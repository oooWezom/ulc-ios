//
//  WSPlayerStats.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSPlayerStats: WSBaseEntity {

	var level = 0
	var exp = 0
	var voices: WSVoicesEntity?

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		super.mapping(map);
		level   <- map[MapperKey.level]
		exp     <- map[MapperKey.exp]
		voices  <- map[MapperKey.voices]
	}
}
