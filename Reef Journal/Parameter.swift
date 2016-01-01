//
//  Paramter.swift
//  Reef Journal
//
//  Created by Christopher Harding on 1/1/16
//  Copyright © 2016 Epic Kiwi Interactive
//

import Foundation

enum Parameter: String {
    case Salinity
    case Temperature
    case Alkalinity
    case Calcium
    case Magnesium
    case pH
    case Strontium
    case Potasium
    case Ammonia
    case Nitrite
    case Nitrate
    case Phosphate
    
    // MARK: - Static Properties
    
    static var allParameters: [Parameter] {
        return self.chemistryParameters + self.nutrientParameters
    }
    
    static var chemistryParameters: [Parameter] {
        return [.Salinity, .Temperature, .Alkalinity, .Calcium, .Magnesium, .pH, .Strontium, .Potasium]
    }
    
    static var nutrientParameters: [Parameter] {
        return [.Ammonia, .Nitrite, .Nitrate, .Phosphate]
    }
    
    // MARK: - Instance Properties
    
    var decimalPlaces: Int {
        get {
            switch self {
            case .Calcium, .Magnesium, .Potasium, .Nitrate:
                return 0
            case .Temperature, .pH, .Ammonia, .Nitrite, .Strontium:
                return 1
            case .Phosphate:
                return 2
            case .Alkalinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
                    let alkUnit = AlkalinityUnit(rawValue: intValue) {
                        switch alkUnit {
                        case .DKH, .MeqL: return 1
                        case .PPM: return 0
                        }
                }
                else {
                    return 0
                }
            case .Salinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
                    let salUnit = SalinityUnit(rawValue: intValue) {
                        switch salUnit {
                        case .SG: return 3
                        case .PSU: return 0
                        }
                }
                else {
                    return 0
                }
            }
        }
    }
    
    var displaysDecimalDigits: Bool {
        get {
            return decimalPlaces > 0
        }
    }
    
    var unitLabel: String {
        get {
            switch self {
            case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
                return "ppm"
            case .Alkalinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
                    let alkUnit = AlkalinityUnit(rawValue: intValue) {
                        switch alkUnit {
                        case .DKH:
                            return AlkalinityLabel.DKH.rawValue
                        case .MeqL:
                            return AlkalinityLabel.MeqL.rawValue
                        case .PPM:
                            return AlkalinityLabel.PPM.rawValue
                        }
                }
                else {
                    return ""
                }
            case .Salinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
                    let salUnit = SalinityUnit(rawValue: intValue) {
                        switch salUnit {
                        case .SG: return SalinityLabel.SG.rawValue
                        case .PSU: return SalinityLabel.PSU.rawValue
                        }
                }
                else {
                    return ""
                }
            case .pH:
                return ""
            case .Temperature:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.TemperatureUnits.rawValue) as? Int,
                    let tempUnit = TemperatureUnit(rawValue: intValue) {
                        switch tempUnit {
                        case .Fahrenheit:
                            return TemperatureLabel.Fahrenheit.rawValue
                        case.Celcius:
                            return TemperatureLabel.Celcius.rawValue
                        }
                }
                else {
                    return ""
                }
            }
        }
    }
    
    var measurementRange: (Double, Double) {
        get {
            switch self {
            case .Calcium: return (min: 0, max: 600)
            case .Magnesium: return (min: 800, max: 2000)
            case .Strontium: return (min: 0, max: 30)
            case .Potasium: return (min: 0, max: 600)
            case .Phosphate: return (min: 0, max: 1)
            case .Ammonia: return (min: 0, max: 5)
            case .Nitrite: return (min: 0, max: 20)
            case .Nitrate: return (min: 0, max: 200)
            case .Alkalinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.AlkalinityUnits.rawValue) as? Int,
                    let alkUnit = AlkalinityUnit(rawValue: intValue) {
                        switch alkUnit {
                        case .DKH: return (min: 0, max: 22.4)
                        case .MeqL: return (min: 0, max: 8)
                        case .PPM: return (min: 0, max: 400)
                        }
                }
                else {
                    return (min: 0, max: 22.4)
                }
            case .Salinity:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.SalinityUnits.rawValue) as? Int,
                    let salUnit = SalinityUnit(rawValue: intValue) {
                        switch salUnit {
                        case .SG: return (min: 1.0, max: 1.040)
                        case .PSU: return (min: 0, max: 53)
                        }
                }
                else {
                    return (min: 1.0, max: 1.040)
                }
            case .pH: return (min: 0, max: 14)
            case .Temperature:
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingsKey.TemperatureUnits.rawValue) as? Int,
                    let tempUnit = TemperatureUnit(rawValue: intValue) {
                        switch tempUnit {
                        case .Fahrenheit: return (min: 32, max: 100)
                        case.Celcius: return (min: 0, max: 37.7)
                        }
                }
                else {
                    return (min: 32, max: 100)
                }
            }
        }
    }
    
    // MARK: - Static Functions
    
    static func parameterForSetting(setting: AppSettingsKey) -> Parameter {
        
        switch setting {
        case .TemperatureUnits:     return .Temperature
        case .SalinityUnits:        return .Salinity
        case .AlkalinityUnits:      return .Alkalinity
        case .EnableTemperature:    return .Temperature
        case .EnableSalinity:       return .Salinity
        case .EnablePH:             return .pH
        case .EnableAlkalinity:     return .Alkalinity
        case .EnableCalcium:        return .Calcium
        case .EnableMagnesium:      return .Magnesium
        case .EnableStrontium:      return .Strontium
        case .EnablePotassium:      return .Potasium
        case .EnableAmmonia:        return .Ammonia
        case .EnableNitrite:        return .Nitrite
        case .EnableNitrate:        return .Nitrate
        case .EnablePhosphate:      return .Phosphate
        }
    }
}