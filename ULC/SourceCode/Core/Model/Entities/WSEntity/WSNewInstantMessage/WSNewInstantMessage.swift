//
//  WSNewInstantMessage.swift
//  ULC
//
//  Created by Alex on 8/4/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSNewInstantMessage: WSInstantMessageEcho {
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
    }
}
