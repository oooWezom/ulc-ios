//
//  WSRoundStartEntity.swift
//  ULC
//
//  Created by Alexey on 9/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSRoundStartEntity: WSBaseTypeEntity {
    
    var p1:WSPlayerEntity?
    var p2:WSPlayerEntity?
    var timeSync: WSTimeSync?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        p1          <- map[MapperKey.p1]
        p2          <- map[MapperKey.p2]
        timeSync    <- map[MapperKey.time_sync]
    }
}
