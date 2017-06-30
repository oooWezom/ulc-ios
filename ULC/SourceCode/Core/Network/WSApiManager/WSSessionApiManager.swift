//
//  WSSessionApiManager.swift
//  ULC
//
//  Created by Alexey on 9/27/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

public enum WSSessionApiManager {
    case EndSession()
    case SendReadyMessage(Int)
    case SendMoveMessage(Int, Int)
    case SendRockSpockMessage(Int)
    case SendMessage(String)
    case DonePerfomance()
    case VotePlus(Int)
    case VoteMinus(Int)
    case FollowUser(Int)
    case UnfollowUser(Int)
    case LookingGameToWatch(Int, Int?)
}

extension WSSessionApiManager {
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .EndSession():
            return [WSProfileApiManagerKey.type: WebSocketTypeKey.end_session]
            
        case .SendReadyMessage(let userId):
            return [WSProfileApiManagerKey.type: SessionEvents.PLAYER_READY.rawValue, WSProfileApiManagerKey.stype: WSSessionApiManagerKey.ready, WSProfileApiManagerKey.id: userId]
            
        case .SendMoveMessage(let angle, let disk):
            return [WSProfileApiManagerKey.type: UnityEvents.MOVE.rawValue, WSProfileApiManagerKey.angle:angle, WSProfileApiManagerKey.disk:disk];
            
        case .SendRockSpockMessage(let move):
            return [WSProfileApiManagerKey.type: UnityEvents.MOVE.rawValue, WSProfileApiManagerKey.move : move]
            
        case .SendMessage(let textMessage):
            return [WSProfileApiManagerKey.type: SessionEvents.SESSION_MESSAGE.rawValue, WSProfileApiManagerKey.text:textMessage];
            
        case .DonePerfomance():
            return [WSProfileApiManagerKey.type: SessionEvents.LOSER_DONE_HIS_PERFORMANCE.rawValue];
            
        case .VotePlus(let userId):
            return  [WSProfileApiManagerKey.type: SessionEvents.VOTE_PLUS.rawValue, WSProfileApiManagerKey.id: userId];
            
        case .VoteMinus(let userId):
            return  [WSProfileApiManagerKey.type: SessionEvents.VOTE_MINUS.rawValue, WSProfileApiManagerKey.id: userId];
            
        case .FollowUser(let userId):
            return  [WSProfileApiManagerKey.type: SessionEvents.FOLLOW_USER.rawValue, WSProfileApiManagerKey.follow_id: userId];
            
        case .UnfollowUser(let userId):
            return  [WSProfileApiManagerKey.type: SessionEvents.UNFOLLOW_USER.rawValue, WSProfileApiManagerKey.follow_id: userId];
            
        case .LookingGameToWatch(let category, let except):
            
            if let except = except {
                return [WSProfileApiManagerKey.type: SessionEvents.LF_GAME_TO_WATCH.rawValue,
                        // WSTalkApiManagerKey.category: catefory,
                    WSTalkApiManagerKey.except: except];
            } else {
                return [WSProfileApiManagerKey.type: SessionEvents.LF_GAME_TO_WATCH.rawValue,
                        WSTalkApiManagerKey.category: category];
            }
        }
    }
}

enum WSSessionApiManagerKey {
    static let ready          = "ready"
    static let lets_watch     = "lets_watch"
}
