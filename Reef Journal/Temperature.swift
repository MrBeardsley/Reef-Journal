//
//  TemperatureValue.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

public struct Temperature {
    public var fahrenheit: Double = 0.0 // Store all values in Fahrenheit by default
    public var celcius: Double {
        get {
            return (fahrenheit - 32.0) * 5.0 / 9.0
        }
        
        set {
            fahrenheit = (newValue * 9.0 / 5.0) + 32.0
        }
    }

    public var preferredTemperature: Double? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let preferenceValue = userDefaults.valueForKey(PreferenceIdentifier.TemperatureUnits.rawValue) as? Int {
            switch TemperatureUnit(rawInt: preferenceValue) {
            case .Fahrenheit:
                return self.fahrenheit
            case .Celcius:
                return self.celcius
            }
        }
        else {
            return nil
        }
    }

    public init(fromFahrenheit: Double) {
        self.fahrenheit = fromFahrenheit
    }
    
    public init(fromCelcius: Double) {
        self.celcius = fromCelcius
    }
    
    public init?(preferredTemp: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let preferenceValue = userDefaults.valueForKey(PreferenceIdentifier.TemperatureUnits.rawValue) as? Int {
            switch TemperatureUnit(rawInt: preferenceValue) {
            case .Fahrenheit:
                self.init(fromFahrenheit: preferredTemp)
            case .Celcius:
                self.init(fromCelcius: preferredTemp)
            }
        }
        else {
            return nil
        }
    }
}