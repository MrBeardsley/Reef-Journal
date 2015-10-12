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

extension Measurement {
    var convertedMeasurementValue: Double {
        guard let type = self.parameter, param = Parameter(rawValue: type) else { return 0 }
        
        switch param {
        case .Alkalinity:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.AlkalinityUnits.rawValue) as? Int,
                let alkUnit = AlkalinityUnit(rawValue: intValue) {
                    switch alkUnit {
                    case .DKH:
                        let alk = Alkalinity(self.value, unit: .DKH)
                        return alk.dkh
                    case .MeqL:
                        let alk = Alkalinity(self.value, unit: .DKH)
                        return alk.meqL
                    case .PPM:
                        let alk = Alkalinity(self.value, unit: .DKH)
                        return alk.ppm
                    }
            }
            else {
                return value
            }
        case .Salinity:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.SalinityUnits.rawValue) as? Int,
                let salUnit = SalinityUnit(rawValue: intValue) {
                    switch salUnit {
                    case .SG:
                        let salinity = Salinity(self.value, unit: .SG)
                        return salinity.sg
                    case .PSU:
                        let salinity = Salinity(self.value, unit: .SG)
                        return salinity.psu
                    }
            }
            else {
                return value
            }
        case .Temperature:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.TemperatureUnits.rawValue) as? Int,
                let tempUnit = TemperatureUnit(rawValue: intValue) {
                    switch tempUnit {
                    case .Fahrenheit:
                        let temp = Temperature(self.value, unit: .Fahrenheit)
                        return temp.fahrenheit
                    case.Celcius:
                        let temp = Temperature(self.value, unit: .Fahrenheit)
                        return temp.celcius
                    }
            }
            else {
                return value
            }
        default:
            return value
        }
    }
}
