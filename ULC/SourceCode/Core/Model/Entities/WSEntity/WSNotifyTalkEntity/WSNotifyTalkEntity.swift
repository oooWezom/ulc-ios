//
//  WSNotifyTalkEntity.swift
//  ULC
//
//  Created by Vitya on 8/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSNotifyTalkEntity: WSBaseTypeEntity {
    
    var talk: TalkSessionsResponseEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        talk    <- map[MapperKey.talk]
    }
}
