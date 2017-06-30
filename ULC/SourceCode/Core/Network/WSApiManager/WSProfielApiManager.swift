//
//  WebSocketManager.swift
//  ULC
//
//  Created by Alexey on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import Starscream

public enum WSProfielApiManager {
    
    case Introduce(Int, String, Int, Int, String)
    case InstantMessage(Int, String, Int, String)
    
    case FindTalkPartner(Int, String)
    case InviteTalkPartner(Int, Int)
    case InviteToTalkResponseAccept(Int)
    case InviteToTalkResponseDeny(Int)
    case InviteResponseNotDisturb(Int, Int)
    case LookingForGame([Int])
    case LookingForGameToWatch([Int])
    case CancelGameSearch()
    case CreateTwoTalk(Int, String)
    case FollowUser(Int)
    case UnfollowUser(Int)
    case ReadInstantMessage([Int])
    case FollowerAcknowledged([Int])
    case AnonymousIntroduce(Int, String, Int, Int)
}



extension WSProfielApiManager {
    
    var parameters: [String: AnyObject]? {
        
        switch self {
            
        case .Introduce(let type, let stype, let platform, let version, let token):
            let value = [WSProfileApiManagerKey.type: type,
                         WSProfileApiManagerKey.stype: stype,
                         WSProfileApiManagerKey.platform: platform,
                         WSProfileApiManagerKey.version: version,
                         WSProfileApiManagerKey.token: token];
            return value as? [String : AnyObject]
            
        case .InstantMessage(let type, let stype, let recipient_id, let text):
            let value =  [WSProfileApiManagerKey.type: type,
                          WSProfileApiManagerKey.stype: stype,
                          WSProfileApiManagerKey.recipient_id: recipient_id,
                          WSProfileApiManagerKey.text: text];
            return value as? [String : AnyObject];
            
        case .FindTalkPartner(let type, let stype):
            let value = [WSProfileApiManagerKey.type: type,
                         WSProfileApiManagerKey.stype: stype];
            return value as? [String : AnyObject]
            
        case .InviteTalkPartner(let recipient, let category):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.INVITE_TO_TALK.rawValue,
                         WSProfileApiManagerKey.recipient: recipient,
                         WSProfileApiManagerKey.category: category]
            return value as [String: AnyObject]
            
        case .InviteToTalkResponseAccept(let sender):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                         WSProfileApiManagerKey.result: WebSocketInviteResultKey.accept,
                         WSProfileApiManagerKey.sender: sender]
            return value as [String : AnyObject]
            
        case .InviteToTalkResponseDeny(let sender):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                         WSProfileApiManagerKey.result: WebSocketInviteResultKey.deny,
                         WSProfileApiManagerKey.sender: sender]
            return value as [String : AnyObject]
            
        case .InviteResponseNotDisturb(let time, let sender):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                         WSProfileApiManagerKey.result: WebSocketInviteResultKey.do_Not_Disturb,
                         WSProfileApiManagerKey.time: time,
                         WSProfileApiManagerKey.sender: sender]
            return value as [String : AnyObject]
            
        case .LookingForGame(let games):
			let value = [WSProfileApiManagerKey.type: WebSocketTypeKey.looking_for_game_response,
			             WSProfileApiManagerKey.stype: WebSocketStypeKey.looking_for_game_request,
			             WSProfileApiManagerKey.games : games]
			return value as? [String: AnyObject]

        case .LookingForGameToWatch(let exclude):
            let value = [WSProfileApiManagerKey.type: WebSocketTypeKey.looking_for_game_to_watch,
                         WSProfileApiManagerKey.stype: WebSocketStypeKey.looking_for_game_to_watch,
                         WSProfileApiManagerKey.exclude : exclude]
            return value as? [String: AnyObject]

        case .CancelGameSearch():
            let value = [WSProfileApiManagerKey.type: WebSocketTypeKey.cancel_game_search
            ]
            return value

        case .CreateTwoTalk(let category, let name):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.CREATE_TALK.rawValue,
                         WSProfileApiManagerKey.category: category,
                         WSProfileApiManagerKey.name: name]
            return value as? [String: AnyObject]

        case .FollowUser(let userId):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.FOLLOW_USER.rawValue,
                         WSProfileApiManagerKey.follow_id: userId]
            return value as [String: AnyObject]

        case .UnfollowUser(let userId):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.UNFOLLOW_USER.rawValue,
                         WSProfileApiManagerKey.unfollow_id: userId]
            return value as [String: AnyObject]

        case .ReadInstantMessage(let message):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.INSTANT_MESSAGE_MARK_READ.rawValue,
                         WSProfileApiManagerKey.messages: message]
            return value as? [String: AnyObject]

        case .FollowerAcknowledged(let followersId):
            let value = [WSProfileApiManagerKey.type: ProfileEvents.FOLLOWER_ACKNOWLEDGED.rawValue,
                        WSProfileApiManagerKey.followers: followersId]
            return value as? [String: AnyObject]
            
        case .AnonymousIntroduce(let type, let stype, let platform, let version):
            let value = [WSProfileApiManagerKey.type: type,
                         WSProfileApiManagerKey.stype: stype,
                         WSProfileApiManagerKey.platform: platform,
                         WSProfileApiManagerKey.version: version,
                         WSProfileApiManagerKey.token: NSNull()];
            return value;
        }
    }
}

enum WSProfileApiManagerKey {
    
    static let token               = "token";
    static let introduce           = "introduce";
    static let type                = "type";
    static let stype               = "stype";
    static let recipient           = "recipient";
    static let recipient_id        = "recipient_id";
    static let text                = "text";
    static let platform            = "platform";
    static let version             = "version";
    static let category            = "category";
    static let result              = "result";
    static let sender              = "sender";
    static let time                = "time";
    static let games               = "games";
    static let exclude             = "exclude";
    static let name                = "name";
    static let follow_id           = "follow_id";
    static let unfollow_id         = "unfollow_id";
    static let messages            = "messages";
    static let followers           = "followers";
    static let id                  = "id";
    static let angle               = "angle";
    static let disk                = "disk";
    static let move                = "move";
}

public enum EventTypeCategory {
    case Send
    case Recv
    case SendRecv
}


enum WebSocketStypeKey {
    
    static let invite_to_talk               = "invite_to_talk"
    static let invite_to_talk_response      = "invite_to_talk_response"
    static let invite_to_talk_request       = "invite_to_talk_request"
    static let looking_for_game_request     = "lets_play"
    static let looking_for_game_to_watch    = "lets_watch"
}

enum WebSocketTypeKey {
    static let invite_to_talk               = 220
    static let invite_to_talk_request       = 221
    static let invite_to_talk_response      = 222
    static let looking_for_game_response    = 10
    static let looking_for_game_request     = 11
    static let game_created                 = 12
    static let cancel_game_search           = 13
    static let looking_for_game_to_watch    = 14
    static let game_found                   = 15
    static let end_session                  = 29
}

enum WebSocketInviteResultKey {
    static let accept                       = 1
    static let deny                         = 2
    static let do_Not_Disturb               = 3
}
