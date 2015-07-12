//
//  Measurement+CoreDataProperties.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/11/15.
//  Copyright © 2015 Epic Kiwi Interactive. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Measurement {

    @NSManaged var day: NSTimeInterval
    @NSManaged var parameter: String?
    @NSManaged var value: Double

}
