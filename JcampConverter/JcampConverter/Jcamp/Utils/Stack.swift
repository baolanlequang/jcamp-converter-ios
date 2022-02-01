//
//  Stack.swift
//  JcampConverter
//
//  Created by Bao Lan Le Quang on 21/10/2021.
//

import Foundation

protocol Stack {
    associatedtype Element
    
    mutating func push(item: Element)
    
    mutating func pop() -> Element?
    
    func peak() -> Element?
    
    var count: Int { get }
}

extension Array: Stack {
    
    mutating func push(item: Element) {
        self.append(item)
    }
    
    mutating func pop() -> Element? {
        if let last = self.last {
            self.removeLast()
            return last
        }
        return nil
    }
    
    func peak() -> Element? {
        self.last
    }
}
