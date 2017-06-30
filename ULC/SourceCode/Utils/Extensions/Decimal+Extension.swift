//
//  Decimal+Extension.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/7/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}