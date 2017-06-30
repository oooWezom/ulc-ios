//
//  WSCreateTalkMessage.swift
//  ULC
//
//  Created by Vitya on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSCreateTalkMessage: WSBaseTypeEntity {
    
    var category = 0
    var result = 0
    var message = ""
    var state = 0
    var state_desc = ""
    var likes = 0
    var spectators = 0
    
    var talk: TalkSessionsResponseEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        category        <- map[MapperKey.category]
        result          <- map[MapperKey.result]
        message         <- map[MapperKey.message]
        state           <- map[MapperKey.state]
        state_desc      <- map[MapperKey.state_desc]
        likes           <- map[MapperKey.likes]
        spectators      <- map[MapperKey.spectators]
        
        talk            <- map[MapperKey.talk]
    }
}
