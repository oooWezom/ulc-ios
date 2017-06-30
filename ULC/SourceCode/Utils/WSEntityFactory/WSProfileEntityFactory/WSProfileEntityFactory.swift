//
//  WSProfileEntityFactory.swift
//  ULC
//
//  Created by Alex on 8/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper

class WSProfileEntityFactory: EntityCreatable {
    
    func createEntity(dictionary: [String: AnyObject]) -> Mappable? {
        
        guard let code = dictionary["type"] as? Int where code > 0 else {
            return nil;
        }
        
        guard let eventCode = ProfileEvents(rawValue: code) else {
            return nil;
        }
        
        switch eventCode {
            
        case ProfileEvents.INSTANT_MESSAGE:
            return Mapper<WSInstantMessage>().map(dictionary);
            
        case ProfileEvents.INSTANT_MESSAGE_SELF_ECHO:
            return Mapper<WSInstantMessageEcho>().map(dictionary);
            
        case ProfileEvents.INSTANT_MESSAGE_NEW:
            return Mapper<WSNewInstantMessage>().map(dictionary);
            
        case ProfileEvents.INSTANT_MESSAGE_MARK_READ:
            return Mapper<WSInstantMessageRead>().map(dictionary)

        case ProfileEvents.INVITE_TO_TALK, ProfileEvents.INVITE_TO_TALK_REQUEST, ProfileEvents.INVITE_TO_TALK_RESPONSE:
            return Mapper<WSInviteEntity>().map(dictionary);
            
        case ProfileEvents.LOOKING_FOR_GAME_RESULT:
            return Mapper<WSLookingForGame>().map(dictionary)

        case ProfileEvents.CREATE_TALK:
            return Mapper<WSCreateTalkMessage>().map(dictionary);
            
        case ProfileEvents.GAME_CREATED:
            return Mapper<WSGameCreateEntity>().map(dictionary);

        case ProfileEvents.FOLLOW_USER:
            return Mapper<WSFollowEntity>().map(dictionary)

        case ProfileEvents.UNFOLLOW_USER:
            return Mapper<WSUnfollowEntity>().map(dictionary)


        case ProfileEvents.NOTIFY_GAME_STARTED:
            return Mapper<WSNotifyGameEntity>().map(dictionary)

        case ProfileEvents.NOTIFY_TALK_STARTED:
            return Mapper<WSNotifyTalkEntity>().map(dictionary)

        case ProfileEvents.NEW_FOLLOWER:
            return Mapper<WSFollowerEntity>().map(dictionary)

        default:
            return nil;
        }
    }
}
