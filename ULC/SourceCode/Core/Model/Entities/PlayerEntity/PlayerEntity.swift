//
//  PlayerEntity.swift
//  ULC
//
//  Created by Alexey on 10/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class PlayerEntity: Mappable {
    
    var id = 0
    var level = 0
    var name = ""
    var languages  = [Int]()
    var games  = [Int]()
    var stateDesc = ""
    var exp = 0
    var avatar = ""
    var state = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id                  <- map[MapperKey.id]
        level               <- map[MapperKey.level]
        name                <- map[MapperKey.name]
        languages           <- map[MapperKey.languages]
        games               <- map[MapperKey.games]
        stateDesc           <- map[MapperKey.state_desc]
        exp                 <- map[MapperKey.exp]
        avatar              <- map[MapperKey.avatar]
        state               <- map[MapperKey.state]
    }
}
