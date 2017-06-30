//
//  WSGameplayMessage.swift
//  ULC
//
//  Created by Alexey on 9/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//
import ObjectMapper

class WSGameplayMessage: WSBaseTypeEntity {
    
    var message: WSGameMoveMessage?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        message       <- map[MapperKey.message]
    }
}
