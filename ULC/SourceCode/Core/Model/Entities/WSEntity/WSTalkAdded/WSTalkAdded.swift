//
//  WSTalkAdded.swift
//  ULC
//
//  Created by Vitya on 9/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSTalkAdded: WSBaseTypeEntity {
    
    var talk = TalkSessionsResponseEntity()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        talk  <- map[MapperKey.talk]
    }
}
