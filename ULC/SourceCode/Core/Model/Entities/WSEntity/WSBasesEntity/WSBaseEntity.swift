//
//  WSBaseEntity.swift
//  ULC
//
//  Created by Alex on 8/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSBaseEntity: Mappable {
    
    var id = 0;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id    <- map[MapperKey.id]
    }
}

extension WSBaseEntity: Equatable {}

func ==(lhs: WSBaseEntity, rhs: WSBaseEntity) -> Bool {
    return lhs.id == rhs.id;
}
