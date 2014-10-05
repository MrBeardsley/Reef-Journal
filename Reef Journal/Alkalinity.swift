//
//  Alkalinity.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/4/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

public struct Alkalinity {
    private var internalStorage: Double = 0.0
    public var dKH: Double {return internalStorage }
    public var meqL: Double {return internalStorage }
    public var ppt: Double {return internalStorage }

    public init(alkValue: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let intValue = userDefaults.valueForKey(PreferenceIdentifier.AlkalinityUnits.rawValue) as? Int {
            switch AlkalinityUnit(rawInt: intValue) {
            case .DKH:
                internalStorage = alkValue
            case .MeqL:
                internalStorage = dkhFromMeqL(alkValue)
            case .PPT:
                internalStorage = dkhFromPPT(alkValue)
            }
        }
    }

    private func dkhFromMeqL(value: Double) -> Double {
        return 0.0
    }

    private func dkhFromPPT(value: Double) -> Double {
        return 0.0
    }
}