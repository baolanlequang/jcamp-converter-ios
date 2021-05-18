//
//  JcampBackup.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 09/06/2021.
//

import Foundation

class JcampBackup {
    var blockTitle = ""
    var dicData: [String:Any] = [:]
    var children: [JcampBackup]? = nil
    
    private let arrTitleData = ["xydata", "peaktable", "peak table", "xypoints", "data table"]
    
    struct SpectraData {
        var title: String = ""
        var xValues: [Double] = []
        var yValues: [Double] = []
    }
    
    var data: [SpectraData]?
    
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
        var arrDataFormat: [String:[String]] = ["type_1": [], "type_2": []]
        
        for line in originData {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if (trimmedLine != "") {
                //ignore empty line
                if (trimmedLine.hasPrefix("##TITLE=")) {
                    isReadingChildBlock = true
                    blockTitle = trimmedLine
                    continue
                }
                else if (trimmedLine.hasPrefix("##END=") && blockTitle != "") {
                    isReadingChildBlock = false
                    if (self.children == nil) {
                        self.children = []
                    }
                    let jcampChild = JcampBackup(originData: childBlock)
                    jcampChild.dicData["block_title"] = blockTitle
                    self.children?.append(jcampChild)
                    childBlock = []
                    blockTitle = ""
                    continue
                }
                else if (trimmedLine.hasPrefix("$$")) {
                    //this just a comment line
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
//                        print("lhs: \(lhs), rhs: \(rhs)")
                        self.dicData[lhs] = rhs.trimmingCharacters(in: .whitespaces)
                        if (arrTitleData.contains(lhs)) {
                            isReadingData = true
                            dataFormat = rhs.trimmingCharacters(in: .whitespaces)
                            if let symBolStr = self.dicData["symbol"] as? String {
                                let arrSymBol = symBolStr.components(separatedBy: ",")
                                var firstVar = ""
                                for (index,symbolStr) in arrSymBol.enumerated() {
                                    if (index == 0) {
                                        firstVar = symbolStr.trimmingCharacters(in: .whitespacesAndNewlines)
                                    }
                                    else {
                                        //TODO: need to check multiple data in each block
                                        let secondVar = symbolStr.trimmingCharacters(in: .whitespacesAndNewlines)
                                        let type1 = "(\(firstVar)++(\(secondVar)..\(secondVar))"
                                        let type2 = "(\(firstVar)\(secondVar)..\(firstVar)\(secondVar))"
                                        arrDataFormat["type_1"]?.append(type1)
                                        arrDataFormat["type_2"]?.append(type2)
                                    }
                                }
                                dataFormat = rhs
                            }
                           
                        }
                        else {
                            isReadingData = false
                            dataFormat = ""
                            arrDataFormat = ["type_1": [], "type_2": []]
                            
                            //TODO: test
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
                            
                            if let lastx = self.dicData["lastx"] as? String, let lastXValue = Double(lastx) {
                                let lastIndex = arrStartOfX.count-1
                                if (lastIndex >= 0) {
                                    let firstX = arrStartOfX[lastIndex]
                                    if (firstX > 1) {
                                        let npoints = arrNumberOfX[lastIndex]
                                        let deltaX = (lastXValue-firstX)/Double(npoints)
                                        for val in 0..<npoints {
                                            let xValue = firstX + deltaX*Double(val)
                                            arrX.append(xValue)
                                        }
                                    }
                                    else {
                                        arrX.append(lastXValue)
                                    }
                                }
                            }
                            
                            if let xfactor = self.dicData["xfactor"] as? String, let xfactorValue = Double(xfactor) {
                                arrX.enumerated().forEach { index, value in
                                    arrX[index] = value * xfactorValue
                                }
                            }

                            if let yfactor = self.dicData["yfactor"] as? String, let yfactorValue = Double(yfactor) {
                                arrY.enumerated().forEach { index, value in
                                    arrY[index] = value * yfactorValue
                                }
                            }
                            
                            if (arrX.count > 0 && arrX.count == arrY.count) {
                                if (self.data == nil) {
                                    self.data = []
                                }
                                self.data?.append(SpectraData(xValues: arrX, yValues: arrY))
                    //            self.data = SpectraData(xValues: arrX, yValues: arrY)
                            }
                            else {
//                                print("arrx: \(arrX.count), arry: \(arrY.count)")
                                if (arrX.count > 0) {
                                    print("arrx: \(arrX.count), arry: \(arrY.count)")
                                }
                            }
                            //endtest
                        }
                    }
                    else {
                        if (isReadingData) {
//                            print("dataFormat: \(dataFormat)")
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
                            else if (arrDataFormat.count > 0) {
//                                print("arrDataFormat: \(arrDataFormat)")
                                if let type1 = arrDataFormat["type_1"] {
                                    let filter = type1.filter { type in
                                        return dataFormat.contains(type)
                                    }
                                    if (filter.count > 0) {
                                        let dataValues = self.parsing(encodedString: trimmedLine)
//                                        print("dataValues: \(dataValues)")
                                        arrStartOfX.append(dataValues[0])
                                        arrNumberOfX.append(dataValues.count-1)
                                        for i in 1..<dataValues.count {
                                            arrY.append(dataValues[i])
                                        }
//                                        print("arry: \(arrY.count)")
                                    }
                                }
                                else if let type2 = arrDataFormat["type_2"] {
                                    let filter = type2.filter { type in
                                        return dataFormat.contains(type)
                                    }
                                    if (filter.count > 0) {
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
            }
        }
        
        
        
        if let lastx = self.dicData["lastx"] as? Double {
            arrStartOfX.append(lastx)
        }

//        if (arrStartOfX.count > 0) {
//            for index in 0..<arrStartOfX.count-1 {
//                let lastX = arrStartOfX[index+1]
//                let firstX = arrStartOfX[index]
//                let npoints = arrNumberOfX[index]
//                let deltaX = (lastX-firstX)/Double(npoints)
//                for val in 0..<npoints {
//                    let xValue = firstX + deltaX*Double(val)
//                    arrX.append(xValue)
//                }
//            }
//        }
//
//        if let lastx = self.dicData["lastx"] as? String, let lastXValue = Double(lastx) {
//            let lastIndex = arrStartOfX.count-1
//            if (lastIndex >= 0) {
//                let firstX = arrStartOfX[lastIndex]
//                if (firstX > 1) {
//                    let npoints = arrNumberOfX[lastIndex]
//                    let deltaX = (lastXValue-firstX)/Double(npoints)
//                    for val in 0..<npoints {
//                        let xValue = firstX + deltaX*Double(val)
//                        arrX.append(xValue)
//                    }
//                }
//                else {
//                    arrX.append(lastXValue)
//                }
//            }
//        }
//
//        if let xfactor = self.dicData["xfactor"] as? String, let xfactorValue = Double(xfactor) {
//            arrX.enumerated().forEach { index, value in
//                arrX[index] = value * xfactorValue
//            }
//        }
//
//        if let yfactor = self.dicData["yfactor"] as? String, let yfactorValue = Double(yfactor) {
//            arrY.enumerated().forEach { index, value in
//                arrY[index] = value * yfactorValue
//            }
//        }
//
//        if (arrX.count > 0) {
//            if (self.data == nil) {
//                self.data = []
//            }
//            self.data?.append(SpectraData(xValues: arrX, yValues: arrY))
////            self.data = SpectraData(xValues: arrX, yValues: arrY)
//        }
    }
    
    private func scanner(encodedString: String) -> [String] {
        var result = [String]()
        var tmpStr = ""
        for char in encodedString {
            if (char.isNumeric || char == ".") {
                tmpStr.append(char)
            }
            else {
                if (tmpStr != "") {
                    result.append(tmpStr)
                    tmpStr = ""
                }
                
                let charString = String(char)
                if let sqzValue = SQZ[charString] {
                    //SQZ form
                    tmpStr.append(sqzValue)
                }
                else {
                    //DIF form
                    tmpStr.append(char)
                }
            }
        }
        if (tmpStr != "") {
            result.append(tmpStr)
            tmpStr = ""
        }
        return result
    }
    
    private func getDIFValue(dif: Double, prev: Double = 0) -> Double {
        return prev + dif
    }
    
    private func parsing(encodedString: String) -> [Double] {
        var result = [Double]()
        
        let scannedResult = self.scanner(encodedString: encodedString)
        for value in scannedResult {
            if (value.isDouble) {
                let doubleVal = Double(value) ?? 0.0
                result.append(doubleVal)
            }
            else {
                //DIF value
                let firstChar = value[0]
                if let intFirst = DIF[firstChar] {
                    let difValStr = "\(intFirst)\(value.substring(fromIndex: 1))"
                    let difVal = Double(difValStr) ?? 0.0
                    var doubleVal = 0.0
                    if (result.count > 0) {
                        let prev = result[result.count-1]
                        doubleVal = self.getDIFValue(dif: difVal, prev: prev)
                    }
                    else {
                        doubleVal = self.getDIFValue(dif: difVal)
                    }
                    result.append(doubleVal)
                }
            }
        }
        
        return result
    }
}
