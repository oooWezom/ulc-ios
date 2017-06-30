//
//  WSRoundResultEntity.swift
//  ULC
//
//  Created by Alexey on 9/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSRoundResultEntity: WSBaseTypeEntity {
    
    var final = false
    var winner_id = 0

    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        winner_id   <- map[MapperKey.winner_id]
        final       <- map[MapperKey.final]
    }

}
