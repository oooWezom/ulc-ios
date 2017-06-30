//
//  WSTalkViewModel.swift
//  ULC
//
//  Created by Alex on 8/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper
import ReactiveCocoa
import Result

enum TalkSessionState: Int {
    case NONE_STATE
    case STREAMER_CONNECTED
    case STREAMER_RECONNECTED
    case STREAMER_DISCONNECTED
    case SPECTATOR_CONNECTED
    case SPECTATOR_DISCONNECTED
    case TALK_CLOSED
}

class WSTalkViewModel: WSGeneralViewModel {
    
    let talkMessageEchoHandler:(signal:Signal<WSTalkChatMessageEntity, ULCError>, observer:Observer<WSTalkChatMessageEntity, ULCError>) = Signal<WSTalkChatMessageEntity, ULCError>.pipe();
    let errorMessageHandler:(signal:Signal<WSError, ULCError>, observer:Observer<WSError, ULCError>)                      = Signal<WSError, ULCError>.pipe();
    let donateMessageHandler:(signal:Signal<WSDonateMessage, ULCError>, observer:Observer<WSDonateMessage, ULCError>)                   = Signal<WSDonateMessage, ULCError>.pipe();
    //Streamer signals
    let streamerConnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)            = Signal<WSTalkStreamerConnected, ULCError>.pipe();
    let streamerReconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)        = Signal<WSTalkStreamerConnected, ULCError>.pipe();
    let streamerDisconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)      = Signal<WSTalkStreamerConnected, ULCError>.pipe();
    let streamClosedByReportHandler:(signal:Signal<WSBaseTypeEntity, ULCError>, observer:Observer<WSBaseTypeEntity, ULCError>) = Signal<WSBaseTypeEntity, ULCError>.pipe();
    //Spectator signals
    let spectatorConnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)          = Signal<WSTalkStreamerConnected, ULCError>.pipe();
    let spectatorDisconnectedHandler:(signal:Signal<WSTalkStreamerConnected, ULCError>, observer:Observer<WSTalkStreamerConnected, ULCError>)    = Signal<WSTalkStreamerConnected, ULCError>.pipe();
    //Talk Signals
    let talkAddedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) = Signal<WSTalkAdded, ULCError>.pipe();
    let talkStateHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) = Signal<WSTalkAdded, ULCError>.pipe();
    let talkRemovedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>) = Signal<WSTalkAdded, ULCError>.pipe();
    let talkClosedHandler:(signal:Signal<WSTalkAdded, ULCError>, observer:Observer<WSTalkAdded, ULCError>)  = Signal<WSTalkAdded, ULCError>.pipe();
    let talkLikesHandler:(signal: Signal<WSTalkLikes, ULCError>, observer: Observer<WSTalkLikes, ULCError>) = Signal<WSTalkLikes, ULCError>.pipe();
    //
    let switchTalkHandler:(signal:Signal<WSSwitchTalk, ULCError>, observer:Observer<WSSwitchTalk, ULCError>) = Signal<WSSwitchTalk, ULCError>.pipe();
    let updateTalkDataHandler:(signal:Signal<WSUpdateTalkData, ULCError>, observer:Observer<WSUpdateTalkData, ULCError>) = Signal<WSUpdateTalkData, ULCError>.pipe();
    let findTalkHandler:(signal:Signal<WSFindTalk, ULCError>, observer:Observer<WSFindTalk, ULCError>) = Signal<WSFindTalk, ULCError>.pipe();
    //Invite
    let inviteToTalkHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) = Signal<WSInviteEntity, ULCError>.pipe();
    let inviteToTalkRequestHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) = Signal<WSInviteEntity, ULCError>.pipe();
    let inviteToTalkResponseHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) = Signal<WSInviteEntity, ULCError>.pipe();
    let findTalkPartnerHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) = Signal<WSFindTalkPartner, ULCError>.pipe();
    let cancelFindTalkPartnerHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) = Signal<WSFindTalkPartner, ULCError>.pipe();
    let sendDonateMessageHandler:(signal:Signal<WSFindTalkPartner, ULCError>, observer:Observer<WSFindTalkPartner, ULCError>) = Signal<WSFindTalkPartner, ULCError>.pipe();
    
   
    init(sessionId: Int) {
        super.init(channel: .Talk, sessionId: sessionId)
        configureSignals();
    }
    
    override func configureSignals() {
        super.configureSignals();
        
        signal.observeResult { [unowned self] observer in
            
            guard   let inputObject = observer.value as? WSBaseTypeEntity,
                let type = TalkEvents(rawValue: inputObject.type) else {
                    return;
            }
            
            switch type {
                
            case TalkEvents.TALK_STATE:
                self.talkStateHandler.observer.sendNext(observer.value as! WSTalkAdded)
                
            case TalkEvents.TALK_MESSAGE:
                self.talkMessageEchoHandler.observer.sendNext(observer.value as! WSTalkChatMessageEntity);
                
            case TalkEvents.ERROR:
                self.errorMessageHandler.observer.sendNext(observer.value as! WSError)
                
            case TalkEvents.TALK_STREAMER_CONNECTED:
                self.streamerConnectedHandler.observer.sendNext(observer.value as! WSTalkStreamerConnected)
                
            case TalkEvents.TALK_STREAMER_RECONNECTED:
                self.streamerReconnectedHandler.observer.sendNext(observer.value as! WSTalkStreamerConnected)
                
            case TalkEvents.TALK_STREAMER_DISCONNECTED:
                self.streamerDisconnectedHandler.observer.sendNext(observer.value as! WSTalkStreamerConnected)
                
            case TalkEvents.TALK_SPECTATOR_CONNECTED:
                self.spectatorConnectedHandler.observer.sendNext(observer.value as! WSTalkStreamerConnected)
                
            case TalkEvents.TALK_SPECTATOR_DISCONNECTED:
                self.spectatorDisconnectedHandler.observer.sendNext(observer.value as! WSTalkStreamerConnected)
                
            case TalkEvents.TALK_ADDED:
                self.talkAddedHandler.observer.sendNext(observer.value as! WSTalkAdded)
                
            case TalkEvents.TALK_REMOVED:
                self.talkRemovedHandler.observer.sendNext(observer.value as! WSTalkAdded)
                
            case TalkEvents.TALK_CLOSED:
                self.talkClosedHandler.observer.sendNext(observer.value as! WSTalkAdded)
                
            case TalkEvents.SWITCH_TALK:
                self.switchTalkHandler.observer.sendNext(observer.value as! WSSwitchTalk)
                
            case TalkEvents.UPDATE_TALK_DATA:
                self.updateTalkDataHandler.observer.sendNext(observer.value as! WSUpdateTalkData)
                
            case TalkEvents.TALK_LIKES:
                self.talkLikesHandler.observer.sendNext(observer.value as! WSTalkLikes)
                
            case TalkEvents.FIND_TALK:
                self.findTalkHandler.observer.sendNext(observer.value as! WSFindTalk)
                
            case TalkEvents.INVITE_TO_TALK:
                self.inviteToTalkHandler.observer.sendNext(observer.value as! WSInviteEntity)
                
            case TalkEvents.INVITE_TO_TALK_REQUEST:
                self.inviteToTalkRequestHandler.observer.sendNext(observer.value as! WSInviteEntity)
                
            case TalkEvents.INVITE_TO_TALK_RESPONSE:
                self.inviteToTalkResponseHandler.observer.sendNext(observer.value as! WSInviteEntity)
                
            case TalkEvents.FIND_TALK_PARTNER:
                self.findTalkPartnerHandler.observer.sendNext(observer.value as! WSFindTalkPartner)
                
            case TalkEvents.CANCEL_FIND_TALK_PARTNER:
                self.cancelFindTalkPartnerHandler.observer.sendNext(observer.value as! WSFindTalkPartner)
                
            case TalkEvents.SEND_DONATE_MESSAGE:
                self.sendDonateMessageHandler.observer.sendNext(observer.value as! WSFindTalkPartner)
                
            case TalkEvents.DONATE_MESSAGE:
                self.donateMessageHandler.observer.sendNext(observer.value as! WSDonateMessage)
                
            case TalkEvents.STREAM_CLOSED_BY_REPORTS:
                self.streamClosedByReportHandler.observer.sendNext(observer.value as! WSBaseTypeEntity)
                
            default:
                break;
            }
        }
    }
    
    func sendMessage(text: String) {
        if let dictionaryParameters = WSTalkApiManager.SendMessage(text).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func leaveTalk() {
        if let dictionaryParameters = WSTalkApiManager.LeaveTalk().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendDonateMessage(message: String) {
        if let dictionaryParameters = WSTalkApiManager.SendDonateMessage(message).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func detachTalk() {
        if let dictionaryParameters = WSTalkApiManager.DetachTalk().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func swithTalk(nextSessionID: Int) {
        if let dictionaryParameters = WSTalkApiManager.SwitchTalk(nextSessionID).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func updateTalkData(newTalkName: String) {
        if let dictionaryParameters = WSTalkApiManager.UpdateTalkData(newTalkName).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendTalkLikes(likesCount: Int) {
        if let dictionaryParameters = WSTalkApiManager.TalkLikes(likesCount).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func findTalk(category: Int, except: Int?) {
        if let dictionaryParameters = WSTalkApiManager.FindTalk(category, except).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func inviteToTalkSession(recipient: Int, category: Int) {
        if let dictionaryParameters = WSTalkApiManager.InviteTalkPartner(recipient, category).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func acceptTalkSessionInvite(senderId: Int) {
        if let dictionaryParameters = WSTalkApiManager.InviteToTalkResponseAccept(senderId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func denyTalkSessionInvite(senderId: Int) {
        if let dictionaryParameters = WSTalkApiManager.InviteToTalkResponseDeny(senderId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func inviteResponseNotDisturb(timeMinutes: Int, senderId: Int) {
        let timeInSeconds = timeMinutes * 60
        if let dictionaryParameters = WSTalkApiManager.InviteResponseNotDisturb(timeInSeconds, senderId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func findTalkPartner() {
        if let dictionaryParameters = WSTalkApiManager.FindTalkPartner().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func cancelFindTalkPartner() {
        if let dictionaryParameters = WSTalkApiManager.CancelFindTalkPartner().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func reportUserBehavior(sessionId: Int, userId: Int?, categoryId: Int, comment: String?) {
        if let dictionaryParameters = WSTalkApiManager.ReportUserBehavior(sessionId, userId, categoryId, comment).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func getTalkState() {
        if let dictionaryParameters = WSTalkApiManager.GetTalkState().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendTalkOppinentLikes(talkID: Int, likesCount: Int) {
        if let dictionaryParameters = WSTalkApiManager.TalkLikesOpponent(talkID, likesCount).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
}
