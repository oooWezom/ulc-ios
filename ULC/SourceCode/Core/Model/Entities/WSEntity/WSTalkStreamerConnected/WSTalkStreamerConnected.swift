//
//  WSTalkStreamerConnected.swift
//  ULC
//
//  Created by Vitya on 9/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSTalkStreamerConnected: WSBaseTypeEntity {
    
    var talk = 0
    var user = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        talk  <- map[MapperKey.talk]
        user  <- map[MapperKey.user]
    }
}
