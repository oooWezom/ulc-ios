//
//  String+RoundValue.swift
//  ULC
//
//  Created by Vitya on 10/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension Int {
    
    func roundValueAsString() -> String {
        var userLikes = String(self)
        
        if self > 999_999_999 {
            let roundLikes = self.roundDivision(1000_000_000)
            userLikes = String(roundLikes) + "b"
        } else if self > 999_999 {
            let roundLikes = self.roundDivision(1000_000)
            userLikes = String(roundLikes) + "m"
        } else if self > 999 {
            let roundLikes = self.roundDivision(1000)
            userLikes = String(roundLikes) + "k"
        }
        
        return userLikes
    }
}
