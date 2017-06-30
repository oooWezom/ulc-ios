//
//  WSGameEntity.swift
//  ULC
//
//  Created by Alexey on 8/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameEntity: WSBaseEntity {

    var game = 0
    var state = 0
    var spectators = 0
    var players = [WSPlayerEntity]()
    var videoUrl = ""

    required convenience init?(_ map: Map) {
        self.init()
    }

    override func mapping(map: Map) {
        super.mapping(map);
        game        <- map[MapperKey.game]
        state       <- map[MapperKey.state]
        spectators  <- map[MapperKey.spectators]
        players     <- map[MapperKey.players]
        videoUrl    <- map[MapperKey.videoUrl]
	}
    
    static func create(model: GameSessionsEntity) -> WSGameEntity {
        let gameEntity          = WSGameEntity();
		gameEntity.id			= model.id;
        gameEntity.game         = model.game;
        gameEntity.state        = model.state;
        gameEntity.spectators   = model.spectators;
        gameEntity.players      = model.players;
        gameEntity.videoUrl     = model.videoUrl;
        return gameEntity;
    }
}
