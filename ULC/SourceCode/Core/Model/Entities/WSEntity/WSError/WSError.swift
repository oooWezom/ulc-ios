//
//  WSError.swift
//  ULC
//
//  Created by Vitya on 9/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSError: WSBaseTypeEntity {
    
    dynamic var error   = 0
    dynamic var message = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        
        error    <- map[MapperKey.error]
        message  <- map[MapperKey.message]
    }
}
