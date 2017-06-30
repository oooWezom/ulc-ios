//
//  WSStreamerEntity.swift
//  ULC
//
//  Created by Vitya on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSStreamerEntity: WSBaseEntity {
    
    var name = ""
    var sex = 0
    var level = 0
    var avatar = ""
    
    var talk: WSSenderEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        name        <- map[MapperKey.name]
        sex         <- map[MapperKey.sex]
        level       <- map[MapperKey.level]
        avatar      <- map[MapperKey.avatar]
    }
}
