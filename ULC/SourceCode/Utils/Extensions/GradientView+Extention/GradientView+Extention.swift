//
//  GradientView+Extention.swift
//  ULC
//
//  Created by Alexey on 9/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension GradientView {
    func initBlackGradient(location:[CGFloat]){
        self.backgroundColor = UIColor.clearColor()
        self.colors = [UIColor.clearColor(), UIColor.blackColor()]
        self.locations = location
        self.alpha = 0.8
        self.direction = .Vertical
    }
    
    func initClearGradient(location:[CGFloat]){
        self.backgroundColor = UIColor.clearColor()
        self.colors = [UIColor.clearColor()]
        self.locations = location
        self.alpha = 0.8
        self.direction = .Vertical
    }
}
