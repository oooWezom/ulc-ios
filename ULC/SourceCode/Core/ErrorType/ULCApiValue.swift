//
//  ULCApiVersionError.swift
//  ULC
//
//  Created by Cruel Ultron on 2/23/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

enum ULCApiValue: ErrorType, CustomStringConvertible {
    
    case CURRENT_VERSION
    case OLD_VERSION
    case NEW_VERSION_AVALIABLE
    
    var description: String {
        switch self {
        case .CURRENT_VERSION:
            return "";
            
        case .OLD_VERSION:
            return "";
            
        default:
            return "";
        }
    }
}
