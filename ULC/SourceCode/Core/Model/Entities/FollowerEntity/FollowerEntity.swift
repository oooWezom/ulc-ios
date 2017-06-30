//
//  Following.swift
//  ULC
//
//  Created by Alex on 6/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class FollowerEntity: EventBaseEntity {
    
    dynamic var sex = 0
    dynamic var exp = 0
    dynamic var link = 0
    dynamic var time_created = 0
    dynamic var time_acknowledged = 0
    dynamic var status_id = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        sex                 <- map[MapperKey.sex]
        exp                 <- map[MapperKey.exp]
        link                <- map[MapperKey.link]
        time_created        <- map[MapperKey.time_created]
        time_acknowledged   <- map[MapperKey.time_acknowledged]
        status_id           <- map[MapperKey.status_id]
    }
}
