//
//  WSSspectatorEntity.swift
//  ULC
//
//  Created by Alexey on 9/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSSspectatorEntity: WSBaseEntity {

	var name = ""

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		name <- map[MapperKey.name]
	}

}
