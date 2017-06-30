//
//  WSProfileProtocol.swift
//  ULC
//
//  Created by Cruel Ultron on 4/26/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol WSProfiling: WSViewModelTargetType, VersionApiCheckable {
    
    var lookingForGameHandler:(signal:Signal<WSLookingForGame, ULCError>, observer:Observer<WSLookingForGame, ULCError>) { get };
    
    var followerHandler: (signal: Signal<WSFollowerEntity, ULCError>, observer:Observer<WSFollowerEntity, ULCError>) { get };
    var newInstantMessageHadler: (signal:Signal<WSNewInstantMessage, ULCError>, observer:Observer<WSNewInstantMessage, ULCError>) { get };
    
    var createGameResultHandler:(signal:Signal<WSGameCreateEntity, ULCError>, observer:Observer<WSGameCreateEntity, ULCError>) { get }
    var instantMessageHandler:(signal:Signal<WSInstantMessageEcho, ULCError>, observer:Observer<WSInstantMessageEcho, ULCError>) { get };
    var readInstantMessageHandler:(signal:Signal<WSInstantMessageRead, ULCError>, observer:Observer<WSInstantMessageRead, ULCError>) { get };
    var inviteToTalkHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var inviteToTalkRequestHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var inviteToTalkResponseHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var createTalkResultHandler:(signal:Signal<WSCreateTalkMessage, ULCError>, observer:Observer<WSCreateTalkMessage, ULCError>) { get };
    var followUserHandler:(signal:Signal<WSFollowEntity, ULCError>, observer:Observer<WSFollowEntity, ULCError>) { get };
    var unfollowUserHandler:(signal:Signal<WSUnfollowEntity, ULCError>, observer:Observer<WSUnfollowEntity, ULCError>) { get };
    
    var notifyGameStartedHandler:(signal:Signal<WSNotifyGameEntity, ULCError>, observer:Observer<WSNotifyGameEntity, ULCError>) { get };
    var notifyTalkStartedHandler:(signal:Signal<WSNotifyTalkEntity, ULCError>, observer:Observer<WSNotifyTalkEntity, ULCError>) { get };
    
}
