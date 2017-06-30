//
//  LoginTextFiled.swift
//  ULC
//
//  Created by Alex on 6/5/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

class LoginTextField: UITextField {
    
    let bottomInfoLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.borderStyle = .None
        self.autocorrectionType = .No
        self.keyboardType = .Default
        self.returnKeyType = .Done
        self.clearButtonMode = .WhileEditing
        self.contentVerticalAlignment = .Center
        self.tintColor = UIColor(named: .NavigationBarColor)

        bottomInfoLayer.backgroundColor = UIColor.blackColor().CGColor
        self.layer.addSublayer(bottomInfoLayer)
        
        if let clearButton = self.valueForKey("_clearButton") as? UIButton {
        clearButton.setImage(R.image.clear_button_icon(), forState: .Normal)
        }
        
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        bottomInfoLayer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)
    }
}
