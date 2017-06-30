//
//  String+Dictionary.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/17/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

func convertStringToDictionary(text: String) -> [String:AnyObject]? {
    if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            Swift.debugPrint(error)
        }
    }
    return nil
}