//
//  TransvectorTests.swift
//  TransvectorTests
//
//  Created by Kevin Wong on 4/5/16.
//  Copyright © 2016 Kevin Wong. All rights reserved.
//

import XCTest
@testable import Transvector

class TransvectorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let parser = SVGParser()
        parser.parseFileWithName(filename: "testPath") { graphic in
            print(graphic?.paths.first?.path ?? "")
        }
    }
}
