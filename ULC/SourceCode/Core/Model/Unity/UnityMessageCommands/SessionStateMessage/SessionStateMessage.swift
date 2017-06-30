//
//  SessionStateMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class SessionStateMessage: UnityMessage {

	var session_state: SpinTheDisksGameStateMessage?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		session_state <- map[MapperKey.session_state]
	}

}
