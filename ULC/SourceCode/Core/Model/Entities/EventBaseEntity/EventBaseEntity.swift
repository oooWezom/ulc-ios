//
//  EventBaseEntity.swift
//  ULC
//
//  Created by Alex on 6/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class EventBaseEntity: BaseEntity {
    
    dynamic var name    = ""
    dynamic var avatar  = ""
    dynamic var level   = 0
    dynamic var status  = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        avatar  <- map[MapperKey.avatar]
        name    <- map[MapperKey.name]
        level   <- map[MapperKey.level]
        status  <- map[MapperKey.status]
    }
}
