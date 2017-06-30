//
//  WSFollowEntity.swift
//  ULC
//
//  Created by Vitya on 8/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSFollowEntity: WSBaseTypeEntity {
    
    var follow_id = 0
    var result = false

    var user: FollowerEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        follow_id   <- map[MapperKey.follow_id]
        result      <- map[MapperKey.result]
        user        <- map[MapperKey.user]
    }
}
