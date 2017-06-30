//
//  WSPlayerReconnectedEntity.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSPlayerReconnectedEntity: WSBaseTypeEntity {

	var player: WSPlayerEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		player <- map[MapperKey.player]
	}
}
