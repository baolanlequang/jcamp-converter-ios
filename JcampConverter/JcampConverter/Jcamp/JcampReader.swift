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
            _ = self.reading(data: tmpData)
        }
        catch {
            print(error)
        }
    }
    
    private func reading(data: [String]) -> [String: Any] {
        
        var dataValues = [Int]()
        var isCompound = false  //check is compound
        var isInCompoundBlock = false //check is in compound block
        var storedCompondContents = [String]()
        var isStartReadData = false
        var jcampData: [String: Any] = [:]
        var arrX: [Float] = []
        var arrY: [Float] = []
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
                    //TODO: Process the entire block and put it into the children array.
                    var children = jcampData["children"] as? [[String:Any]] ?? [[String:Any]]()
                    children.append(reading(data: storedCompondContents))
                    isInCompoundBlock = false
                    storedCompondContents = []
                }
                continue
            }
            
            var dataType: Any?
            var dataList: [Any] = []
            if (trimmedLine.hasPrefix("##")) {
                trimmedLine = trimmedLine.replacingOccurrences(of: "##", with: "")
                print(trimmedLine)
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
                let newVal = "\(jcampData[trimmedKey!])\n\(trimmedLine)"
                jcampData[trimmedKey!] = newVal
            }
            
            if (isStartReadData) {
                if let type = dataType as? String {
                    if (type == "(X++(Y..Y))") {
                        
                    }
                }
                else {
                    
                }
            }
        }
        
        return jcampData
    }
    
    private func parsing(encodedString: String) -> [Int] {
        var result = [Int]()
        
        var trimedStr = encodedString.trimmingCharacters(in: .whitespaces)
        trimedStr = trimedStr.condenseWhitespace()
        
        let DUP_keys = DUP.keys
        let filteredDUP = trimedStr.filter { char in
            return DUP_keys.contains(String(char))
        }
        if (filteredDUP.count > 0) {
            var newLine = ""
            var dupVal = ""
            for (index, char) in trimedStr.enumerated() {
                if (DUP_keys.contains(String(char))) {
                    let prevChar = trimedStr[index-1]
                }
                else {
                    dupVal = ""
                    newLine.append(char)
                }
            }
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
