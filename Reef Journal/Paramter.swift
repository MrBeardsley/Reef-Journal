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
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.AlkalinityUnits.rawValue) as? Int,
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
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.SalinityUnits.rawValue) as? Int,
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
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.AlkalinityUnits.rawValue) as? Int,
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
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.SalinityUnits.rawValue) as? Int,
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
                if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.TemperatureUnits.rawValue) as? Int,
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
    
    // MARK: - Static Functions
    
    static func parameterForSetting(setting: AppSettingKey) -> Parameter {
        
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