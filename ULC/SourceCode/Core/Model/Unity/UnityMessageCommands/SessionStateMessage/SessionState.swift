//
//  SessionState.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionState: UnityMessage {
    
	var state: Int?
	var viewers: Int?

    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        state   <- map[MapperKey.state]
        viewers <- map[MapperKey.viewers]
    }
}
