//
//  StreamerEntity.swift
//  ULC
//
//  Created by Vitya on 8/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class StreamerEntity: EventBaseEntity {
    
    dynamic var sex = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        sex    <- map[MapperKey.sex]
    }
}
