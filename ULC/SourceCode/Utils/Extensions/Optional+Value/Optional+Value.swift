//
//  Optional+Value.swift
//  ULC
//
//  Created by Alex on 12/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension Optional {
    func or(defaultValue: Wrapped) -> Wrapped {
        switch(self) {
        case .None:
            return defaultValue
        case .Some(let value):
            return value
        }
    }
}