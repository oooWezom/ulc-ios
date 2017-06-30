//
//  PlayerReadyMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class PlayerReadyMessage: UnityMessage {

	var id: Int?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		id <- map[MapperKey.id]
	}
}
