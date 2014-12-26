//
//  Reef_JournalTests.swift
//  Reef JournalTests
//
//  Created by Christopher Harding on 6/10/14.
//  Copyright (c) 2014 Christopher Harding. All rights reserved.
//

import XCTest
import Reef_Journal

class Temperature_Struct: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFahrenheitInit() {
        let testValue = 98.6
        var temp = Temperature(fromFahrenheit: testValue)
        XCTAssert(temp.fahrenheit == testValue, "Pass")
    }
    
    func testFahrenheitProperty() {
        let testValue = 75.3
        var temp = Temperature(fromFahrenheit: 50.0)
        temp.fahrenheit = testValue
        XCTAssert(temp.fahrenheit == testValue, "Pass")
    }
    
    func testFahrenheitToCelciusBoilingPoint() {
        var boilingPoint = Temperature(fromFahrenheit: 212.0)
        XCTAssert(boilingPoint.celcius == 100.0, "Pass")
    }

    func testFahrenheitToCelciusFreezingPoint() {
        var freezingTemp = Temperature(fromFahrenheit: 32.0)
        XCTAssert(freezingTemp.celcius == 0.0, "Pass")
    }
    
    func testCelciusInit() {
        let testValue = 98.6
        var temp = Temperature(fromCelcius: testValue)
        XCTAssert(temp.celcius == testValue, "Pass")
    }
    
    func testCelciusProperty() {
        let testValue = 75.3
        var temp = Temperature(fromCelcius: 50.0)
        temp.celcius = testValue
        XCTAssert(temp.celcius == testValue, "Pass")
    }

    func testCelciusToFahrenheitBoilingPoint() {
        var boilingPoint = Temperature(fromCelcius: 100.0)
        XCTAssert(boilingPoint.fahrenheit == 212.0, "Pass")
    }

    func testCelciusToFahrenheitFreezingPoint() {
        var freezingTemp = Temperature(fromCelcius: 0.0)
        XCTAssert(freezingTemp.fahrenheit == 32.0, "Pass")
    }
}
