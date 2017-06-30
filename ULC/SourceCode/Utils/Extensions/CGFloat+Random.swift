//
//  CGFloat+Random.swift
//  ULC
//
//  Created by Cruel Ultron on 6/12/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
