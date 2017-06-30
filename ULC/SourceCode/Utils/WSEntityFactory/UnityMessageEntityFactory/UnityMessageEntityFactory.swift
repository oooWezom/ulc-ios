//
//  UnityMessageEntityFactory.swift
//  ULC
//
//  Created by Alexey on 8/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class UnityMessageEntityFactory: EntityCreatable {

    let generalViewModel = GeneralViewModel()
    
	func createEntity(dictionary: [String: AnyObject]) -> Mappable? {
        
        guard let code = dictionary["type"] as? Int where code > 0 else {
            return nil;
        }
        
        var type = code

		if code == ProfileEvents.GAME_CREATED.rawValue {
			type = UnityEvents.INIT_GAME.rawValue;
		}

		switch type {

		case UnityEvents.INIT_GAME.rawValue: // WSGameCreateEntity
			var user_id = 0
			var leftPlayerId = 0
			guard let game = Mapper<WSGameCreateEntity>().map(dictionary) else {
				return nil;
			}

			guard let gameID =  game.game?.id else {
				return nil;
			}

			if let players = game.game?.players {
				players.forEach { it in
					if it.id == generalViewModel.currentId {
						user_id = it.id
					} else {
						leftPlayerId = it.id
					}
				}
			}
            
			let model = GameInitMessage()
			model.game_id = gameID
			model.user_id = user_id
			model.leftPlayerId = leftPlayerId
            model.game_type = game.game?.game
            model.base_url = Constants.GAMES_IMAGES_URL
			model.type = UnityEvents.INIT_GAME.rawValue
			return model;

		case UnityEvents.INIT_GAME_STATE.rawValue:
            
			return Mapper<GameStateMessage>().map(dictionary);

		case UnityEvents.PLAYER_READY.rawValue:
            
			return Mapper<PlayerReadyMessage>().map(dictionary);

		case UnityEvents.ROUND_START.rawValue:
			return Mapper<RoundStartMessage>().map(dictionary);

		case UnityEvents.MOVE.rawValue:
            
			return Mapper<MoveMessage>().map(dictionary);
            
        case UnityEvents.GAME_RESULT.rawValue:
            return Mapper<WSRoundResultRockSpockEntity>().map(dictionary);

		default:
			return nil;
		}
	}
}
