//
//  LastConversation.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import RealmSwift
import ObjectMapper

class LastMessage: BaseEntity {
    
    dynamic var senderID = 0;
    dynamic var text = "";
    dynamic var postedDate = "";
    dynamic var postedTimestamp = 0;
    dynamic var deliveredDate = "";
    dynamic var deliveredTimestamp = 0;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        senderID <- map["sender.id"]
        
        text <- map[MapperKey.text]
        postedTimestamp <- map[MapperKey.posted_timestamp]
        postedDate <- map[MapperKey.posted_date]
        deliveredDate <- map[MapperKey.delivered_date]
        deliveredTimestamp <- map[MapperKey.delivered_timestamp]
    }
}
