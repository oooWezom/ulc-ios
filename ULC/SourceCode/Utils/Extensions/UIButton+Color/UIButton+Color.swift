//
//  UIButton+Color.swift
//  ULC
//
//  Created by Alexey on 11/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  func setBackgroundColor(color: UIColor, forState: UIControlState, cornerRadius:CGFloat = 0) {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = true
    self.setBackgroundImage(colorImage, forState: forState)
  }}