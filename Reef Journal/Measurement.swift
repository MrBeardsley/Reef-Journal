//
//  Measurement.swift
//  Reef Journal
//
//  Created by Christopher Harding on 8/19/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation
import CoreData

public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public final class Measurement: NSManagedObject {

    @NSManaged var day: NSDate
    @NSManaged var value: Double
    @NSManaged private var primitiveParameter: String
    
    var parameter: Parameter {
        get {
            willAccessValueForKey("parameter")
            let paramString = primitiveParameter
            didAccessValueForKey("parameter")
            
            return Parameter(rawValue: paramString)!
        }
        set {
            willChangeValueForKey("parameter")
            primitiveParameter = newValue.rawValue
            didChangeValueForKey("parameter")
        }
    }
}

extension Measurement: ManagedObjectType {

    public static var entityName: String {
        return "Measurement"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "day", ascending: false)]
    }
}

extension Measurement: CustomDebugStringConvertible {
    override public var debugDescription: String {
        get {
            return "Parameter: \(parameter.rawValue), Value: \(value), Date: \(day)"
        }
    }
}

extension Measurement {
    var convertedMeasurementValue: Double {
        
        switch parameter {
        case .Alkalinity:
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
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
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
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
            if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.TemperatureUnits.rawValue) as? Int,
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
