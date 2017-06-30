//
//  LinkedEntity.swift
//  ULC
//
//  Created by Vitya on 8/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class LinkedEntity: WSBaseEntity {
    
    var category = 0
    var state = 0
    var state_desc = ""
    var likes = 0
    var spectators = 0
    
    var streamer: WSStreamerEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        category        <- map[MapperKey.category]
        state           <- map[MapperKey.state]
        state_desc      <- map[MapperKey.state_desc]
        likes           <- map[MapperKey.likes]
        spectators      <- map[MapperKey.spectators]
        
        streamer        <- map[MapperKey.streamer]
    }
}
