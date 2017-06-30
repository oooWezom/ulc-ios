//
//  String+Localized.swift
//  ULC
//
//  Created by Alex on 6/5/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "");
    }
}
