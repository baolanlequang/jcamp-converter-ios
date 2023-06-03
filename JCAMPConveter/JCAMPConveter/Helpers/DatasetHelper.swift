//
//  DatasetHelper.swift
//  JCAMPConveter
//
//  Created by Lan Le on 03.06.23.
//

import Foundation

class DatasetHelper {
    
    func isAFFN(_ value: String) -> Bool {
        if value == "" {
            return false
        }
        
        let regexPattern = #"^[+-]?(\d+(\.\d*)?|\.\d+)([Ee][+-]?\d+)?$"#

        do {
            let regex = try NSRegularExpression(pattern: regexPattern)
            let range = NSRange(location: 0, length: value.utf16.count)

            if let _ = regex.firstMatch(in: value, options: [], range: range) {
                return true
            }
        } catch {
//            print("Error creating regex: \(error)")
        }
        return false
    }
}
