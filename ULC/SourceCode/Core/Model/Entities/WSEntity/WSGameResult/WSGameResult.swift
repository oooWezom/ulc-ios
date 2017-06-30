//
//  WSGameResult.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameResult: WSBaseTypeEntity {

	var sessionState: WSSessionPlayersStats?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		sessionState <- map[MapperKey.session_state]
	}
}
