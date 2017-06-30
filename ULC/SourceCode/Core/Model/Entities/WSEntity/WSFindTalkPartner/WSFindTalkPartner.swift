//
//  WSFindTalkPartner.swift
//  ULC
//
//  Created by Vitya on 10/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSFindTalkPartner: WSBaseTypeEntity {
    
    var result  = 0
    var message = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        result      <- map[MapperKey.result]
        message     <- map[MapperKey.message]
        
    }
}
