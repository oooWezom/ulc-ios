//
//  WSGameMoveMessage.swift
//  ULC
//
//  Created by Alexey on 9/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSGameMoveMessage: WSBaseEntity {
    
    var angle = 0
    var disk = 0
    
    required init?(_ map: Map) { }
    
    override func mapping(map: Map) {
        super.mapping(map);
        angle       <- map[MapperKey.angle]
        disk        <- map[MapperKey.disk]
    }
}
