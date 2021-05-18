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
            _ = self.parsing(data: tmpData)
        }
        catch {
            print(error)
        }
    }
    
    private func parsing(data: [String]) -> [String: Any] {
        
        var isCompound = false  //check is compound
        var isInCompoundBlock = false //check is in compound block
        var storedCompondContents = [String]()
        var isStartReadData = false
        var jcampData: [String: Any] = [:]
        var arrX: [Float] = []
        var arrY: [Float] = []
        
        
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
                    children.append(parsing(data: storedCompondContents))
                    isInCompoundBlock = false
                    storedCompondContents = []
                }
                continue
            }
            
            var dataType = ""
            if (trimmedLine.hasPrefix("##")) {
                trimmedLine = trimmedLine.replacingOccurrences(of: "##", with: "")
                print(trimmedLine)
                let keyVal = trimmedLine.split(separator: "=")
                let key = keyVal[0]
                var val = ""
                if (keyVal.count > 1) {
                    val = String(keyVal[1])
                }
                let trimmedKey = key.trimmingCharacters(in: .whitespaces).lowercased()
                let trimmedVal = val.trimmingCharacters(in: .whitespaces)
//                print("key: \(key), val: \(val)")
//                print("trimmedKey: \(trimmedKey), trimmedVal: \(trimmedVal)")
                
                if (trimmedVal.isNumeric) {
                    jcampData[trimmedKey] = Int(trimmedVal)
                }
                else if (trimmedVal.isFloat) {
                    jcampData[trimmedKey] = Float(trimmedVal)
                }
                else {
                    jcampData[trimmedKey] = trimmedVal
                }
                
                //detect compound file
                let arrTitleDataType = ["data type", "datatype"]
                if (arrTitleDataType.contains(trimmedKey) && trimmedVal.lowercased() == "link") {
                    isCompound = true
                    jcampData["children"] = [[String:Any]]()
                }
                
                let arrTitlePoints = ["xydata", "xypoints", "peak table"]
                if (arrTitlePoints.contains(trimmedKey)) {
                    arrX = []
                    arrY = []
                    isStartReadData = true
                    dataType = trimmedVal
                    print("dataType: \(dataType)")
                }
            }
        }
        
        return jcampData
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
