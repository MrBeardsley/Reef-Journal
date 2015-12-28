//
//  AppData.swift
//  Reef Journal
//
//  Created by Christopher Harding on 12/27/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation
import CoreData

class AppData {
    
    var dataPersistence: DataPersistence!
    
    func mostUsedParameters() -> [String] {
        guard let context = dataPersistence?.managedObjectContext else { return [] }
        
        // Keep track of the counts as we get them from the data store
        var runningTotals = [String : Int]()
        var enabledParameters = [Parameter]()
        
        // Get a list of all enabled parameters
        let defaults = NSUserDefaults.standardUserDefaults()
        
        for item in parameterEnabledSettings {
            let enabled = defaults.boolForKey(item.rawValue)
            if enabled {
                enabledParameters.append(parameterForPreference(item))
            }
        }
        
        // Count the number of saved
        
        for param in enabledParameters {
            let fetchRequest = NSFetchRequest(entityName: measurementEntityName)
            let pred = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
            fetchRequest.predicate = pred
            fetchRequest.includesPropertyValues = false
            fetchRequest.includesSubentities = false
            var error: NSError? = nil
            let count = context.countForFetchRequest(fetchRequest, error:&error)
            
            runningTotals[param.rawValue] = count
        }
        
        let keys = Array(runningTotals.keys)
        let sortedKeys = keys.sort() { return runningTotals[$0] > runningTotals[$1] }
        
        // If there are more than 4 remove the extras
        if sortedKeys.count > 4 {
            return Array(sortedKeys[0..<4])
        }
        else {
            return sortedKeys
        }
    }
}
