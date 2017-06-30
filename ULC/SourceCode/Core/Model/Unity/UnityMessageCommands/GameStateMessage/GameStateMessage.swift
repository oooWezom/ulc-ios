//
//  GameStateMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class GameStateMessage: UnityMessage {

	var data: SpinTheDisksGameStateMessage?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		data <- map[MapperKey.data]
	}
}
