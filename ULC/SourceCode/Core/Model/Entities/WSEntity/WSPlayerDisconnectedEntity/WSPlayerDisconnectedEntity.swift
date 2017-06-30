//
//  WSPlayerDisconnectedEntity.swift
//  ULC
//
//  Created by Alexey on 10/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSPlayerDisconnectedEntity:WSBaseTypeEntity {
    
     var user: WSPlayerEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        user        <- map[MapperKey.user]
    }

}

