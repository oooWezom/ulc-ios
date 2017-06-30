//
//  CGFloat+Degrees.swift
//  ULC
//
//  Created by Alex on 6/17/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension CGFloat {
    var doubleValue:      Double  { return Double(self) }
    var degreesToRadians: CGFloat { return CGFloat(doubleValue * M_PI / 180) }
    var radiansToDegrees: CGFloat { return CGFloat(doubleValue * 180 / M_PI) }
}
