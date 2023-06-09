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
    
    private func getSpectrum(arrData: [String]) {
        if (arrData.count == 0) {
            return
        }
        let data = arrData.joined(separator: "\n")
        let spectrum = Spectrum(data)
        self.spectra.append(spectrum)
    }
    
    private func readData() {
        var readingData = false
        var storeDataForReading: [String] = []
        for line in originData {
            if (line.hasPrefix("##")) {
                if (line.hasPrefix("##XYDATA=") || line.hasPrefix("##XYPOINTS=") || line.hasPrefix("##PEAK TABLE=") || line.hasPrefix("##PEAK ASSIGNMENTS=") || line.hasPrefix("##DATA TABLE=")) {
                    if (storeDataForReading.count > 0) {
                        self.getSpectrum(arrData: storeDataForReading)
                        storeDataForReading = []
                    }
                    readingData = true
                }
                else {
                    readingData = false
                    self.getSpectrum(arrData: storeDataForReading)
                    storeDataForReading = []
                    
                    //TODO: data label
                }
            }
            else if (!line.hasPrefix("$") && readingData) {
                storeDataForReading.append(line)
            }
            else {
                //TODO: add order
                readingData = false
                self.getSpectrum(arrData: storeDataForReading)
                storeDataForReading = []
            }
        }
    }
}
