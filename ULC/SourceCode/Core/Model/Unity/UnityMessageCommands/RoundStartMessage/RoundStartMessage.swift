//
//  RoundStartMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class RoundStartMessage: UnityMessage {

	var p1: WSGameStatePlayerEntity?
	var p2: WSGameStatePlayerEntity?

    required convenience init?(_ map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        super.mapping(map);
		p1 <- map[MapperKey.p1]
		p2 <- map[MapperKey.p2]
	}
}
