//
//  WSNotifyGameEntity.swift
//  ULC
//
//  Created by Vitya on 8/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSNotifyGameEntity: WSBaseTypeEntity {
    
    var user = 0
    
    var game: WSGameEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        user     <- map[MapperKey.user]
        game     <- map[MapperKey.game]

    }
}
