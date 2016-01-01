//
//  Functions.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

/**
Takes a parameter and returns a string representing the unit label for the type of the parameter

:param: type The type of parameter

:returns: The unit of measure label
*/
//func unitLabelForParameterType(type: Parameter) -> String {
//    switch (type) {
//    case .Calcium, .Magnesium, .Strontium, .Potasium, .Phosphate, .Ammonia, .Nitrite, .Nitrate:
//        return "ppm"
//    case .Alkalinity:
//        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.AlkalinityUnits.rawValue) as? Int,
//           let alkUnit = AlkalinityUnit(rawValue: intValue) {
//            switch alkUnit {
//            case .DKH:
//                return AlkalinityLabel.DKH.rawValue
//            case .MeqL:
//                return AlkalinityLabel.MeqL.rawValue
//            case .PPM:
//                return AlkalinityLabel.PPM.rawValue
//            }
//        }
//        else {
//            return ""
//        }
//    case .Salinity:
//        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.SalinityUnits.rawValue) as? Int,
//            let salUnit = SalinityUnit(rawValue: intValue) {
//                switch salUnit {
//                case .SG: return SalinityLabel.SG.rawValue
//                case .PSU: return SalinityLabel.PSU.rawValue
//                }
//        }
//        else {
//            return ""
//        }
//    case .pH:
//        return ""
//    case .Temperature:
//        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.TemperatureUnits.rawValue) as? Int,
//           let tempUnit = TemperatureUnit(rawValue: intValue) {
//            switch tempUnit {
//            case .Fahrenheit:
//                return TemperatureLabel.Fahrenheit.rawValue
//            case.Celcius:
//                return TemperatureLabel.Celcius.rawValue
//            }
//        }
//        else {
//            return ""
//        }
//    }
//}

/**
Takes a parameter and returns a string representing the unit label for the type of the parameter

:param: type The type of parameter

:returns: The unit of measure label
*/
func measurementRangeForParameterType(type: Parameter) -> (Double, Double) {
    switch (type) {
    case .Calcium: return (min: 0, max: 600)
    case .Magnesium: return (min: 800, max: 2000)
    case .Strontium: return (min: 0, max: 30)
    case .Potasium: return (min: 0, max: 600)
    case .Phosphate: return (min: 0, max: 1)
    case .Ammonia: return (min: 0, max: 5)
    case .Nitrite: return (min: 0, max: 20)
    case .Nitrate: return (min: 0, max: 200)
    case .Alkalinity:
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.AlkalinityUnits.rawValue) as? Int,
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
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.SalinityUnits.rawValue) as? Int,
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
        if let intValue = NSUserDefaults.standardUserDefaults().valueForKey(AppSettingKey.TemperatureUnits.rawValue) as? Int,
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

