//
//  NSObject+ClassName.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}
