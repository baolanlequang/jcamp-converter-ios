//
//  Jcamp.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 09/06/2021.
//

import Foundation

class Jcamp {
    var blockTitle = ""
    var dicData: [String:Any] = [:]
    var children: [Jcamp]? = nil
    
    private let arrTitleData = ["xydata", "peaktable", "peak table", "xypoints"]
    
    struct SpectraData {
        var xValues: [Double] = []
        var yValues: [Double] = []
    }
    
    var data: SpectraData?
    
    init() {}
    
    init(originData: [String]) {
        var childBlock: [String] = []
        var isReadingChildBlock = false
        var blockTitle = ""
        var isReadingData = false
        var dataFormat = ""
        var arrStartOfX: [Double] = []
        var arrNumberOfX: [Int] = []
        var arrX: [Double] = []
        var arrY: [Double] = []
        for line in originData {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine != "") {
                //ignore empty line
                if (trimmedLine.hasPrefix("$$")) {
                    isReadingChildBlock = true
                    blockTitle = trimmedLine
                    continue
                }
                else if (trimmedLine.hasPrefix("##END=") && blockTitle != "") {
                    isReadingChildBlock = false
                    if (self.children == nil) {
                        self.children = []
                    }
                    let jcampChild = Jcamp(originData: childBlock)
                    jcampChild.dicData["block_title"] = blockTitle
                    self.children?.append(jcampChild)
                    childBlock = []
                    blockTitle = ""
                    continue
                }
                
                if (isReadingChildBlock) {
                    childBlock.append(trimmedLine)
                }
                else {
                    if (trimmedLine.hasPrefix("##")) {
                        let clearLine = trimmedLine.replacingOccurrences(of: "##", with: "")
                        let arrKeysValues = clearLine.split(separator: "=")
                        let lhs = String(arrKeysValues[0]).lowercased()
                        var rhs = ""
                        if (arrKeysValues.count > 1) {
                            rhs = String(arrKeysValues[1])
                        }
        //                print("lhs: \(lhs), rhs: \(rhs)")
                        self.dicData[lhs] = rhs
                        if (arrTitleData.contains(lhs)) {
                            isReadingData = true
                            dataFormat = rhs.trimmingCharacters(in: .whitespaces)
                        }
                        else {
                            isReadingData = false
                            dataFormat = ""
                        }
                    }
                    else {
                        if (isReadingData) {
                            if (dataFormat == "(X++(Y..Y))") {
                                let dataValues = self.parsing(encodedString: trimmedLine)
        //                        print("datavalues: \(dataValues)")
                                arrStartOfX.append(dataValues[0])
                                arrNumberOfX.append(dataValues.count-1)
                                for i in 1..<dataValues.count {
                                    arrY.append(dataValues[i])
                                }
                            }
                            else if (dataFormat == "(XY..XY)") {
                                var dataValues = [Double]()
                                let clearLine = trimmedLine.replacingOccurrences(of: ";", with: ",").replacingOccurrences(of: " ", with: "")
                                let arrVals = clearLine.split(separator: ",")
                                for val in arrVals {
                                    if let dValue = Double(val) {
                                        dataValues.append(dValue)
                                    }
                                    else {
                                        continue
                                    }
                                }
                                for (index, val) in dataValues.enumerated() {
                                    if (index%2 == 0) {
                                        arrX.append(val)
                                    }
                                    else {
                                        arrY.append(val)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let lastx = self.dicData["lastx"] as? Double {
            arrStartOfX.append(lastx)
        }

        if (arrStartOfX.count > 0) {
            for index in 0..<arrStartOfX.count-1 {
                let lastX = arrStartOfX[index+1]
                let firstX = arrStartOfX[index]
                let npoints = arrNumberOfX[index]
                let deltaX = (lastX-firstX)/Double(npoints)
                for val in 0..<npoints {
                    let xValue = firstX + deltaX*Double(val)
                    arrX.append(xValue)
                }
            }
        }
        
        if let lastx = self.dicData["lastx"] as? Double {
            if let lastNumberX = arrNumberOfX.last, lastNumberX > 1, let lastStartX = arrStartOfX.last {
                let deltaX = (lastx - lastStartX) / (Double(lastNumberX)-1.0)
                for val in 0..<Int(lastNumberX) {
                    let tmp = lastStartX + deltaX*Double(val)
                    arrX.append(tmp)
                }
            }
            else {
                arrX.append(lastx)
            }
        }
        
        if let xfactor = self.dicData["xfactor"] as? Double {
            arrX.enumerated().forEach { index, value in
                arrX[index] = value * xfactor
            }
        }

        if let yfactor = self.dicData["yfactor"] as? Double {
            arrY.enumerated().forEach { index, value in
                arrY[index] = value * yfactor
            }
        }
        
        if (arrX.count > 0) {
            self.data = SpectraData(xValues: arrX, yValues: arrY)
        }
    }
    
    private func getValue(numStr: String, isDIF: Bool, values:[Double]) -> Double {
        let tmpNumber = Double(numStr) ?? 0.0
        var result = 0.0
        if (isDIF) {
            let lastValue = values.last ?? 0.0
            result = Double(lastValue + tmpNumber)
        }
        else {
            result = tmpNumber
        }
        return result
    }
    
    private func parsing(encodedString: String) -> [Double] {
        var result = [Double]()
        var numberStr = ""
        
        var trimedStr = encodedString.trimmingCharacters(in: .whitespaces)
        trimedStr = trimedStr.condenseWhitespace()
        
        let DUP_keys = DUP.keys
        let filteredDUP = trimedStr.filter { char in
            return DUP_keys.contains(String(char))
        }
        if (filteredDUP.count > 0) {
            var newLine = ""
            var dupVal = 0
            for (index, char) in trimedStr.enumerated() {
                if (DUP_keys.contains(String(char))) {
                    let prevChar = trimedStr[index-1]
                    dupVal = DUP[String(char)] ?? 0
                    if (dupVal > 0) {
                        let charsToAppend = String(repeating: prevChar, count: dupVal)
                        newLine.append(charsToAppend)
                    }
                }
                else {
                    dupVal = 0
                    newLine.append(char)
                }
            }
            trimedStr = newLine
        }
        
        var isDIF = false
        for char: Character in trimedStr {
            if ((char.isNumeric) || (char == ".")) {
                numberStr.append(char)
            }
            else if (char == " ") {
                isDIF = false
                if (numberStr != "") {
                    let val = self.getValue(numStr: numberStr, isDIF: isDIF, values: result)
                    result.append(val)
                }
                numberStr = ""
            }
            else if (SQZ.keys.contains(String(char))) {
                isDIF = false
                if (numberStr != "") {
                    let val = self.getValue(numStr: numberStr, isDIF: isDIF, values: result)
                    result.append(val)
                }
                numberStr = SQZ[String(char)] ?? ""
            }
            else if (DIF.keys.contains(String(char))) {
                isDIF = true
                if (numberStr != "") {
                    let val = self.getValue(numStr: numberStr, isDIF: isDIF, values: result)
                    result.append(val)
                }
                numberStr = DIF[String(char)] ?? ""
            }
            else {
                let error = String(format: "Unkwon character %@ when parsing", String(char))
//                assertionFailure(error)
                print(error)
            }
        }
        
        if (numberStr != "") {
            let val = self.getValue(numStr: numberStr, isDIF: isDIF, values: result)
            result.append(val)
        }
        
        return result
    }
}
