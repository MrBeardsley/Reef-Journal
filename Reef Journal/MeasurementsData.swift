//
//  MeasurementsData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/13/15.
//  Copyright © 2015 Epic Kiwi Interactive
//

import UIKit
import CoreData

extension NSDate {    
    func dayFromDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: self)
        return calendar.dateFromComponents(components)!
    }
}

class MeasurementsData {
    
    var dataPersistence: DataPersistence?
    
    var managedObjectContext: NSManagedObjectContext? {
        get {
            return dataPersistence?.managedObjectContext
        }
    }
    
    init() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            self.dataPersistence = appDelegate.dataPersistence
        }
    }

    // MARK: - Data persistence operations

    func saveMeasurement(value: Double, date: NSDate, param: Parameter) {
        guard let context = self.managedObjectContext else { return }
        
        var valueToSave: Double
        
        switch param {
        case .Alkalinity:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSetting.AlkalinityUnits.rawValue) as? Int,
                let alkUnit = AlkalinityUnit(rawValue: intValue) {
                switch alkUnit {
                case .DKH:
                    let alk = Alkalinity(value, unit: .DKH)
                    valueToSave = alk.dkh
                case .MeqL:
                    let alk = Alkalinity(value, unit: .MeqL)
                    valueToSave = alk.dkh
                case .PPM:
                    let alk = Alkalinity(value, unit: .PPM)
                    valueToSave = alk.dkh
                }
            }
            else {
                valueToSave = value
            }
        case .Salinity:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSetting.SalinityUnits.rawValue) as? Int,
                let salUnit = SalinityUnit(rawValue: intValue) {
                switch salUnit {
                case .SG:
                    let salinity = Salinity(value, unit: .SG)
                    valueToSave = salinity.sg
                case .PSU:
                    let salinity = Salinity(value, unit: .PSU)
                    valueToSave = salinity.sg
                }
            }
            else {
                valueToSave = value
            }
        case .Temperature:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSetting.TemperatureUnits.rawValue) as? Int,
                let tempUnit = TemperatureUnit(rawValue: intValue) {
                switch tempUnit {
                case .Fahrenheit:
                    let temp = Temperature(value, unit: .Fahrenheit)
                    valueToSave = temp.fahrenheit
                case.Celcius:
                    let temp = Temperature(value, unit: .Celcius)
                    valueToSave = temp.fahrenheit
                }
            }
            else {
                valueToSave = value
            }
        default:
            valueToSave = value
            
        }

        if let aMesurement = self.measurementForDate(date, param: param) {
            aMesurement.value = valueToSave
            aMesurement.parameter = param.rawValue
            aMesurement.day = date.dayFromDate().timeIntervalSinceReferenceDate
        }
        else {
            if let newEntity = NSEntityDescription.insertNewObjectForEntityForName(Measurement.entityName, inManagedObjectContext: context) as? Measurement {
                newEntity.value = valueToSave
                newEntity.parameter = param.rawValue
                newEntity.day = date.dayFromDate().timeIntervalSinceReferenceDate
            }
        }
        
        dataPersistence?.saveContext()
    }

    func deleteMeasurementOnDay(day: NSTimeInterval, param: Parameter) {
        guard let context = self.managedObjectContext else { return }
        let date = NSDate(timeIntervalSinceReferenceDate: day)
        if let aMesurement = self.measurementForDate(date, param: param) {
            context.deleteObject(aMesurement)
            dataPersistence?.saveContext()
        }
    }

    func mostRecentMeasurements() -> [String : Measurement] {
        guard let context = self.managedObjectContext else { return [:] }
        var recentMeasurements = [String : Measurement]()

        for item in Parameter.allParameters {
            let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
            let predicate = NSPredicate(format: "parameter = %@", argumentArray: [item.rawValue])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
            fetchRequest.fetchLimit = 1

            do {
                let results = try context.executeFetchRequest(fetchRequest)

                if let aMeasurement = results.last as? Measurement,
                   let param = aMeasurement.parameter {
                    recentMeasurements[param] = aMeasurement
                }
            }
            catch {
                let nserror = error as NSError
                NSLog("Error in fetch of measurements for enabled paramters: \(nserror), \(nserror.userInfo)")
            }
        }

        return recentMeasurements
    }

    func measurementForDate(date: NSDate, param: Parameter) -> Measurement? {
        guard let context = self.managedObjectContext else { return nil }
        
        let day = date.dayFromDate()
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter == %@ AND day == %@", argumentArray: [param.rawValue, day])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.executeFetchRequest(fetchRequest)
            if let aMeasurement = results.last as? Measurement {
                return aMeasurement
            }
            else {
                return nil
            }
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of measurement for paramter type \(param.rawValue) on \(date.description): \(nserror), \(nserror.userInfo)")
            return nil
        }
    }

    func measurementsForParameter(param: Parameter) -> [Measurement] {
        guard let context = self.managedObjectContext else { return [] }
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors

        do {
            let results = try context.executeFetchRequest(fetchRequest)
            if let results = results as? [Measurement] {
                return results
            }
            else { return [] }
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of measurement for paramter type \(param.rawValue): \(nserror), \(nserror.userInfo)")
            return []
        }
    }

    func lastMeasurementValueForParameter(param: Parameter) -> Measurement? {
        guard let context = self.managedObjectContext else { return nil }
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter = %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.executeFetchRequest(fetchRequest)
            if let aMeasurement = results.last as? Measurement {
                return aMeasurement

            }
            else {
                return nil
            }
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of last measurement for paramter type \(param.rawValue): \(nserror), \(nserror.userInfo)")
            return nil
        }
    }

    func dateHasMeasurement(date: NSDate, param: Parameter) -> Bool {
        return self.measurementForDate(date, param: param) == nil ? false : true
    }
}
