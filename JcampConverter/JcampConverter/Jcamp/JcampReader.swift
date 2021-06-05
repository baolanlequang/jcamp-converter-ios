//
//  JcampReader.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 18/05/2021.
//

import Foundation

class JcampReader {
    init() {}
    
    init(filePath: String) {
        do {
            let data = try String(contentsOfFile: filePath, encoding: .utf8)
            let tmpData = data.components(separatedBy: .newlines)
            let arrData = self.reading(data: tmpData)
            print("arrData: \(arrData)")
//            self.parsing(encodedString: "12T")
        }
        catch {
            print(error)
        }
    }
    
    private func reading(data: [String]) -> [String: Any] {
        
        var dataValues = [Double]()
        var isCompound = false  //check is compound
        var isInCompoundBlock = false //check is in compound block
        var storedCompondContents = [String]()
        var isStartReadData = false
        var jcampData: [String: Any] = [:]
        var arrX: [Double] = []
        var arrY: [Double] = []
        var arrStartOfX: [Double] = []
        var arrNumberOfX: [Double] = []
        var trimmedKey: String? = nil
        
        for line in data {
            var trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine == "") {
                //ignore empty line
                continue
            }
            if (trimmedLine.hasPrefix("$$")) {
                //ignore line start with $$
                continue
            }
            
//            print("line: \(trimmedLine)")
            
            //detect start of compound block
            if (isCompound && trimmedLine.uppercased().hasPrefix("##TITLE")) {
                isInCompoundBlock = true
                storedCompondContents = [trimmedLine]
                continue
            }
           
            //recursive call this this function if reading compound contents
            if (isInCompoundBlock) {
                storedCompondContents.append(trimmedLine)
                
                //detect end of compound block
                if (trimmedLine.uppercased().hasPrefix("##END")) {
                    var children = jcampData["children"] as? [[String:Any]] ?? [[String:Any]]()
                    children.append(reading(data: storedCompondContents))
                    isInCompoundBlock = false
                    storedCompondContents = []
                    jcampData["children"] = children
                }
                continue
            }
            
            var dataType: Any?
            var dataList: [Double] = []
            if (trimmedLine.hasPrefix("##")) {
                trimmedLine = trimmedLine.replacingOccurrences(of: "##", with: "")
//                print(trimmedLine)
                let keyVal = trimmedLine.split(separator: "=")
                let key = keyVal[0]
                var val = ""
                if (keyVal.count > 1) {
                    val = String(keyVal[1])
                }
                trimmedKey = key.trimmingCharacters(in: .whitespaces).lowercased()
                let trimmedVal = val.trimmingCharacters(in: .whitespaces)
                
                if (trimmedVal.isNumeric) {
                    jcampData[trimmedKey!] = Int(trimmedVal)
                }
                else if (trimmedVal.isFloat) {
                    jcampData[trimmedKey!] = Float(trimmedVal)
                }
                else {
                    jcampData[trimmedKey!] = trimmedVal
                }
                
                //detect compound file
                let arrTitleDataType = ["data type", "datatype"]
                if (arrTitleDataType.contains(trimmedKey!) && trimmedVal.lowercased() == "link") {
                    isCompound = true
                    jcampData["children"] = [[String:Any]]()
                }
                
                let arrTitlePoints = ["xydata", "xypoints", "peak table"]
                if (arrTitlePoints.contains(trimmedKey!)) {
                    arrX = []
                    arrY = []
                    isStartReadData = true
                    dataType = trimmedVal
                    continue
                }
                else if (trimmedKey == "end") {
                    isStartReadData = true
                    dataType = trimmedVal.arrayNumbers
                    dataList = []
                    continue
                }
                else if (isStartReadData) {
                    isStartReadData = false
                }
            }
            else if (trimmedKey != nil && !isStartReadData) {
                if let oldVal = jcampData[trimmedKey!] as? String {
                    let newVal = "\(oldVal)\n\(trimmedLine)"
                    jcampData[trimmedKey!] = newVal
                }
                
            }
            
            if (isStartReadData) {
                if let type = dataType as? String {
                    if (type == "(X++(Y..Y))") {
                        dataValues = self.parsing(encodedString: trimmedLine)
                        arrStartOfX.append(dataValues[0])
                        arrNumberOfX.append(Double(dataValues.count-1))
                        for i in 1..<dataValues.count {
                            let val = dataValues[i]
                            arrY.append(val)
                        }
                    }
                    else if ((jcampData.keys.contains("xypoints") || (jcampData.keys.contains("xydata"))) && type == "(XY..XY)") {
                        let tmpArr = trimmedLine.ranges(of: "[,;\\s]", options: .regularExpression).map { trimmedLine[$0].trimmingCharacters(in: .whitespaces) }
                        for val in tmpArr {
                            if let val = Double(val) {
                                dataValues.append(val)
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
                    else if ((jcampData.keys.contains("peak table") || jcampData.keys.contains("peaktable")) && type == "(XY..XY)") {
                        let tmpArr = trimmedLine.ranges(of: "[,;\\s]", options: .regularExpression).map { trimmedLine[$0].trimmingCharacters(in: .whitespaces) }
                        for val in tmpArr {
                            if let val = Double(val) {
                                dataValues.append(val)
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
                    else if (dataType is Array<Any>) {
                        dataValues = self.parsing(encodedString: trimmedLine)
                        dataList.append(contentsOf: dataValues)
                    }
                }
            }
        }
        
        if let xydata = jcampData["xydata"] as? String, xydata == "(X++(Y..Y))" {
            if let lastx = jcampData["lastx"] as? Double {
                arrStartOfX.append(lastx)
            }
            
            arrX = []
            
            if (arrNumberOfX.count > 0) {
                for number in 0..<(arrNumberOfX.count-1) {
                    let deltaX = (arrStartOfX[number+1] - arrStartOfX[number]) / arrNumberOfX[number]
                    for val in 0..<Int(arrNumberOfX[number]) {
                        let tmp = arrStartOfX[number] + deltaX*Double(val)
                        arrX.append(tmp)
                    }
                }
            }
            
            
            if let lastx = jcampData["lastx"] as? Double {
                if let lastNumberX = arrNumberOfX.last, lastNumberX > 1, let lastStartX = arrStartOfX.last {
                    let deltaX = (lastx - lastStartX) / (lastNumberX-1.0)
                    for val in 0..<Int(lastNumberX) {
                        let tmp = lastStartX + deltaX*Double(val)
                        arrX.append(tmp)
                    }
                }
                else {
                    arrX.append(lastx)
                }
            }
        }
        
        if let xfactor = jcampData["xfactor"] as? Double {
            arrX.enumerated().forEach { index, value in
                arrX[index] = value * xfactor
            }
        }
        
        if let yfactor = jcampData["yfactor"] as? Double {
            arrY.enumerated().forEach { index, value in
                arrY[index] = value * yfactor
            }
        }
        jcampData["x"] = arrX
        jcampData["y"] = arrY
        
        return jcampData
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
                let error = String(format: "Unkwon character %s when parsing", String(char))
                assertionFailure(error)
            }
        }
        
        if (numberStr != "") {
            let val = self.getValue(numStr: numberStr, isDIF: isDIF, values: result)
            result.append(val)
        }
        
        return result
    }
    
    private func checkIsFloat(arrString: [String]) -> [Bool] {
        //check list strings can convert to a float
        var result: [Bool] = []
        for str in arrString {
            let isFloat = str.isFloat
            result.append(isFloat)
        }
        return result
    }
}
