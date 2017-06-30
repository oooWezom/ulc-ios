//
//  WSSwitchTalk.swift
//  ULC
//
//  Created by Vitya on 9/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSwitchTalk: WSBaseTypeEntity {
    
    var user = 0
    var to   = 0
    var from = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        user  <- map[MapperKey.user]
        to    <- map[MapperKey.to]
        from  <- map[MapperKey.from]
    }
}
