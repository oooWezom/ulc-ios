//
//  WSGameStateDataEntity.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameStateDataEntity: WSBaseEntity {

	var gameId = 0
	var winsCount = 0
	var state = 0
	var round = 0
	var playersData = [WSGameStatePlayerEntity]()

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		gameId      <- map[MapperKey.game_id]
		winsCount   <- map[MapperKey.wins_count]
		state       <- map[MapperKey.state]
		round       <- map[MapperKey.round]
		playersData <- map[MapperKey.players_data]
	}
}
