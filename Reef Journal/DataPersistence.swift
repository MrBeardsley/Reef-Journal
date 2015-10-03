//
//  DataPersistence.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/13/15.
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation
import CoreData

let measurementEntityName = "Measurement"

class DataPersistence {

    // MARK: - Data persistence operations

    func saveMeasurement(value: Double, date: NSDate, param: Parameter) {

        if let aMesurement = self.measurementForDate(date, param: param) {
            aMesurement.value = value
            aMesurement.parameter = param.rawValue
            aMesurement.day = self.dayFromDate(date).timeIntervalSinceReferenceDate
        }
        else {
            if let newEntity = NSEntityDescription.insertNewObjectForEntityForName(measurementEntityName, inManagedObjectContext: self.managedObjectContext) as? Measurement {
                newEntity.value = value
                newEntity.parameter = param.rawValue
                newEntity.day = self.dayFromDate(date).timeIntervalSinceReferenceDate
            }
        }
        
        self.saveContext()
    }

    func deleteMeasurementOnDay(day: NSTimeInterval, param: Parameter) {
        let date = NSDate(timeIntervalSinceReferenceDate: day)
        if let aMesurement = self.measurementForDate(date, param: param) {
            self.managedObjectContext.deleteObject(aMesurement)
            self.saveContext()
        }
    }

    func mostRecentMeasurements() -> [String : Measurement] {
        let context = self.managedObjectContext
        var recentMeasurements = [String : Measurement]()

        for item in parameterList {
            let fetchRequest = NSFetchRequest(entityName: measurementEntityName)
            let predicate = NSPredicate(format: "parameter = %@", argumentArray: [item])
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
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
        let day = self.dayFromDate(date)
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: measurementEntityName)
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
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: measurementEntityName)
        let predicate = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]

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
        // Coredata fetch to find the most recent measurement
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: measurementEntityName)
        let predicate = NSPredicate(format: "parameter = %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
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
        return self.measurementForDate(date, param: param) == nil ? true : false
    }

    func firstEnabledParameter() -> Parameter {

        return Parameter.Salinity
    }

    // MARK: - Private helpers

    private func dayFromDate(date: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: date)
        return calendar.dateFromComponents(components)!
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.epickiwi.Reef_Journal" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Reef_Journal", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
        }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
