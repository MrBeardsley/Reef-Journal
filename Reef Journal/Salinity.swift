//
//  Salinity.swift
//  Reef Journal
//
//  Created by Christopher Harding on 12/14/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import Darwin  // Needed for the round function

struct Salinity {
    var sg: Double = 0.0
    var psu: Double {
        get { return round((sg - 1) / 0.00075333333333) }
        set { sg = round((newValue * 0.00075333333333 + 1) * 10000) / 10000 }
    }

    init(_ sal: Double, unit: SalinityUnit = .SG) {
        switch unit {
        case .SG:
            sg = sal
        case .PSU:
            psu = sal
        }
    }
}

func ==(lhs: Salinity, rhs: Salinity) -> Bool {
    return lhs.sg == rhs.sg
}

func <(lhs: Salinity, rhs: Salinity) -> Bool {
    return lhs.sg < rhs.sg
}

extension Salinity: CustomStringConvertible {
    var description: String { get { return "" } }
}

enum SalinityUnit: Int {
    case SG = 0, PSU
}

enum SalinityLabel: String {
    case SG = "dKH"
    case PSU = "PSU"
}