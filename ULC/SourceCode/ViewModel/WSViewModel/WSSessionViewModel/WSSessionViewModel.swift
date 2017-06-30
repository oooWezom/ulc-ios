//
//  WSSessionViewModel.swift
//  ULC
//
//  Created by Alex on 8/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import Starscream
import ObjectMapper

class WSSessionViewModel: WSGeneralViewModel {
    
    let (sessionStateSignal, sessionStateObserver)              = Signal<WSSessionState, ULCError>.pipe();
    let (gameStateSignal, gameStateObserver)                    = Signal<WSGameStateEntity, ULCError>.pipe();
    let (playerReadySignal, playerReadyObserver)                = Signal<WSPlayerReadyEntity, ULCError>.pipe();
    let (gameResultSignal, gameResultObserver)                  = Signal<WSGameResult, ULCError>.pipe();
    let (gameMessageSignal, gameMessageObserver)                = Signal<WSGameChatMessageEntity, ULCError>.pipe();
    let (gameRoundResultSignal, gameRoundResultObserver)        = Signal<WSRoundResultEntity, ULCError>.pipe();
    let (startRoundSignal, startRoundObserver)                  = Signal<WSRoundStartEntity, ULCError>.pipe();
    let (userDisconnectedSignal, userDisconnectedObserver)      = Signal<WSPlayerDisconnectedEntity, ULCError>.pipe();
    let (spectatorConnectedSignal, spectatorConnectedObserver)  = Signal<WSSspectatorSessionEntity, ULCError>.pipe();
    let (gameFoundSignal, gameFoundObserver)                    = Signal<WSGameCreateEntity, ULCError>.pipe();
    
    init(sessionId: Int) {
        super.init(channel: .Session, sessionId: sessionId)
        configureSignals();
    }
    
    override func configureSignals() {
        super.configureSignals();
        
        
        
        signal.observeResult { [unowned self] observer in
            
            guard let inputObject = observer.value as? WSBaseTypeEntity,
                let type = SessionEvents(rawValue: inputObject.type) else {
                    return;
            }
            
            switch type {
                
            //Happen evil error
            case SessionEvents.ERROR:
                break;
            //Game for watcher is found
            case SessionEvents.GAME_FOUND:
                self.gameFoundObserver.sendNext(observer.value as! WSGameCreateEntity);
                break;
            //Message in chat session
            case SessionEvents.SESSION_MESSAGE:
                self.gameMessageObserver.sendNext(observer.value as! WSGameChatMessageEntity);
                break;
            //Dublicate all messages and all connections to the server
            case SessionEvents.INSTANT_MESSAGE_SELF_ECHO:
                break;
            //Get a new instance message
            case SessionEvents.INSTANT_MESSAGE_NEW:
                break;
            //Start following a user
            case SessionEvents.FOLLOW_USER:
                break;
            //End followin a user
            case SessionEvents.UNFOLLOW_USER:
                break;
            //Get message about new follower
            case SessionEvents.NEW_FOLLOWER:
                break;
            //Follower is removed
            case SessionEvents.FOLLOWER_REMOVES:
                break;
            //Player is connented to the session
            case SessionEvents.PLAYER_CONNECTED_TO_SESSION:
                break;
            //Player is reconnected to the session
            case SessionEvents.PLAYER_RECONNECTED_TO_SESSION:
                break;
            //Spectator is connected to the session
            case SessionEvents.SPECTATOR_CONNECTED_TO_SESSION:
                self.spectatorConnectedObserver.sendNext(observer.value as! WSSspectatorSessionEntity)
                break;
            //Some user leave the game session
            case SessionEvents.SESSION_USER_DISCONNECTED:
                self.userDisconnectedObserver.sendNext(observer.value as! WSPlayerDisconnectedEntity)
                break;
            //State of the game session
            case .SESSION_STATE:
                self.sessionStateObserver.sendNext(observer.value as! WSSessionState);
                break;
                
            case .BEGIN_EXECUTION:
                self.sessionStateObserver.sendNext(observer.value as! WSSessionState);
                break;
                
            case .LOSER_DONE_HIS_PERFORMANCE:
                self.sessionStateObserver.sendNext(observer.value as! WSSessionState);
                break;
            //Results of the game session
            case SessionEvents.GAME_RESULTS:
                self.gameResultObserver.sendNext(observer.value as! WSGameResult);
                break;
            //Sate of the game(not session)
            case SessionEvents.GAME_STATE:
                self.gameStateObserver.sendNext(observer.value as! WSGameStateEntity);
                break;
            //I don't why this but I keep is theire
            case SessionEvents.PLAYER_READY:
                self.playerReadyObserver.sendNext(observer.value as! WSPlayerReadyEntity);
                break;
                
            case SessionEvents.GAME_RESULT:
                self.gameRoundResultObserver.sendNext(observer.value as! WSRoundResultEntity);
                break;
                
            case SessionEvents.ROUND_START:
                self.startRoundObserver.sendNext(observer.value as! WSRoundStartEntity);
                break;
                
            default:
                break;
            }
        }
    }
    
    func lookingGameToWatch(category: Int, except: Int?){
        if let dictionaryParameters = WSSessionApiManager.LookingGameToWatch(category, except!).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func endSession() {
        if let dictionaryParameters = WSSessionApiManager.EndSession().parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendReadyMessage(id:Int?) {
        if let id = id {
            if let dictionaryParameters = WSSessionApiManager.SendReadyMessage(id).parameters {
                writeDataToSocket(dictionaryParameters);
            }
        }
    }
    
    func sendMoveRockSpockMessage(model:AnyObject){ //WSGameMoveMessage
        guard let model = model as? MoveRockSpockMessage else{return}
        if let dictionaryParameters = WSSessionApiManager.SendRockSpockMessage(model.move).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendMoveMessage(model:AnyObject){ //WSGameMoveMessage
        guard let model = model as? WSGameMoveMessage else{return}
        if let dictionaryParameters = WSSessionApiManager.SendMoveMessage(model.angle, model.disk).parameters {
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    func sendMessage(textMessage:String){
        if let dictionaryParameters = WSSessionApiManager.SendMessage(textMessage).parameters{
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func donePerfomance(){
        if let dictionaryParameters = WSSessionApiManager.DonePerfomance().parameters{
            writeDataToSocket(dictionaryParameters)
        }
    }
    
    func votePlus(id:Int?){
        if let id = id {
            if let dictionaryParameters = WSSessionApiManager.VotePlus(id).parameters{
                writeDataToSocket(dictionaryParameters)
            }
        }
    }
    
    func voteMinus(id:Int?){
        if let id = id {
            if let dictionaryParameters = WSSessionApiManager.VoteMinus(id).parameters{
                writeDataToSocket(dictionaryParameters)
            }
        }
    }
    
    func follow(id:Int?){
        if let id = id {
            if let dictionaryParameters = WSSessionApiManager.FollowUser(id).parameters{
                writeDataToSocket(dictionaryParameters)
            }
        }
    }
    
    func unfollow(id:Int?){
        if let id = id {
            if let dictionaryParameters = WSSessionApiManager.UnfollowUser(id).parameters{
                writeDataToSocket(dictionaryParameters)
            }
        }
    }
}
