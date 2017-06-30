//
//  WSUpdateTalkData.swift
//  ULC
//
//  Created by Vitya on 9/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSUpdateTalkData: WSBaseTypeEntity {
    
    var talk = 0
    var name = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        talk  <- map[MapperKey.talk]
        name  <- map[MapperKey.name]
    }
}
