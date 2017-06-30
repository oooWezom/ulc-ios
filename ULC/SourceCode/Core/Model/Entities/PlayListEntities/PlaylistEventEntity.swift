//
//  PlaylistEventEntity.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/1/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class PlaylistEventEntity: BaseEntity {

	var duration = 0

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map)
		duration <- map[MapperKey.duration]
	}
}