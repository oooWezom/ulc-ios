//
//  Int+RoundDivision.swift
//  ULC
//
//  Created by Vitya on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension Int {
    func roundDivision(divNumber: Double) -> Int {
        let doubleLikes = Double(self) / divNumber
        return Int(round(doubleLikes))
    }
}
