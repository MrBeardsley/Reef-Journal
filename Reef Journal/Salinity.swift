//
//  Salinity.swift
//  Reef Journal
//
//  Created by Christopher Harding on 12/14/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

public struct Salinity {
    public var specificGravity: Double = 0.0
    public var meqL: Double {return specificGravity }
    public var ppt: Double {return specificGravity }
    
    public init(sal: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let preferenceValue = userDefaults.valueForKey(SettingIdentifier.AlkalinityUnits.rawValue) as? Int {
            switch SalinityUnit(rawInt: preferenceValue) {
            case .SG:
                specificGravity = sal
            case .PPT:
                specificGravity = sal
            }
        }
    }
    
    private func sgFromPPT(value: Double) -> Double {
        return 0.0
    }
}




enum SalinityUnit: String {
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