//
//  Parser.swift
//  JCAMPConveter
//
//  Created by Lan Le on 03.06.23.
//

import Foundation

class Parser {
    
    private var datasetHelper: DatasetHelper!
    
    init() {
        datasetHelper = DatasetHelper()
    }
    
    private func getNumber(_ value: String) -> Double? {
        return Double(value)
    }
    
    func parse(_ value: String) -> [Double] {
        if let doubleValue = Double(value) {
            return [doubleValue]
        }
        
        var result: [Double] = []
        
        let arrSplitted = datasetHelper.splitString(value)
        if arrSplitted.count > 0 {
            for item in arrSplitted {
                if let number = getNumber(item) {
                    result.append(number)
                }
            }
        }
        
        return result
    }
}
