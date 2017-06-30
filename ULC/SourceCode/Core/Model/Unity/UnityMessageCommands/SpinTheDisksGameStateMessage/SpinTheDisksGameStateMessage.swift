//
//  SpinTheDisksGameState.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class SpinTheDisksGameStateMessage: UnityMessage {
    
	var game_id: Int?
	var wins_count: Int?
	var state: Int?
	var round: Int?
	var auto_finalization: Int?
	var players_data: [PlayerDataMessage]?

    required convenience init?(_ map: Map) {
        self.init()
    }

	override func mapping(map: Map) {
		game_id             <- map[MapperKey.game_id]
		wins_count          <- map[MapperKey.wins_count]
		state               <- map[MapperKey.state]
		round               <- map[MapperKey.round]
		auto_finalization   <- map[MapperKey.auto_finalization]
		players_data        <- map[MapperKey.players_data]
	}
}
