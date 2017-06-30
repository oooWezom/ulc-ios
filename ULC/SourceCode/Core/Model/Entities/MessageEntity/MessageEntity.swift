//
//  MessageEntity.swift
//  ULC
//
//  Created by Alex on 7/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import RealmSwift
import ObjectMapper

class MessageEntity: BaseEntity {
    
    dynamic var conversationID = 0;
    dynamic var out = 0;
    dynamic var text = "";
    dynamic var postedTimestamp = 0;
    dynamic var postedDate = "";
    dynamic var delivered_timestamp = 0;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        conversationID      <- map[MapperKey.conversation_id];
        out                 <- map[MapperKey.out]
        text                <- map[MapperKey.text]
        postedTimestamp     <- map[MapperKey.posted_timestamp]
        postedDate          <- map[MapperKey.posted_date]
        delivered_timestamp <- map[MapperKey.delivered_timestamp]
    }
}
