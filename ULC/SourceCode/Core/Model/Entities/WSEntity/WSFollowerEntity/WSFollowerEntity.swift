//
//  WSFollowerEntity.swift
//  ULC
//
//  Created by Vitya on 8/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSFollowerEntity: WSBaseTypeEntity {
    
    var user: FollowerEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        user    <- map[MapperKey.user]

    }
}
