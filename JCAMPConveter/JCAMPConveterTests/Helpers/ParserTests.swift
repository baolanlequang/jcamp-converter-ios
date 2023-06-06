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
        let expected = (data: [987654321.25], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParseStringSeperateNumbersWithSpaces() throws {
        let strValue = "987654321.25 987654321    +10          -11"
        let expected = (data: [987654321.25, 987654321.0, 10.0, -11.0], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParseOnlyPACString() throws {
        let strValue = "1+10-11"
        let expected = (data: [1.0, 10, -11.0], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParsePACCombinedString() throws {
        let strValue = "1+10-11 987654321.25 987654321    +10          -11"
        let expected = (data: [1.0, 10, -11.0, 987654321.25, 987654321.0, 10.0, -11.0], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParseOnlySQZString() throws {
        let strValue = "1BCCBA@abc"
        let expected = (data: [1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -3.0], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParseDIFString() throws {
        let strValue = "1JJ%jjjjjj"
        let expected = (data: [1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -3.0], isDIF: true)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
    
    func testParseDIFDUPString() throws {
        let arrValue = ["1JT%jX", "56A28"]
        let arrExpected = [(data: [1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -3.0], isDIF: true), (data: [56.0, 128.0], isDIF: false)]
        
        for (idx, strValue) in arrValue.enumerated() {
            let parsedValue = parser.parse(strValue)
            let expected = arrExpected[idx]
            
            XCTAssertEqual(parsedValue.data, expected.data)
            XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
        }
    }
    
    func testParseDIFButNotEndString() throws {
        let strValue = "914320C58KJ0J3MQMNJ7NJ2nJ1K3qJ6J1J8NOKK7M1k1J1TJ2K5L5L2k8J1L4pJ7K5jJ3K8M7J9ML7"
        let expected = (data: [1.0], isDIF: false)
        
        let parsedValue = parser.parse(strValue)
        print(parsedValue.data)
        
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
}
