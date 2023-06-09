//
//  Jcamp.swift
//  JCAMPConveter
//
//  Created by Lan Le on 09.06.23.
//

import Foundation

class Jcamp {
    
    lazy var spectra: [Spectrum] = []
    
    private lazy var originData: [String] = []
    
    init(_ stringData: String) {
        self.originData = stringData.components(separatedBy: .newlines)
        self.readData()
    }
    
    private func getSpectrum(arrData: [String], dataRecords: [String]) {
        if (arrData.count == 0) {
            return
        }
        
        var dicDataRecord: [String: String] = [:]
        for record in dataRecords {
            let values = record.components(separatedBy: "=")
            let label = values[0]
            
            dicDataRecord[label] = values.count > 1 ? values[1] : ""
        }
        
        let dataFormatValue = dicDataRecord["DATAFORMAT"]?.components(separatedBy: ",").first as? String ?? ""
        
        var firstXValue = 0.0, lastXValue = 0.0
        var factorXValue = 1.0, factorYValue = 1.0
        
        if var firstX = dicDataRecord["##FIRSTX"] {
            firstX = firstX.replacingOccurrences(of: " ", with: "")
            firstXValue = Double(firstX) ?? 0.0
        }
        
        if var lastX = dicDataRecord["##LASTX"] {
            lastX = lastX.replacingOccurrences(of: " ", with: "")
            lastXValue = Double(lastX) ?? 0.0
        }
        
        if var factorX = dicDataRecord["##XFACTOR"] {
            factorX = factorX.replacingOccurrences(of: " ", with: "")
            factorXValue = Double(factorX) ?? 0.0
        }
        
        if var factorY = dicDataRecord["##YFACTOR"] {
            factorY = factorY.replacingOccurrences(of: " ", with: "")
            factorYValue = Double(factorY) ?? 0.0
        }
        
        let data = arrData.joined(separator: "\n")
        let spectrum = Spectrum(data, dataFormat: dataFormatValue, factorX: factorXValue, factorY: factorYValue, firstX: firstXValue, lastX: lastXValue )
        self.spectra.append(spectrum)
    }
    
    private func readData() {
        var readingData = false
        var storeDataForReading: [String] = []
        var storeLabelDataRecords: [String] = []
        for line in originData {
            if (line.hasPrefix("##")) {
                if (line.hasPrefix("##XYDATA=") || line.hasPrefix("##XYPOINTS=") || line.hasPrefix("##PEAK TABLE=") || line.hasPrefix("##PEAK ASSIGNMENTS=") || line.hasPrefix("##DATA TABLE=")) {
                    
                    let seperatedLine = line.components(separatedBy: "=")
                    let dataFormatStr = "DATAFORMAT=\(seperatedLine[1])"
                    storeLabelDataRecords.append(dataFormatStr)
                    
                    if (storeDataForReading.count > 0) {
                        self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                        storeDataForReading = []
                    }
                    readingData = true
                }
                else {
                    readingData = false
                    self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                    
                    if (storeDataForReading.count > 0) {
                        storeLabelDataRecords = []
                    }
                    
                    storeDataForReading = []
                    
                    //TODO: data label
                    storeLabelDataRecords.append(line)
                }
            }
            else if (!line.hasPrefix("$") && readingData) {
                storeDataForReading.append(line)
            }
            else {
                //TODO: add order
                readingData = false
                self.getSpectrum(arrData: storeDataForReading, dataRecords: storeLabelDataRecords)
                
                if (storeDataForReading.count > 0) {
                    storeLabelDataRecords = []
                }
                
                storeDataForReading = []
                
                storeLabelDataRecords.append(line)
                
            }
        }
    }
}
