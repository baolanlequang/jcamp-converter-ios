//
//  ViewController.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 18/05/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let path = Bundle.main.path(forResource: "1h", ofType: "jdx") {
            let reader = JcampReader(filePath: path)
            if let jcamp = reader.jcamp {
                if let children = jcamp.children {
                    for (index, child) in children.enumerated() {
                        if let data = child.data {
                            print("child data x: \(data.xValues.count), index: \(index)")
                            print("child data y: \(data.yValues.count), index: \(index)")
                        }
                    }
                }
            }
            else {
                print("no jcamp")
            }
        }
    }


}

