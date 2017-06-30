//
//  WSBaseEntity.swift
//  ULC
//
//  Created by Alex on 8/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSBaseTypeEntity: Mappable {
    
    var type = 0
    var stype = "";
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        type    <- map[MapperKey.type]
        stype   <- map[MapperKey.stype]
    }
    
    var eventType: Int {
        return type;
    }
}
