//
//  SalinityStruct.swift
//  Reef Journal
//
//  Created by Christopher Harding on 7/12/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import XCTest
@testable import Reef_Journal

class Salinity_Struct: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSGInit() {
        let sal = Salinity(1.0264)
        XCTAssert(sal.sg == 1.0264, "Pass")
    }

    func testPSUInit() {
        let sal = Salinity(35, unit: .PSU)
        XCTAssert(sal.psu == 35, "Pass")
    }

    func testSGProperty() {
        let sal = Salinity(35, unit: .PSU)
        XCTAssert(sal.sg == 1.0264, "Pass")
    }
    
    func testPSUProperty() {
        let sal = Salinity(1.0264, unit: .SG)
        XCTAssert(sal.psu == 35, "Pass")
    }

    func testConversion38() {
        let sal = Salinity(38, unit: .PSU)
        XCTAssert(sal.sg == 1.0286, "Pass")
    }

    func testConversion37() {
        let sal = Salinity(37, unit: .PSU)
        XCTAssert(sal.sg == 1.0279, "Pass")
    }

    func testConversion36() {
        let sal = Salinity(36, unit: .PSU)
        XCTAssert(sal.sg == 1.0271, "Pass")
    }

    func testConversion35() {
        let sal = Salinity(35, unit: .PSU)
        XCTAssert(sal.sg == 1.0264, "Pass")
    }

    func testConversion34() {
        let sal = Salinity(34, unit: .PSU)
        XCTAssert(sal.sg == 1.0256, "Pass")
    }

    func testConversion33() {
        let sal = Salinity(33, unit: .PSU)
        XCTAssert(sal.sg == 1.0249, "Pass")
    }

    func testConversion32() {
        let sal = Salinity(32, unit: .PSU)
        XCTAssert(sal.sg == 1.0241, "Pass")
    }


}
