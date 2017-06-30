//
//  PlaylistEntity.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/1/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class PlaylistEntity: BaseEntity {

	var name = ""
	var state = 0
	var events = List<PlaylistEventEntity>()

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map)
		name	<- map[MapperKey.name]
		state	<- map[MapperKey.state]
        events  <- (map[MapperKey.events], ListTransform<PlaylistEventEntity>())
	}
}