//
//  WSTalkProtocol.swift
//  ULC
//
//  Created by Cruel Ultron on 4/26/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol WSTalking {
    
    var talkMessageEchoHandler:(signal:Signal<WSTalkChatMessageEntity, ULCError>, observer:Observer<WSTalkChatMessageEntity, ULCError>) { get };
    var errorMessageHandler:(signal:Signal<WSError, ULCError>, observer:Observer<WSError, ULCError>) { get };
    var donateMessageHandler:(signal:Signal<WSDonateMessage, ULCError>, observer:Observer<WSDonateMessage, ULCError>) { get };
    //Streamer signals
    var streamerConnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>) { get };
    var streamerReconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)  { get };
    var streamerDisconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)     { get };
    var streamClosedByReportHandler:(signal:Signal<WSBaseTypeEntity, ULCError>, observer:Observer<WSBaseTypeEntity, ULCError>) { get };
    //Spectator signals
    var spectatorConnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>) { get };
    var spectatorDisconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)    { get };
    //Talk Signals
    var talkAddedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) { get };
    var talkStateHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) { get };
    var talkRemovedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) { get };
    var talkClosedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>)  { get };
    var talkLikesHandler:(signal: Signal<WSTalkLikes, ULCError>, observer: Observer<WSTalkLikes, ULCError>) { get };
    //
    var switchTalkHandler:(signal:Signal<WSSwitchTalk, ULCError>, observer:Observer<WSSwitchTalk, ULCError>) { get };
    var updateTalkDataHandler:(signal:Signal<WSUpdateTalkData, ULCError>, observer:Observer<WSUpdateTalkData, ULCError>) { get };
    var findTalkHandler:(signal:Signal<WSFindTalk, ULCError>, observer:Observer<WSFindTalk, ULCError>) { get };
    //Invite
    var inviteToTalkHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var inviteToTalkRequestHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var inviteToTalkResponseHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) { get };
    var findTalkPartnerHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) { get };
    var cancelFindTalkPartnerHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) { get };
    var sendDonateMessageHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) { get };
}
