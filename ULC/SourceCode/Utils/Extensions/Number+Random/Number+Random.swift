//
//  Number+Random.swift
//  ULC
//
//  Created by Alex on 9/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

public func randomNumber(cap: Int) -> CGFloat {
    return CGFloat(arc4random_uniform(UInt32(cap)))
}

public func randomNumber(cap: CGFloat) -> CGFloat {
    return randomNumber(Int(cap))
}
