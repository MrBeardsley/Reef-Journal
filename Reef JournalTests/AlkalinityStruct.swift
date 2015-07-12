//
//  AlkalinityStruct.swift
//  Reef Journal
//
//  Created by Christopher Harding on 10/4/14.
//  Copyright (c) 2014 Epic Kiwi Interactive. All rights reserved.
//

import XCTest
@testable import Reef_Journal

class Alkalinity_Struct: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDKHInit() {
        let testValue: Double = 10.0
        let alk = Alkalinity(testValue, unit: .DKH)
        XCTAssert(alk.dkh == testValue, "Pass")
    }
    
    func testDKHProperty() {
        let testValue = 9.3
        var alk = Alkalinity(15)
        alk.dkh = testValue
        XCTAssert(alk.dkh == testValue, "Pass")
    }
    
    func testMeqLInit() {
        let testValue = 4.2
        let alk = Alkalinity(testValue, unit: .MeqL)
        XCTAssert(alk.meqL == testValue, "Pass")
    }

    func testMeqLProperty() {
        let testValue = 4.2
        let alk = Alkalinity(testValue, unit: .MeqL)
        XCTAssert(alk.meqL == testValue, "Pass")
    }
    
//    func testPPTInit() {
//        let alk = 134.0
//        var measurement = Alkalinity(fromPPT: alk)
//        XCTAssert(measurement.ppt == alk, "Pass")
//    }
    
    
}
