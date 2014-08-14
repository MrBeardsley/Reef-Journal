//
//  Measurement.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/14/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation
import CoreData

class Measurement: NSManagedObject {

    @NSManaged var day: NSTimeInterval
    @NSManaged var type: String
    @NSManaged var value: Double

}
