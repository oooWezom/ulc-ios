//
//  WSProfileViewModel.swift
//  ULC
//
//  Created by Alex on 7/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import Starscream
import ObjectMapper
import ReactiveCocoa
import Result

class WSProfileViewModel: WSGeneralViewModel, WSProfiling {

    let lookingForGameHandler:(signal:Signal<WSLookingForGame, ULCError>, observer:Observer<WSLookingForGame, ULCError>) = Signal<WSLookingForGame, ULCError>.pipe();
    
    let followerHandler: (signal: Signal<WSFollowerEntity, ULCError>, observer:Observer<WSFollowerEntity, ULCError>) = Signal<WSFollowerEntity, ULCError>.pipe();
    let newInstantMessageHadler: (signal:Signal<WSNewInstantMessage, ULCError>, observer:Observer<WSNewInstantMessage, ULCError>) = Signal<WSNewInstantMessage, ULCError>.pipe();
    
    let createGameResultHandler:(signal:Signal<WSGameCreateEntity, ULCError>, observer:Observer<WSGameCreateEntity, ULCError>) = Signal<WSGameCreateEntity, ULCError>.pipe();
    let instantMessageHandler:(signal:Signal<WSInstantMessageEcho, ULCError>, observer:Observer<WSInstantMessageEcho, ULCError>) = Signal<WSInstantMessageEcho, ULCError>.pipe();
    let readInstantMessageHandler:(signal:Signal<WSInstantMessageRead, ULCError>, observer:Observer<WSInstantMessageRead, ULCError>) = Signal<WSInstantMessageRead, ULCError>.pipe();
    let inviteToTalkHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>) = Signal<WSInviteEntity, ULCError>.pipe();
    let inviteToTalkRequestHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>)  = Signal<WSInviteEntity, ULCError>.pipe();
    let inviteToTalkResponseHandler:(signal:Signal<WSInviteEntity, ULCError>, observer:Observer<WSInviteEntity, ULCError>)  = Signal<WSInviteEntity, ULCError>.pipe();
    let createTalkResultHandler:(signal:Signal<WSCreateTalkMessage, ULCError>, observer:Observer<WSCreateTalkMessage, ULCError>) = Signal<WSCreateTalkMessage, ULCError>.pipe();
    let followUserHandler:(signal:Signal<WSFollowEntity, ULCError>, observer:Observer<WSFollowEntity, ULCError>) = Signal<WSFollowEntity, ULCError>.pipe();
    let unfollowUserHandler:(signal:Signal<WSUnfollowEntity, ULCError>, observer:Observer<WSUnfollowEntity, ULCError>)               = Signal<WSUnfollowEntity, ULCError>.pipe();
    
    let notifyGameStartedHandler:(signal:Signal<WSNotifyGameEntity, ULCError>, observer:Observer<WSNotifyGameEntity, ULCError>)        = Signal<WSNotifyGameEntity, ULCError>.pipe();
    let notifyTalkStartedHandler:(signal:Signal<WSNotifyTalkEntity, ULCError>, observer:Observer<WSNotifyTalkEntity, ULCError>) = Signal<WSNotifyTalkEntity, ULCError>.pipe();
    
    override init() {
        super.init(channel: Channel.Profile, sessionId: nil)
        configureSignals();
    }
    
    override func configureSignals() {
        super.configureSignals();
        
        signal.observeResult { [unowned self] observer in
            
            guard   let inputObject = observer.value as? WSBaseTypeEntity,
                let type = ProfileEvents(rawValue: inputObject.type) else {
                    return;
            }
            
            switch type {
                
            case ProfileEvents.INSTANT_MESSAGE_SELF_ECHO:
                self.instantMessageHandler.observer.sendNext(observer.value as! WSInstantMessageEcho);
                
            case ProfileEvents.INSTANT_MESSAGE_NEW:
                let newInstantMessageObserver = self.newInstantMessageHadler.1;
                newInstantMessageObserver.sendNext(observer.value as! WSNewInstantMessage);
                
            case ProfileEvents.INSTANT_MESSAGE_MARK_READ:
                self.readInstantMessageHandler.observer.sendNext(observer.value as! WSInstantMessageRead);
                
            case ProfileEvents.INVITE_TO_TALK:
                self.inviteToTalkHandler.observer.sendNext(observer.value as! WSInviteEntity)
                
            case ProfileEvents.INVITE_TO_TALK_REQUEST:
                self.inviteToTalkRequestHandler.observer.sendNext(observer.value as! WSInviteEntity)
                
            case ProfileEvents.INVITE_TO_TALK_RESPONSE:
                self.inviteToTalkResponseHandler.observer.sendNext(observer.value as! WSInviteEntity)
                break;

            case ProfileEvents.LOOKING_FOR_GAME_RESULT:
                self.lookingForGameHandler.observer.sendNext(observer.value as! WSLookingForGame);
                break;

            case ProfileEvents.GAME_CREATED:
                self.createGameResultHandler.observer.sendNext(observer.value as! WSGameCreateEntity);
                break;

            case ProfileEvents.CREATE_TALK:
                self.createTalkResultHandler.observer.sendNext(observer.value as! WSCreateTalkMessage)
                
            case ProfileEvents.FOLLOW_USER:
                self.followUserHandler.observer.sendNext(observer.value as! WSFollowEntity)
                
            case ProfileEvents.UNFOLLOW_USER:
                self.unfollowUserHandler.observer.sendNext(observer.value as! WSUnfollowEntity)
                
            case ProfileEvents.NOTIFY_GAME_STARTED:
                self.notifyGameStartedHandler.observer.sendNext(observer.value as! WSNotifyGameEntity)
                
            case ProfileEvents.NOTIFY_TALK_STARTED:
                self.notifyTalkStartedHandler.observer.sendNext(observer.value as! WSNotifyTalkEntity)
                
            case ProfileEvents.NEW_FOLLOWER:
                let newFollowerObserver = self.followerHandler.1;
                newFollowerObserver.sendNext(observer.value as! WSFollowerEntity)
                
            default:
                break;
            }
        }
    }
    
    func inviteToTalkSession(recipient: Int, category: Int) {
        
        if let dictionaryParameters = WSProfielApiManager.InviteTalkPartner(recipient, category).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func acceptTalkSessionInvite(senderId: Int) {
        
        if let dictionaryParameters = WSProfielApiManager.InviteToTalkResponseAccept(senderId).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func denyTalkSessionInvite(senderId: Int) {
        
        if let dictionaryParameters = WSProfielApiManager.InviteToTalkResponseDeny(senderId).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func inviteResponseNotDisturb(timeMinutes: Int, senderId: Int) {
        
        let timeInSeconds = timeMinutes * 60
        if let dictionaryParameters = WSProfielApiManager.InviteResponseNotDisturb(timeInSeconds, senderId).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }

    func lookingForGame(games: [Int]) {
        if let dictionaryParameters = WSProfielApiManager.LookingForGame(games).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }

    func cancelGameSearch() {
        if let dictionaryParameters = WSProfielApiManager.CancelGameSearch().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func createTwoTalk(category: Int, name: String) {
        
        if let dictionaryParameters = WSProfielApiManager.CreateTwoTalk(category, name).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func lookingForGameToWatch(exclude: [Int]) {
        if let dictionaryParameters = WSProfielApiManager.LookingForGameToWatch(exclude).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }

    func followUser(userId: Int) {
        if let dictionaryParameters = WSProfielApiManager.FollowUser(userId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func unfollowUser(userId: Int) {
        if let dictionaryParameters = WSProfielApiManager.UnfollowUser(userId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func readInstantMessage(message: [Int]) {
        if let dictionaryParameters = WSProfielApiManager.ReadInstantMessage(message).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func followerAcknowledged(followersId: [Int]) {
        
        if let dictionaryParameters = WSProfielApiManager.FollowerAcknowledged(followersId).parameters {
            writeDataToSocket(dictionaryParameters)
        }
    }
}
