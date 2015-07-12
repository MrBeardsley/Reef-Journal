//
//  Alkalinity.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/4/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

struct Alkalinity {
    var dkh: Double {
        get { return meqL * 2.8 }
        set { meqL = newValue / 2.8 }
    }
    var meqL: Double = 0
    var ppm: Double {
        get { return meqL * 50.0 }
        set { meqL = newValue / 50.0 }
    }

    init(_ alk: Double, unit: AlkalinityUnit = .DKH) {
        switch unit {
        case .DKH:
            dkh = alk
        case .MeqL:
            meqL = alk
        case .PPM:
            ppm = alk
        }
    }
}

func ==(lhs: Alkalinity, rhs: Alkalinity) -> Bool {
    return lhs.dkh == rhs.dkh
}

func <(lhs: Alkalinity, rhs: Alkalinity) -> Bool {
    return lhs.dkh < rhs.dkh
}

extension Alkalinity: CustomStringConvertible {
    var description: String { get { return "" } }
}

enum AlkalinityUnit: Int {
    case DKH = 0, MeqL, PPM
}

enum AlkalinityLabel: String {
    case DKH = "dKH"
    case MeqL = "meq/L"
    case PPM = "ppm"
}