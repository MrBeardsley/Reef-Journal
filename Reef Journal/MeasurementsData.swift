//
//  MeasurementsData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/13/15
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
    
    // MARK: - Private Properties
    
    private lazy var dataPersistence: DataPersistence = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.dataPersistence
    }()

    // MARK: - Data persistence operations

    func saveMeasurement(value: Double, date: NSDate, param: Parameter) {

        if let aMesurement = self.measurementForDate(date, param: param) {
            aMesurement.convertedValue = value
        } else {
            
            if let newEntity = NSEntityDescription.insertNewObjectForEntityForName(Measurement.entityName, inManagedObjectContext: managedObjectContext) as? Measurement {
                
                newEntity.parameter = param
                newEntity.convertedValue = value
                newEntity.day = date.dayFromDate()
            }
        }
        
        dataPersistence.saveContext()
    }

    func deleteMeasurementOnDay(day: NSDate, param: Parameter) {


        if let aMesurement = self.measurementForDate(day, param: param) {
            managedObjectContext.deleteObject(aMesurement)
            dataPersistence.saveContext()
        }
    }

    func mostRecentMeasurements() -> [String : Measurement] {
        var recentMeasurements = [String : Measurement]()

        for item in Parameter.allParameters {
            let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
            let predicate = NSPredicate(format: "parameter = %@", argumentArray: [item.rawValue])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
            fetchRequest.fetchLimit = 1

            do {
                let results = try managedObjectContext.executeFetchRequest(fetchRequest)

                if let aMeasurement = results.last as? Measurement {
                    recentMeasurements[aMeasurement.parameter.rawValue] = aMeasurement
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
        
        let day = date.dayFromDate()
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter == %@ AND day == %@", argumentArray: [param.rawValue, day])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
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
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors

        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
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
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter = %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
        fetchRequest.fetchLimit = 1

        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
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

// MARK: - Data Model Conformance

extension MeasurementsData: DataModel { }
