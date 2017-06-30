//
//  WSSessionState.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSessionStateEntity: WSBaseEntity {

	var state = 0
	var spectators = 0
  var loserID = 0
  var game = 0
  var winsCount = 0
  var players = [WSPlayerEntity]() // = [WSGameStatePlayerEntity]()

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		state       <- map[MapperKey.state]
		spectators  <- map[MapperKey.spectators]
    loserID     <- map[MapperKey.loser_id]
    game        <- map[MapperKey.game]
    players     <- map[MapperKey.players]
	}

}
