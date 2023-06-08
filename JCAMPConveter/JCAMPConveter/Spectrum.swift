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
    
    private var listX: [[Double]] = [], listY: [[Double]] = []
    private var factorX: Double, factorY: Double
    private var firstX: Double, lastX: Double
    
    
    init(_ data: String, factorX: Double = 1.0, factorY: Double = 1.0, firstX: Double = 0.0, lastX: Double = 0.0) {
        self.dataString = data
        self.parser = Parser()
        self.factorX = factorX
        self.factorY = factorY
        self.firstX = firstX
        self.lastX = lastX
        
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
            if (parsedDataCount > 1) {
                arrStartX.append(parsedData[0])
                var arrY: [Double] = []
                if (!isSkipCheckPoint) {
                    arrY = Array(parsedData[1..<parsedDataCount])
                }
                else {
                    var prevLine = self.listY[lineIdx - 1]
                    prevLine.removeLast()
                    self.listY[lineIdx-1] = prevLine
                    nPoints -= 1
                    arrY = Array(parsedData[1..<parsedDataCount])
                }
                
                self.listY.append(arrY)
                nPoints += Double(arrY.count)
                
                isSkipCheckPoint = parsedLine.isDIF
            }
        }
        
        let deltaX = (self.lastX - self.firstX) / (nPoints - 1)

        for (idx, startX) in arrStartX.enumerated() {
            var realXValue = startX * self.factorX
            var arrX: [Double] = [realXValue]
            let arrY = self.listY[idx]
            let arrCount = arrY.count
            if (arrCount > 2) {
                for _ in 1..<arrY.count {
                    realXValue += deltaX
                    arrX.append(realXValue)
                }
            }

            self.listX.append(arrX)

        }
    }
    
    func getListX() -> [Double] {
        var result: [Double] = []
        for line in self.listX {
            for xValue in line {
                result.append(xValue)
            }
        }
        return result
    }
    
    func getListY() -> [Double] {
        var result: [Double] = []
        for line in self.listY {
            for yValue in line {
                let realY = yValue * self.factorY
                result.append(realY)
            }
        }
        return result
    }
}
