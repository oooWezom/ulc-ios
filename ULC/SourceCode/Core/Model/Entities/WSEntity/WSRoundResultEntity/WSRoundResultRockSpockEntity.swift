//
//  WSRoundResultRockSpockEntity.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/14/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSRoundResultRockSpockEntity: WSBaseTypeEntity {
    
    var final = false
    var winner_id = 0
    var moves = [Int]()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        winner_id   <- map[MapperKey.winner_id]
        final       <- map[MapperKey.final]
        moves       <- map[MapperKey.moves]
    }
    
}
