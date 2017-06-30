//
//  WSDonateMessage.swift
//  ULC
//
//  Created by Vitya on 9/24/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSDonateMessage: WSBaseTypeEntity {
    
    var message = WSMessageEntity()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        message  <- map[MapperKey.message]
    }
}
