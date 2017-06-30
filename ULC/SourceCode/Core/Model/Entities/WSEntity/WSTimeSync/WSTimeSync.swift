//
//  WSTimeSync.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSTimeSync: WSBaseEntity {

	var abs_time = 0
	var global_time = 0
	var user_id = 0

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		abs_time <- map[MapperKey.abs_time]
		global_time <- map[MapperKey.global_time]
		user_id <- map[MapperKey.user_id]

	}
}
