//
//  WSInstantMessageEcho.swift
//  ULC
//
//  Created by Alex on 8/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSInstantMessageEcho: WSBaseTypeEntity {
    
    var recipientID = 0;
    
    var message: WSMessageEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        recipientID     <- map["recipient_id"]
        message         <- map[MapperKey.message]
    }
}
