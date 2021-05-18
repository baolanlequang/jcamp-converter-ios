//
//  Utils.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 18/05/2021.
//

import Foundation

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    var isFloat: Bool {
        guard self.count > 0 else { return false }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        guard let floatVal = numberFormatter.number(from: self) else {
            return false
        }
        return true
    }
}
