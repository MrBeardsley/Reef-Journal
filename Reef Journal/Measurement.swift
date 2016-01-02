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
    @NSManaged private var value: Double
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
    
    var convertedValue: Double {
        get {
            
            willAccessValueForKey("value")
            let primValue = value
            didAccessValueForKey("value")
            
            switch parameter {
            case .Alkalinity:
                let alk = Alkalinity(primValue, unit: .DKH)
                
                if let
                    intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
                    alkUnit = AlkalinityUnit(rawValue: intValue) {
                        
                    switch alkUnit {
                    case .DKH:  return alk.dkh
                    case .MeqL: return alk.meqL
                    case .PPM:  return alk.ppm
                    }
                } else {
                    return alk.dkh
                }
                
            case .Salinity:
                let salinity = Salinity(primValue, unit: .SG)
                
                if let
                    intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
                    salUnit = SalinityUnit(rawValue: intValue) {
                    
                    switch salUnit {
                    case .SG:   return salinity.sg
                    case .PSU:  return salinity.psu
                    }
                } else {
                    return salinity.sg
                }
                
            case .Temperature:
                let temp = Temperature(primValue, unit: .Fahrenheit)
                
                if let
                    intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.TemperatureUnits.rawValue) as? Int,
                    tempUnit = TemperatureUnit(rawValue: intValue) {
                        
                    switch tempUnit {
                    case .Fahrenheit:   return temp.fahrenheit
                    case.Celcius:       return temp.celcius
                    }
                }
                else {
                    return temp.fahrenheit
                }
                
            default:
                return primValue
            }
        }
        
        set {
            
            var primValue: Double
            
            switch parameter {
            case .Alkalinity:
                if let
                    intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
                    alkUnit = AlkalinityUnit(rawValue: intValue) {
                        
                    switch alkUnit {
                    case .DKH:
                        let alk = Alkalinity(newValue, unit: .DKH)
                        primValue = alk.dkh
                    case .MeqL:
                        let alk = Alkalinity(newValue, unit: .MeqL)
                        primValue = alk.dkh
                    case .PPM:
                        let alk = Alkalinity(newValue, unit: .PPM)
                        primValue = alk.dkh
                    }
                } else {
                    primValue = newValue
                }
                
            case .Salinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
                    let salUnit = SalinityUnit(rawValue: intValue) {
                        switch salUnit {
                        case .SG:
                            let salinity = Salinity(newValue, unit: .SG)
                            primValue = salinity.sg
                        case .PSU:
                            let salinity = Salinity(newValue, unit: .PSU)
                            primValue = salinity.sg
                        }
                } else {
                    primValue = newValue
                }
                
            case .Temperature:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.TemperatureUnits.rawValue) as? Int,
                    let tempUnit = TemperatureUnit(rawValue: intValue) {
                        switch tempUnit {
                        case .Fahrenheit:
                            let temp = Temperature(newValue, unit: .Fahrenheit)
                            primValue = temp.fahrenheit
                        case.Celcius:
                            let temp = Temperature(newValue, unit: .Celcius)
                            primValue = temp.fahrenheit
                        }
                } else {
                    primValue = newValue
                }
                
            default:
                primValue = newValue
            }
            
            willChangeValueForKey("value")
            value = primValue
            didChangeValueForKey("value")
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


