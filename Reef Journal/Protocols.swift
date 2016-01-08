//
//  Protocols.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/2/16
//  Copyright © 2016 Epic Kiwi Interactive
//

import UIKit
import CoreData

protocol DataModel: class {
    var managedObjectContext: NSManagedObjectContext { get }
}

extension DataModel {
    var managedObjectContext: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.dataPersistence.managedObjectContext
        }
    }
}

protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension ManagedObjectType {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    static var sortedFetchRequest: NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}


protocol EnableParametersType: class {
    var enabledChemistryParameters: [Parameter] { get }
    var enabledNutrientParameters: [Parameter] { get }
}

extension EnableParametersType {
    var enabledChemistryParameters: [Parameter] {
        
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
    
    var enabledNutrientParameters: [Parameter] {
        
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
}

protocol DisplaysInDetailViewType {
    var shouldCollapseSplitView: Bool { get }
}
