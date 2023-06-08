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
        let strValue = "4879C1556N0TN9SM9SN3SK9SL7SK9SK7SL7SJ2SJSJ0Sj5Sj3Sj7Sk9Sk6Sl0Sm7Sl8S"
        let expected = (data: [4879.0, 31556.0, 31606.0, 31656.0, 31715.0, 31764.0, 31817.0, 31846.0, 31883.0, 31912.0, 31939.0, 31976.0, 31988.0, 31989.0, 31999.0, 31984.0, 31971.0, 31954.0, 31925.0, 31899.0, 31869.0, 31822.0, 31784.0], isDIF: true)
        
        let parsedValue = parser.parse(strValue)
        
        XCTAssertEqual(parsedValue.data, expected.data)
        XCTAssertEqual(parsedValue.isDIF, expected.isDIF)
    }
}
