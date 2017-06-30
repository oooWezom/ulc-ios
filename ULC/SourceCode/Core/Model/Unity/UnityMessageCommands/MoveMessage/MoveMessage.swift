//
//  MoveMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class MoveMessage: UnityMessage {
    
	var disk: Int?
	var angle: Int?
	var id: Int?

    required convenience init?(_ map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        super.mapping(map);
		disk    <- map[MapperKey.disk]
		angle   <- map[MapperKey.angle]
		id      <- map[MapperKey.id]
	}
}
