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

    func testInit() {
        let testValue: Double = 14
        let alk = Alkalinity(testValue)
        XCTAssert(alk.dkh == testValue, "Pass")
    }
    
    func testMeqLProperty() {
        let alk = Alkalinity(14)
        XCTAssert(alk.meqL == 5, "Pass")
    }

    func testPPMProperty() {
        let alk = Alkalinity(14)
        XCTAssert(alk.ppt == 250, "Pass")
    }
    
    func testPPTInit() {
        let alk = Alkalinity(250, unit: .PPT)
        XCTAssert(alk.meqL == 5, "Pass")
    }

    func testMegLInit() {
        let alk = Alkalinity(5, unit: .MeqL)
        XCTAssert(alk.dkh == 14, "Pass")
    }
}
