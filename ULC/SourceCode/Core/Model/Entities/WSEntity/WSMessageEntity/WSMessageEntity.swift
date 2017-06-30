//
//  WSMessageEntity.swift
//  ULC
//
//  Created by Alex on 8/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSMessageEntity: WSBaseEntity {
    
    var conversationID = 0;
    var text = ""
    var postedTimestamp = 0;
    var postedDate = "";
    var sender: Partner?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        conversationID  <- map[MapperKey.conversation_id];
        sender          <- map[MapperKey.sender];
        text            <- map[MapperKey.text];
        postedTimestamp <- map[MapperKey.posted_timestamp];
        postedDate      <- map[MapperKey.posted_date];
    }
}
