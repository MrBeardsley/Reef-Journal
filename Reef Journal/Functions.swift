//
//  Functions.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

/**
Return the number of decimal places a parameter will display.

:param: type The type of parameter

:returns: The number of decimal places
*/
func decimalPlacesForParameter(type: Parameter) -> Int {
    switch type {
    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
        return 0
    case .Temperature, .pH:
        return 1
    case .Alkalinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.AlkalinityUnits.rawValue) as? Int,
           let alkUnit = AlkalinityUnit(rawValue: intValue) {
            switch alkUnit {
            case .DKH, .MeqL: return 1
            case .PPT: return 0
            }
        }
        else {
            return 0
        }
    case .Salinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.SalinityUnits.rawValue) as? Int {
            switch SalinityUnit(rawInt: intValue) {
            case .SG: return 3
            case .PPT: return 0
            }
        }
        else {
            return 3
        }
    }
}

/**
Determines if a paramter uses decimal places or not

:param: type The type of parameter

:returns: True/false if the parameter type uses decimal places
*/
func parameterTypeDisplaysDecimal(type: Parameter) -> Bool {
    if decimalPlacesForParameter(type) > 0 {
        return true
    }
    else {
        return false
    }
}

/**
Takes a parameter and returns a string representing the unit label for the type of the parameter

:param: type The type of parameter

:returns: The unit of measure label
*/
func unitLabelForParameterType(type: Parameter) -> String {
    switch (type) {
    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
        return "ppm"
    case .Alkalinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.AlkalinityUnits.rawValue) as? Int,
           let alkUnit = AlkalinityUnit(rawValue: intValue) {
            switch alkUnit {
            case .DKH:
                return AlkalinityLabel.DKH.rawValue
            case .MeqL:
                return AlkalinityLabel.MeqL.rawValue
            case .PPT:
                return AlkalinityLabel.PPT.rawValue
            }
        }
        else {
            return ""
        }
    case .Salinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.SalinityUnits.rawValue) as? Int {
            return SalinityUnit(rawInt: intValue).rawValue
        }
        else {
            return SalinityUnit.SG.rawValue
        }
    case .pH:
        return ""
    case .Temperature:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(SettingIdentifier.TemperatureUnits.rawValue) as? Int,
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
