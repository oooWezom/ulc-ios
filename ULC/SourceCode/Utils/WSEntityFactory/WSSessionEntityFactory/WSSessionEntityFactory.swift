//
//  WSSessionEntityFactory.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSSessionEntityFactory: EntityCreatable {

	func createEntity(dictionary: [String: AnyObject]) -> Mappable? {

		Swift.debugPrint("*********** SOCKET ***********")
		Swift.debugPrint(dictionary)
		Swift.debugPrint("*********** SOCKET ***********")

		guard let code = dictionary["type"] as? Int where code > 0 else {
			return nil;
		}

		guard let eventCode = SessionEvents(rawValue: code) else {
			return nil;
		}

		switch eventCode {
            
        case SessionEvents.GAME_FOUND:
            return Mapper<WSGameCreateEntity>().map(dictionary);

		case SessionEvents.SESSION_STATE:
			return Mapper<WSSessionState>().map(dictionary);

		case SessionEvents.GAME_STATE:
			return Mapper<WSGameStateEntity>().map(dictionary);

		case SessionEvents.BEGIN_EXECUTION:
			return Mapper<WSSessionState>().map(dictionary);

		case SessionEvents.LOSER_DONE_HIS_PERFORMANCE:
			return Mapper<WSSessionState>().map(dictionary);

		case SessionEvents.GAME_RESULTS:
			return Mapper<WSGameResult>().map(dictionary);

		case SessionEvents.PLAYER_CONNECTED_TO_SESSION:
			return Mapper<WSPlayerReconnectedEntity>().map(dictionary);

		case SessionEvents.PLAYER_RECONNECTED_TO_SESSION:
			return Mapper<WSPlayerReconnectedEntity>().map(dictionary);

		case SessionEvents.SPECTATOR_CONNECTED_TO_SESSION:
			return Mapper<WSSspectatorSessionEntity>().map(dictionary);

		case SessionEvents.SESSION_USER_DISCONNECTED:
			return Mapper<WSPlayerDisconnectedEntity>().map(dictionary);

		case SessionEvents.SESSION_MESSAGE:
			return Mapper<WSGameChatMessageEntity>().map(dictionary);

		case SessionEvents.PLAYER_READY:
			return Mapper<WSPlayerReadyEntity>().map(dictionary);
            
        case SessionEvents.GAME_RESULT:
            return Mapper<WSRoundResultEntity>().map(dictionary);
            
        case SessionEvents.ROUND_START:
            return Mapper<WSRoundStartEntity>().map(dictionary);

		default:
			return nil;
		}
	}
}
