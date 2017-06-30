//
//  LocalizedString.swift
//  ULC
//
//  Created by Alex on 6/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

internal func LocalizedString(key: String, comment: String?) -> String {
    struct Static {
        static let bundle = NSBundle(identifier: "Wezom-Mobile.ULC")!
    }
    return NSLocalizedString(key, bundle: Static.bundle, comment: comment ?? "")
}
