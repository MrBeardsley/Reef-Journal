//
//  Reef_JournalTests.swift
//  Reef JournalTests
//
//  Created by Christopher Harding on 6/10/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import XCTest
@testable import Reef_Journal

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
        var temp = Temperature(testValue)
        XCTAssert(temp.fahrenheit == testValue, "Pass")
    }
    
    func testFahrenheitProperty() {
        let testValue = 75.3
        var temp = Temperature(50.0)
        temp.fahrenheit = testValue
        XCTAssert(temp.fahrenheit == testValue, "Pass")
    }
    
    func testFahrenheitToCelciusBoilingPoint() {
        let boilingPoint = Temperature(212.0)
        XCTAssert(boilingPoint.celcius == 100.0, "Pass")
    }

    func testFahrenheitToCelciusFreezingPoint() {
        let freezingTemp = Temperature(32.0)
        XCTAssert(freezingTemp.celcius == 0.0, "Pass")
    }
    
    func testCelciusInit() {
        let testValue = 98.6
        let temp = Temperature(testValue, unit: .Celcius)
        XCTAssert(temp.celcius == testValue, "Pass")
    }
    
    func testCelciusProperty() {
        let testValue = 75.3
        var temp = Temperature(50.0, unit: .Celcius)
        temp.celcius = testValue
        XCTAssert(temp.celcius == testValue, "Pass")
    }

    func testCelciusToFahrenheitBoilingPoint() {
        var boilingPoint = Temperature(100.0, unit: .Celcius)
        XCTAssert(boilingPoint.fahrenheit == 212.0, "Pass")
    }

    func testCelciusToFahrenheitFreezingPoint() {
        var freezingTemp = Temperature(0.0, unit: .Celcius)
        XCTAssert(freezingTemp.fahrenheit == 32.0, "Pass")
    }
}
