//
//  TemperatureValue.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

public struct Temperature : Equatable, Comparable {

    public var celcius: Double = 0
    public var fahrenheit: Double {
        get { return celcius * 9/5 + 32 }
        set { celcius = (newValue - 32) * 5/9 }
    }

    public init(_ temp: Double, unit: TemeratureUnit = TemeratureUnit.Fahrenheit) {
        switch unit {
        case .Fahrenheit:
            fahrenheit = temp
        case .Celcius:
            celcius = temp
        }
    }
}

public func ==(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.celcius == rhs.celcius
}

public func <(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.celcius < rhs.celcius
}

public enum TemeratureUnit {
    case Celcius
    case Fahrenheit
}

extension Temperature: Printable {
    public var description: String { get { return "\(celcius) degrees Celcius, \(fahrenheit) degrees Fahrenheit" } }
}