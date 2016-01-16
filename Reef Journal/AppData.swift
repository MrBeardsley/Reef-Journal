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
    
    // MARK: - Properties
    
    var mostUsedParameters: [(String, Int)] {
        
        get {
        
            // Keep track of the counts as we get them from the data store
            var runningTotals = [String : Int]()
            var enabledParameters = [Parameter]()
            
            // Get a list of all enabled parameters
            let defaults = NSUserDefaults.standardUserDefaults()
            
            for item in SettingsKey.enabledParameterKeys {
                let enabled = defaults.boolForKey(item.rawValue)
                if enabled {
                    enabledParameters.append(Parameter.parameterForSetting(item))
                }
            }
            
            // Count the number of saved
            
            for param in enabledParameters {
                let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
                let pred = NSPredicate(format: "parameter == %@", argumentArray: [param.rawValue])
                fetchRequest.predicate = pred
                fetchRequest.includesPropertyValues = false
                fetchRequest.includesSubentities = false
                var error: NSError? = nil
                let count = managedObjectContext.countForFetchRequest(fetchRequest, error:&error)
                
                runningTotals[param.rawValue] = count
            }
            
            let keys = Array(runningTotals.keys)
            var sortedKeys = keys.sort() { return runningTotals[$0] > runningTotals[$1] }
            
            // If there are more than 4 remove the extras
            if sortedKeys.count > 4 {
                sortedKeys = Array(sortedKeys[0..<4])
            }
            
            sortedKeys = Array(sortedKeys.reverse())
            
            var results = [(String, Int)]()
            
            for key in sortedKeys {
                results.append((key, runningTotals[key]!))
            }
            
            return results
            
        }
    }
}

// MARK: - Data Model Conformance

extension AppData: DataModel { }
