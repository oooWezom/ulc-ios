//
//  WSSenderEntity.swift
//  ULC
//
//  Created by Alex on 8/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSSenderEntity: WSBaseEntity {
    
    var avatar = ""
    var level = 0
    var name = ""
    var sex = 0
    var status = 0;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        avatar  <- map[MapperKey.avatar]
        level   <- map[MapperKey.level]
        name    <- map[MapperKey.name]
        sex     <- map[MapperKey.sex]
        status  <- map[MapperKey.status]
    }
    
    static func getWSSenderEntity(streamer: WSStreamerEntity) -> WSSenderEntity {
    
        let sender = WSSenderEntity()
        
        sender.avatar   = streamer.avatar
        sender.level    = streamer.level
        sender.name     = streamer.name
        sender.sex      = streamer.sex
        
        return sender
    }
}
