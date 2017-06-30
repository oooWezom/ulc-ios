//
//  WSSspectatorSessionEntity.swift
//  ULC
//
//  Created by Alexey on 9/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSspectatorSessionEntity: WSBaseTypeEntity {

	var spectator: WSSspectatorEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		spectator <- map[MapperKey.spectator]
	}

}
