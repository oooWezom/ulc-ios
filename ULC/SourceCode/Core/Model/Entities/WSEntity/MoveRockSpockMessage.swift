//
//  MoveRockSpockMessage.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/14/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class MoveRockSpockMessage: WSBaseEntity {
    
    var move = 0
    
    required init?(_ map: Map) { }
    
    override func mapping(map: Map) {
        super.mapping(map);
        move       <- map[MapperKey.move]
    }
}