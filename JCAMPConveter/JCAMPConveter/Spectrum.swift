//
//  JCamp.swift
//  JCAMPConveter
//
//  Created by Lan Le on 05.06.23.
//

import Foundation

class Spectrum {
    private var dataString: String!
    
    private var parser: Parser!
    
    private var listX: [[Double]] = []
    private var listY: [[Double]] = []
    private var factorX: Double
    private var factorY: Double
    
    init(_ data: String, factorX: Double = 1.0, factorY: Double = 1.0) {
        self.dataString = data
        self.parser = Parser()
        self.factorX = factorX
        self.factorY = factorY
        
        self.parseData()
    }
    
    private func parseData() {
        var arrStartX: [Double] = []
        
        let dataLines = self.dataString.components(separatedBy: .newlines)
        
        var nPoints = 0.0
        var isSkipCheckPoint = false
        for (lineIdx, line) in dataLines.enumerated() {
            let parsedLine = self.parser.parse(line)
            let parsedData = parsedLine.data
            let parsedDataCount = parsedData.count
            print(line)
//            print(parsedData)
            if (parsedDataCount > 1) {
                arrStartX.append(parsedData[0])
                if (!isSkipCheckPoint) {
                    let arrY = Array(parsedData[1..<parsedDataCount])
                    self.listY.append(arrY)
                    print(parsedData.count)
                    nPoints += Double(arrY.count)
                }
                else {
                    var prevArrY = self.listY[lineIdx-1]
                    prevArrY.removeLast()
                    self.listY[lineIdx-1] = prevArrY
                    let arrY = Array(parsedData[2..<parsedDataCount])
                    self.listY.append(arrY)
                    nPoints += Double(arrY.count) - 1
                }
                
//                if (!isSkipCheckPoint || (isSkipCheckPoint && !parsedLine.isDIF)) {
//                    let arrY = Array(parsedData[1..<parsedDataCount])
//                    self.listY.append(arrY)
//                    nPoints += Double(arrY.count)
//                }
//                else {
//                    var prevArrY = self.listY[lineIdx-1]
//                    prevArrY.removeLast()
//                    self.listY[lineIdx-1] = prevArrY
//                    let arrY = Array(parsedData[2..<parsedDataCount])
//                    self.listY.append(arrY)
//                    nPoints += Double(arrY.count) - 1
//                }
                print("parsedLine.isDIF: \(parsedLine.isDIF)")
                print("isSkipCheckPoint: \(isSkipCheckPoint)")
                
                isSkipCheckPoint = parsedLine.isDIF
            }
        }
        
        let firstX = arrStartX[0], lastX = arrStartX[arrStartX.count-1]
//        let firstX = 4.0, lastX = 56.0
        let deltaX = (lastX - firstX) / (nPoints - 1)
        
        for (idx, startX) in arrStartX.enumerated() {
            var realXValue = startX * self.factorX
            var arrX: [Double] = [realXValue]
            let arrY = self.listY[idx]
            let arrCount = arrY.count
            if (arrCount > 2) {
                for _ in 1..<arrY.count {
                    realXValue += deltaX
                    let xValue = startX * self.factorX + deltaX
                    arrX.append(realXValue)
                }
            }
            
            
            self.listX.append(arrX)
            
        }
        print("npoiint: \(nPoints)")
        print("arrStartX: \(arrStartX)")
        print("listY: \(self.listY.last)")
        print("firstX: \(firstX)")
        print("lastX: \(lastX)")
        print("delta: \(deltaX)")
    }
    
    func getListX() -> [Double] {
        var result: [Double] = []
        for line in self.listX {
            for xValue in line {
//                let realXValue = xValue * self.factorX
                result.append(xValue)
            }
        }
        print(result)
        return result
    }
}
