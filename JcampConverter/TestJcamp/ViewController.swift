//
//  ViewController.swift
//  TestJcamp
//
//  Created by Lan Le on 02.02.22.
//

import UIKit
import JcampConverter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "File012", ofType: "dx") {
            let reader = JcampReader(filePath: path)
            for spec in reader.jcamp!.spectra {
                print(spec.xValues.count)
            }
        }
        else {
            print("file not found")
        }
    }


}

