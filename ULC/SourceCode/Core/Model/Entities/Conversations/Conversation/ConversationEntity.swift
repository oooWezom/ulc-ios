//
//  Conversation.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import RealmSwift
import ObjectMapper

class ConversationEntity: BaseEntity {
    
    dynamic var createdTimestamp = 0;
    dynamic var createdDate = "";
    dynamic var unreadCount = 0;
    dynamic var parther: Partner?;
    dynamic var lastConversation: LastMessage?;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        createdTimestamp    <- map[MapperKey.created_timestamp]
        createdDate         <- map[MapperKey.created_date]
        unreadCount         <- map[MapperKey.unread_count]
        parther             <- map[MapperKey.partner]
        lastConversation    <- map[MapperKey.last_message]
    }
}
