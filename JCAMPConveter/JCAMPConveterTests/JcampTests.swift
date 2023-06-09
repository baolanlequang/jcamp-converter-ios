//
//  JcampTests.swift
//  JCAMPConveterTests
//
//  Created by Lan Le on 09.06.23.
//

import XCTest
@testable import JCAMPConveter

final class JcampTests: XCTestCase {
    
    var jcamp: Jcamp? = nil
    let jcampStr = """
##TITLE=POLYETHYLENE
##XYDATA=(X++(Y..Y))
3200C1276%Sj05Sl3Sm2SJ44So5Sn7SJ8SK7Sq3SK3SO2Sj4SJ28SL0SM1SQ0SK7SM4S
3519C1501K3SJ0SQ2SL1Sk8SK2Sj8SMSK5SkSn4SJ2Sm0Sl9Sm2Sj8Sl4So0SJSk6Sk7S
##DATA TABLE= (XY..XY), PEAKS
50, 3.93; 51, 22.60; 52, 29.96; 53, 12.27; 54, 19.93; 55, 4.24
56, 3.64; 61, 3.55; 62, 5.12; 63, 14.49; 64, 2.36; 65, 4.70
66, 2.57; 68, 1.25; 76, 1.57; 77, 53.08; 78, 12.56; 79, 64.79
80, 30.92; 81, 4.33; 89, 20.26; 90, 24.82; 91, 9.30; 107, 91.80
108, 100.00; 109, 8.55
##END=
"""

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        jcamp = nil
    }
    
    func testInitJcampFromString() throws {
        jcamp = Jcamp(jcampStr)
        
        XCTAssertNotNil(jcamp)
        XCTAssertEqual(jcamp?.spectra.count, 2)
    }

}
