//
//  CountersEntity.swift
//  ULC
//
//  Created by Vitya on 8/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class CountersEntity: BaseEntity {
    
    dynamic var conversations   = 0
    dynamic var messages        = 0
    dynamic var followers       = 0
    dynamic var warnings        = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        conversations       <- map[MapperKey.conversations]
        messages            <- map[MapperKey.messages]
        followers           <- map[MapperKey.followers]
        warnings            <- map[MapperKey.warnings]
    }
}
