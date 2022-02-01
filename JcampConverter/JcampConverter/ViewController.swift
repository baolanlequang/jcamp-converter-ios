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
        
        if let path = Bundle.main.path(forResource: "test_file_19", ofType: "dx") {
            let reader = JcampReader(filePath: path)
        }
        else {
            print("file not found")
        }
        
    }
}

