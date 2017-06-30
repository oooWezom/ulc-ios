//
//  Object+TypeName.swift
//  ULC
//
//  Created by Alex on 10/31/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol TypeName: AnyObject {
    static var typeName: String { get }
}

// Swift Objects
extension TypeName {
    static var typeName: String {
        let type = String(self)
        return type
    }
}

// Bridge to Obj-C
extension NSObject: TypeName {
    class var typeName: String {
        let type = String(self)
        return type
    }
}
