//
//  InviteEntity.swift
//  ULC
//
//  Created by Vitya on 7/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSInviteEntity: WSBaseTypeEntity {
    
    var category = 0
    var expires = 0
    var result = 0
    var message = ""
    var time = 0
    
    var sender: WSSenderEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        category    <- map[MapperKey.category]
        expires     <- map[MapperKey.expires]
        result      <- map[MapperKey.result]
        message     <- map[MapperKey.message]
        time        <- map[MapperKey.time]
        sender      <- map[MapperKey.sender]
    }
}
