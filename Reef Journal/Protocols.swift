//
//  Protocols.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/2/16.
//  Copyright © 2016 Epic Kiwi Interactive. All rights reserved.
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