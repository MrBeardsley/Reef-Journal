//
//  ParametersListData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/2/16
//  Copyright © 2016 Epic Kiwi Interactive
//

import UIKit
import CoreData

class ParameterListData {
    private var _moc: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        _moc = context
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
}

// MARK: - ManagedObjectContextSettable Conformance

extension ParameterListData: DataModel {
    var managedObjectContext: NSManagedObjectContext {
        get { return _moc }
    }
}
