//
//  Alkalinity.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/4/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Foundation

public struct Alkalinity {
    public var meqL: Double = 0.0 // Store all values in meq / L
 /*   public var dKH: Double {
        get {
            return self.meqL * 2.8
        }
        
        set {
            self.meqL = newValue / 2.8
        }
    }
    public var ppt: Double {
        
        get {
            return self.meqL * 50
        }
        
        set {
            self.meqL = newValue / 50
        }
    }
    
    
    public var preferredAlk: Double? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let preferenceValue = userDefaults.valueForKey(PreferenceIdentifier.AlkalinityUnits.rawValue) as? Int {
            switch AlkalinityUnit(rawInt: preferenceValue) {
            case .DKH:
                return self.dKH
            case .MeqL:
                return self.meqL
            case .PPT:
                return self.ppt
            }
        }
        else {
            return nil
        }
    }

    public init(fromDKH: Double) {
        self.dKH = fromDKH
    }
    
    public init(fromMeqL: Double) {
        self.meqL = fromMeqL
    }
    
    public init(fromPPT: Double) {
        self.ppt = fromPPT
    }
    
    public init?(preferredAlk: Double) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let preferenceValue = userDefaults.valueForKey(PreferenceIdentifier.AlkalinityUnits.rawValue) as? Int {
            switch AlkalinityUnit(rawInt: preferenceValue) {
            case .DKH:
                self.init(fromDKH: preferredAlk)
            case .MeqL:
                self.init(fromMeqL: preferredAlk)
            case .PPT:
                self.init(fromPPT: preferredAlk)
            }
        }
        else {
            return nil
        }
    }
    */
}