//
//  UIView+RoundedCorners.swift
//  ULC
//
//  Created by Alex on 9/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import QuartzCore

extension UIView {
    
    func roundedView(border: Bool, borderColor: UIColor?, borderWidth: CGFloat?, cornerRadius: CGFloat?) {
        
        if let radius = cornerRadius {
            layer.cornerRadius = radius
        } else {
            layer.cornerRadius = frame.size.width * 0.5
        }
        
        if border {
            
            if let borderColor = borderColor {
                layer.borderColor = borderColor.CGColor
            } else {
                layer.borderColor = UIColor.blackColor().CGColor;
            }
            
            if let borderWidth = borderWidth {
                layer.borderWidth = borderWidth
            } else {
                layer.borderWidth = 0.0
            }
        }
        
        layer.masksToBounds = true
    }
}
