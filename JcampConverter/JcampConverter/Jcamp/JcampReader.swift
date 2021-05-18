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
            self.parsing(data: data)
        }
        catch {
            print(error)
        }
    }
    
    private func parsing(data: String) {
        
        var isCompound = false  //check is compound
        var isInCompoundBlock = false //check is in compound block
        var storedCompondContents = [String]()
        
        let tmpData = data.components(separatedBy: .newlines)
        for line in tmpData {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
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
//                    jcamp_dict['children'].append(jcamp_read(compound_block_contents))
                    isInCompoundBlock = false
                    storedCompondContents = []
                }
                continue
            }
        }
    }
}
