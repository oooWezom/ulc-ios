//
//  WSInstantMessageRead.swift
//  ULC
//
//  Created by Vitya on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class WSInstantMessageRead: WSBaseTypeEntity {
    
    var sender = 0
    var messages = [Int]()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        sender          <- map[MapperKey.sender]
        messages        <- map[MapperKey.messages]
    }
}
