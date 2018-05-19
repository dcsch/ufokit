//
//  GLIF2Tests.swift
//  UFOKitTests
//
//  Created by David Schweinsberg on 5/11/18.
//  Copyright © 2018 David Schweinsberg. All rights reserved.
//

import XCTest

class GLIF2Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTopElement() {
      glif = """
      <notglyph name="a" format="2">
        <outline>
        </outline>
      </notglyph>
      """
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
