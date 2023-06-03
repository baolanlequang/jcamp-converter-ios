//
//  ParserTests.swift
//  JCAMPConveterTests
//
//  Created by Lan Le on 03.06.23.
//

import XCTest
@testable import JCAMPConveter

final class ParserTests: XCTestCase {
    
    var parser: Parser!

    override func setUpWithError() throws {
        parser = Parser()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseStringOfNumber() throws {
        let strValue = "987654321.25"
        let expected = [987654321.25]
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue, expected)
    }
    
    func testParseStringSeperateNumbersWithSpaces() throws {
        let strValue = "987654321.25 987654321    +10          -11"
        let expected = [987654321.25, 987654321.0, 10.0, -11.0]
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue, expected)
    }
    
    func testParseOnlyPACString() throws {
        let strValue = "1+10-11"
        let expected = [1.0, 10, -11.0]
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue, expected)
    }

}
