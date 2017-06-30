//
//  Array+Utils.swift
//  ULC
//
//  Created by Alex on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object){
            self.removeAtIndex(index);
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object);
        }
    }
}
