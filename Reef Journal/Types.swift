//
//  Types.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

enum Parameter: String {
    case Salinity = "Salinity"
    case Temperature = "Temperature"
    case Alkalinity = "Alkalinity"
    case Calcium = "Calcium"
    case Magnesium = "Magnesium"
    case pH = "pH"
    case Strontium = "Strontium"
    case Potasium = "Potasium"
    case Ammonia = "Ammonia"
    case Nitrite = "Nitrite"
    case Nitrate = "Nitrate"
    case Phosphate = "Phosphate"
}

enum PreferenceIdentifier: String {
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

enum AlkalinityUnit: String {
    case dKH = "dKH"
    case meqL = "meq/L"
    case ppt = "ppt"

    init (rawInt: Int) {
        switch rawInt {
        case 0:
            self = .dKH
        case 1:
            self = .meqL
        case 2:
            self = .ppt
        default:
            self = .dKH
        }
    }
}

enum SalinityUnit: String {
    case sg = "sg"
    case ppt = "ppt"

    init (rawInt: Int) {
        switch rawInt {
        case 0:
            self = .sg
        case 1:
            self = .ppt

        default:
            self = .sg
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

func decimalPlacesForParameter(type: Parameter) -> Int {
    switch type {
    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
        return 0
    case .Temperature, .pH:
        return 1
    case .Alkalinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(PreferenceIdentifier.AlkalinityUnits.toRaw()) as? Int {
            switch AlkalinityUnit(rawInt: intValue) {
            case .dKH, .meqL: return 1
            case .ppt: return 0
            }
        }
        else {
            return 0
        }
    case .Salinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(PreferenceIdentifier.SalinityUnits.toRaw()) as? Int {
            switch SalinityUnit(rawInt: intValue) {
            case .sg: return 3
            case .ppt: return 0
            }
        }
        else {
            return 3
        }
    }
}

func parameterTypeDisplaysDecimal(type: Parameter) -> Bool {
    switch (type) {
    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
        return false
    case .Alkalinity, .Salinity, .pH, .Temperature:
        return true
    }
}

func unitLabelForParameterType(type: Parameter) -> String {
    switch (type) {
    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
        return "ppm"
    case .Alkalinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(PreferenceIdentifier.AlkalinityUnits.toRaw()) as? Int {
            return AlkalinityUnit(rawInt: intValue).toRaw()
        }
        else {
            return "dKH"
        }
    case .Salinity:
        return "sg"
    case .pH:
        return ""
    case .Temperature:
        return "degrees"
    }
}

protocol ParentControllerDelegate {
    func refreshData()
}