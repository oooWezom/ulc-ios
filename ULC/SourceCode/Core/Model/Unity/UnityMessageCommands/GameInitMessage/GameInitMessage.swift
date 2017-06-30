//
//  GameInitMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class GameInitMessage: UnityMessage {

	var user_id: Int?
	var game_id: Int?
    var game_type: Int?
	var leftPlayerId: Int?
    var base_url: String?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
	override func mapping(map: Map) {
		super.mapping(map);
		user_id <- map[MapperKey.user_id]
		game_id <- map[MapperKey.game_id]
        game_type <- map[MapperKey.game]
		leftPlayerId <- map[MapperKey.left_player_id]
        base_url <- map[MapperKey.base_url]
	}
}
