//
//  WSPlayerReadyEntity.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSPlayerReadyEntity: WSBaseTypeEntity {

	var id = 0
	var timeSync: WSTimeSync?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		id          <- map[MapperKey.id]
		timeSync    <- map[MapperKey.time_sync]
	}
}
