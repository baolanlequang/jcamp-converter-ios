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
    
    private func getNumber(_ value: String, _ isDIF: Bool = false) -> Double? {
        if let doubleNumber = Double(value) {
            return doubleNumber
        }
        
        var convertedStr = ""
        if (!isDIF) {
            convertedStr = datasetHelper.convertSQZ(value)
        }
        else {
            convertedStr = datasetHelper.convertDIF(value)
        }
        
        if let doubleNumber = Double(convertedStr) {
            return doubleNumber
        }
        
        return nil
    }
    
    func parse(_ value: String) -> (data: [Double], isDIF: Bool) {
        if let doubleValue = Double(value) {
            return (data: [doubleValue], isDIF: false)
        }
        
        var result: [Double] = []
        
        let arrSplitted = datasetHelper.splitString(value)
        if (arrSplitted.count > 1) {
            for item in arrSplitted {
                if let number = getNumber(item) {
                    result.append(number)
                }
            }
            return (data: result, isDIF: false)
        }
        
        let dataCompressedStr = arrSplitted[0]
        
        var numberStr = ""
        
        let removedDUP = datasetHelper.convertDUP(dataCompressedStr)
        
        var isDIF = false
        var lastChar = ""
        for char in removedDUP {
            let charString = String(char)
            lastChar = charString
            if (char.isNumber || char == ".") {
                numberStr.append(char)
            }
            else if let dupVal = SQZ[charString] {
                isDIF = false
                if let number = getNumber(numberStr, isDIF) {
                    result.append(number)
                }
                numberStr = dupVal
            }
            else if let _ = DIF[charString] {
                if let number = getNumber(numberStr, isDIF) {
                    result.append(number)
                    numberStr = String(number) + charString
                }
                
                isDIF = true
               
            }
        }
        
        if let number = getNumber(numberStr, isDIF) {
            result.append(number)
        }
        
        let checkDIF = DIF[lastChar] != nil
        return (data: result, isDIF: checkDIF)
    }
}
