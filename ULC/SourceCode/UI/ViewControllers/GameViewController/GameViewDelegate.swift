//
//  GameViewDelegate.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

protocol GameViewDelegate:class {
    
    func bind(view:UIView)
    
    func unbind(view:UIView)
    
}