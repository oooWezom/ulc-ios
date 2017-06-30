//
//  String+Validator.swift
//  ULC
//
//  Created by Alex on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension String {
    
    var isValidEmail: Bool {
        let filterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", filterString)
        return emailTest.evaluateWithObject(self)
    }
    
}

