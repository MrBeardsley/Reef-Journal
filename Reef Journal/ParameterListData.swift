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
    private var enabledChemistryParameters: [Parameter] {
        
        get {
            var enabled = [Parameter]()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            for item in AppSettingsKey.enabledChemistryKeys {
                if userDefaults.boolForKey(item.rawValue) {
                    enabled.append(Parameter.parameterForSetting(item))
                }
            }
            
            return enabled
        }
    }
    
    private var enabledNutrientParameters: [Parameter] {
        
        get {
            var enabled = [Parameter]()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            for item in AppSettingsKey.enabledNutrientKeys {
                if userDefaults.boolForKey(item.rawValue) {
                    enabled.append(Parameter.parameterForSetting(item))
                }
            }
            
            return enabled
        }
    }
    
    func latestMeasurementForParameter(param: Parameter) -> Measurement? {
        
        let fetchRequest = NSFetchRequest(entityName: Measurement.entityName)
        let predicate = NSPredicate(format: "parameter = %@", argumentArray: [param.rawValue])
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = Measurement.defaultSortDescriptors
        fetchRequest.fetchLimit = 1
        
        var latest: Measurement? = nil
        
        do {
            if let
                results = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Measurement],
                first = results.first {
                latest = first
            }
            
        }
        catch {
            let nserror = error as NSError
            NSLog("Error in fetch of measurements for enabled paramters: \(nserror), \(nserror.userInfo)")
        }
        
        return latest
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

// MARK: - Data Model Conformance

extension ParameterListData: DataModel { }
