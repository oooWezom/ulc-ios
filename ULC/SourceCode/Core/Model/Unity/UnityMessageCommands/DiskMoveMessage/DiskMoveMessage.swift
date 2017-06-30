//
//  DiskMoveMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class DiskMoveMessage: UnityMessage {

	var angle: Int?
	var disk: Int?

    required convenience init?(_ map: Map) {
        self.init()
    }

	override func mapping(map: Map) {
		angle   <- map[MapperKey.angle]
		disk    <- map[MapperKey.disk]
	}
}
