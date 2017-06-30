//
//  Owner.swift
//  ULC
//
//  Created by Alex on 6/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class Owner: EventBaseEntity {
    
    dynamic var exp = 0
    dynamic var likes = 0
    dynamic var level_up = 0
    dynamic var link = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        exp         <- map[MapperKey.exp]
        likes       <- map[MapperKey.likes]
        level_up    <- map[MapperKey.level_up]
    }
    
    static func getOwnerEntity(model: UserEntity) -> Owner {
        
        let owner = Owner()
        
        owner.id        = model.id
        owner.name      = model.name
        owner.avatar    = model.avatar
        owner.level     = model.level
        owner.status    = model.status
        owner.link      = model.link
        
        owner.likes     = model.likes
        owner.level_up  = model.level
        
        return owner
    }
}

