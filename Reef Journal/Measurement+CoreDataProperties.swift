//
//  Measurement+CoreDataProperties.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/19/15.
//  Copyright © 2015 Epic Kiwi Interactive.
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

extension Measurement: CustomDebugStringConvertible {
    override var debugDescription: String {
        get {
            let date = NSDate(timeIntervalSinceReferenceDate: self.day)
            if let param = self.parameter {
                return "Parameter: \(param), Value:\(self.value), Date: \(date)"
            }
            else { return "Invalid Measurement" }
        }
    }
}
