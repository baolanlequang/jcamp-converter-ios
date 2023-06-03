//
//  DatasetHelperTests.swift
//  JCAMPConveterTests
//
//  Created by Lan Le on 03.06.23.
//

import XCTest
@testable import JCAMPConveter

final class DatasetHelperTests: XCTestCase {
    
    var datasetHelper: DatasetHelper?

    override func setUpWithError() throws {
        datasetHelper = DatasetHelper()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        datasetHelper = nil
    }
    
    func testIsAFFN() throws {
        let arrValues = ["1", "19", "999", "+10", "-10", ".10", "+.10", "-.10", "1e2", "1E234", "+1.0"]
        for value in arrValues {
            let isAFFN = datasetHelper!.isAFFN(value)
            
            XCTAssertTrue(isAFFN)
        }
    }
    
    func testIsNotAFFN() throws {
        let arrValues = ["", "@19", "9#99", "-10?", "@.10", "-.1.00", "1E2E34"]
        for value in arrValues {
            let isAFFN = datasetHelper!.isAFFN(value)
            
            XCTAssertFalse(isAFFN)
        }
    }

}
