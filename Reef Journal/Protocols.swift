//
//  Protocols.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/2/16.
//  Copyright © 2016 Epic Kiwi Interactive. All rights reserved.
//

import Foundation
import CoreData

protocol DataModel: class {
    var managedObjectContext: NSManagedObjectContext { get }
    init(context: NSManagedObjectContext)
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