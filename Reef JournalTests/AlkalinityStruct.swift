//
//  AlkalinityStruct.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/4/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import XCTest
import Reef_Journal

class Alkalinity_Struct: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDKHToMeqL() {
        NSUserDefaults.standardUserDefaults().setValue(0, forKey: PreferenceIdentifier.AlkalinityUnits.rawValue)
        var measurement = Alkalinity(alkValue: 10.0)
        XCTAssert(measurement.meqL == 100.0, "Pass")
    }
//
//    func testFahrenheitToCelciusFreezingPoint() {
//        NSUserDefaults.standardUserDefaults().setValue(0, forKey: PreferenceIdentifier.TemperatureUnits.rawValue)
//        var freezingTemp = Temperature(aTemp: 32)
//        XCTAssert(freezingTemp.celcius == 0.0, "Pass")
//    }
//
//    func testCelciusToFahrenheitBoilingPoint() {
//        NSUserDefaults.standardUserDefaults().setValue(1, forKey: PreferenceIdentifier.TemperatureUnits.rawValue)
//        var boilingPoint = Temperature(aTemp: 100.0)
//        XCTAssert(boilingPoint.fahrenheit == 212.0, "Pass")
//    }
//
//    func testCelciusToFahrenheitFreezingPoint() {
//        NSUserDefaults.standardUserDefaults().setValue(1, forKey: PreferenceIdentifier.TemperatureUnits.rawValue)
//        var freezingTemp = Temperature(aTemp: 0.0)
//        XCTAssert(freezingTemp.fahrenheit == 32.0, "Pass")
//    }
}
