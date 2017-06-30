//
//  FollowingEntity.swift
//  ULC
//
//  Created by Alex on 7/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class FollowingEntity: EventBaseEntity {
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
    }
}
