//
//  TemperatureValue.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

public struct Temperature {
    private var internalStorage: Double = 0.0
    public var fahrenheit: Double { return internalStorage }
    public var celcius: Double { return (internalStorage - 32.0) * 5.0 / 9.0 }

    public init(aTemp: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let intValue = userDefaults.valueForKey(PreferenceIdentifier.TemperatureUnits.rawValue) as? Int {
            switch TemperatureUnit(rawInt: intValue) {
            case .Fahrenheit:
                internalStorage = aTemp
            case .Celcius:
                internalStorage = fahrenheitFromCelcius(aTemp)
            }
        }
    }

    private func fahrenheitFromCelcius(value: Double) -> Double {
        return value * 9.0 / 5.0 + 32.0
    }
}