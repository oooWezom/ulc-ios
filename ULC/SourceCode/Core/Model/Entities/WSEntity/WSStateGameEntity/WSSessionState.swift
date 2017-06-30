//
//  WSStateGame.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSessionState: WSBaseTypeEntity {

	var sessionState: WSSessionStateEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		sessionState <- map[MapperKey.session_state]
	}
}
