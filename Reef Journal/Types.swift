//
//  Types.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
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
}

public enum PreferenceIdentifier: String {
    case TemperatureUnits = "temperatureUnits"
    case SalinityUnits = "salinityUnits"
    case AlkalinityUnits = "alkalinityUnits"
    case EnableTemperature = "enableTemperature"
    case EnableSalinity = "enableSalinity"
    case EnablePH = "enablePH"
    case EnableAlkalinity = "enableAlkalinity"
    case EnableCalcium = "enableCalcium"
    case EnableMagnesium = "enableMagnesium"
    case EnableStrontium = "enableStrontium"
    case EnablePotassium = "enablePotassium"
    case EnableAmmonia = "enableAmmonia"
    case EnableNitrite = "enableNitrite"
    case EnableNitrate = "enableNitrate"
    case EnablePhosphate = "enablePhosphate"    
}

public enum AlkalinityUnit: String {
    case DKH = "dKH"
    case MeqL = "meq/L"
    case PPT = "ppt"

    init (rawInt: Int) {
        switch rawInt {
        case 0:
            self = .DKH
        case 1:
            self = .MeqL
        case 2:
            self = .PPT
        default:
            self = .DKH
        }
    }
}

public enum SalinityUnit: String {
    case SG = "sg"
    case PPT = "ppt"

    init (rawInt: Int) {
        switch rawInt {
        case 0:
            self = .SG
        case 1:
            self = .PPT

        default:
            self = .SG
        }
    }
}

public enum TemperatureUnit: String {
    case Fahrenheit = "\u{2109}"
    case Celcius = "\u{2103}"

    init (rawInt: Int) {
        switch rawInt {
        case 0:
            self = .Fahrenheit
        case 1:
            self = .Celcius
        default:
            self = .Fahrenheit
        }
    }
}

func parameterForPreference(preference: PreferenceIdentifier) -> Parameter {

    switch preference {
    case .TemperatureUnits: return Parameter.Temperature
    case .SalinityUnits: return Parameter.Salinity
    case .AlkalinityUnits: return Parameter.Alkalinity
    case .EnableTemperature: return Parameter.Temperature
    case .EnableSalinity: return Parameter.Salinity
    case .EnablePH: return Parameter.pH
    case .EnableAlkalinity: return Parameter.Alkalinity
    case .EnableCalcium: return Parameter.Calcium
    case .EnableMagnesium: return Parameter.Magnesium
    case .EnableStrontium: return Parameter.Strontium
    case .EnablePotassium: return Parameter.Potasium
    case .EnableAmmonia: return Parameter.Ammonia
    case .EnableNitrite: return Parameter.Nitrite
    case .EnableNitrate: return Parameter.Nitrate
    case .EnablePhosphate: return Parameter.Phosphate
    }
}

let parameterList = [Parameter.Salinity.rawValue, Parameter.Temperature.rawValue, Parameter.Alkalinity.rawValue, Parameter.Calcium.rawValue, Parameter.Magnesium.rawValue, Parameter.pH.rawValue, Parameter.Strontium.rawValue, Parameter.Potasium.rawValue, Parameter.Ammonia.rawValue, Parameter.Nitrite.rawValue, Parameter.Nitrate.rawValue, Parameter.Phosphate.rawValue]

protocol ParentControllerDelegate {
    func refreshData()
}