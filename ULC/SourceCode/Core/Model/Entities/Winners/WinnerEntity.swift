//
//  WinnerEntity.swift
//  ULC
//
//  Created by Alexey on 10/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import RealmSwift

class WinnerEntity : Object{
    var winCount = List<IntObject>()
}
