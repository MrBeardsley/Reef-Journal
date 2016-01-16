//
//  Temperature.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/1/14
//  Copyright © 2015 Epic Kiwi Interactive
//

struct Temperature : Equatable, Comparable {

    var celcius: Double = 0
    var fahrenheit: Double {
        get { return celcius * 9/5 + 32 }
        set { celcius = (newValue - 32) * 5/9 }
    }

    init(_ temp: Double, unit: TemperatureUnit = .Fahrenheit) {
        switch unit {
        case .Fahrenheit:
            fahrenheit = temp
        case .Celcius:
            celcius = temp
        }
    }
}

func ==(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.celcius == rhs.celcius
}

func <(lhs: Temperature, rhs: Temperature) -> Bool {
    return lhs.celcius < rhs.celcius
}

extension Temperature: CustomStringConvertible {
    var description: String { get { return "\(celcius) degrees Celcius, \(fahrenheit) degrees Fahrenheit" } }
}

enum TemperatureUnit: Int {
    case Fahrenheit = 0, Celcius
}

enum TemperatureLabel: String {
    case Fahrenheit = "\u{2109}"
    case Celcius = "\u{2103}"
}