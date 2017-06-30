//
//  WSTalkEntityFactory.swift
//  ULC
//
//  Created by Vitya on 9/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSTalkEntityFactory: EntityCreatable {
    
    func createEntity(dictionary: [String: AnyObject]) -> Mappable? {
        
        guard let code = dictionary["type"] as? Int where code > 0 else {
            return nil;
        }
        
        guard let eventCode = TalkEvents(rawValue: code) else {
            return nil;
        }
        
        switch eventCode {
            
        case TalkEvents.TALK_MESSAGE:
            return Mapper<WSTalkChatMessageEntity>().map(dictionary);
            
        case TalkEvents.ERROR:
            return Mapper<WSError>().map(dictionary);
            
        case TalkEvents.DONATE_MESSAGE:
            return Mapper<WSDonateMessage>().map(dictionary);
            
        case TalkEvents.TALK_STREAMER_CONNECTED:
            return Mapper<WSTalkStreamerConnected>().map(dictionary);
            
        case TalkEvents.TALK_STREAMER_RECONNECTED:
            return Mapper<WSTalkStreamerConnected>().map(dictionary);
            
        case TalkEvents.TALK_STREAMER_DISCONNECTED:
            return Mapper<WSTalkStreamerConnected>().map(dictionary);
            
        case TalkEvents.TALK_SPECTATOR_CONNECTED:
            return Mapper<WSTalkStreamerConnected>().map(dictionary);
            
        case TalkEvents.TALK_SPECTATOR_DISCONNECTED:
            return Mapper<WSTalkStreamerConnected>().map(dictionary);
            
        case .TALK_ADDED, .TALK_STATE, .TALK_REMOVED, .TALK_CLOSED:
            return Mapper<WSTalkAdded>().map(dictionary);
            
        case .SWITCH_TALK:
            return Mapper<WSSwitchTalk>().map(dictionary)
            
        case .UPDATE_TALK_DATA:
            return Mapper<WSUpdateTalkData>().map(dictionary)
            
        case .FIND_TALK_PARTNER, .CANCEL_FIND_TALK_PARTNER, .SEND_DONATE_MESSAGE:
            return Mapper<WSFindTalkPartner>().map(dictionary)
            
        case .INVITE_TO_TALK, .INVITE_TO_TALK_REQUEST, .INVITE_TO_TALK_RESPONSE:
            return Mapper<WSInviteEntity>().map(dictionary)
            
        case .STREAM_CLOSED_BY_REPORTS:
            return Mapper<WSBaseTypeEntity>().map(dictionary)
            
        case .FIND_TALK:
            return Mapper<WSFindTalk>().map(dictionary)
            
        case .TALK_LIKES:
            return Mapper<WSTalkLikes>().map(dictionary)
            
            
        default:
            return nil;
        }
    }
}
