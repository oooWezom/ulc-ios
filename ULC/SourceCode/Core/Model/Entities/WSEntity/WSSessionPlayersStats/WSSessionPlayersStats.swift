//
//  WSSessionPlayersStats.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSessionPlayersStats: WSBaseEntity {

	var state = 0
	var spectators = 0
	var loserID = 0
	var playersStats = [WSPlayerStats]()

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		state           <- map[MapperKey.state]
		spectators      <- map[MapperKey.spectators]
		loserID         <- map[MapperKey.loser_id]
		playersStats    <- map[MapperKey.players_stats]
	}

}
