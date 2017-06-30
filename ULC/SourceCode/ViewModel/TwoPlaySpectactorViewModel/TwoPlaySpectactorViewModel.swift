//
//  TwoPlaySpectactorView.swift
//  ULC
//
//  Created by Alexey on 10/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper

class TwoPlaySpectactorViewModel :GeneralViewModel {
    
    var game            : AnyProperty<WSGameCreateEntity?> {return AnyProperty(_game)}
    var currentPlayer   : AnyProperty<WSPlayerEntity?> {return AnyProperty(_currentPlayer)}
    var opponentPlayer  : AnyProperty<WSPlayerEntity?> {return AnyProperty(_opponentPlayer)}
    
    private var _game                                           = MutableProperty<WSGameCreateEntity?>(nil);
    private var _currentPlayer                                  = MutableProperty<WSPlayerEntity?>(nil);
    private var _opponentPlayer                                 = MutableProperty<WSPlayerEntity?>(nil);
    
    let (gameMessageSignal, gameMessageObserver)                = Signal<WSGameChatMessageEntity, ULCError>.pipe();
    let (spectatorConnectedSignal, spectatorConnectedObserver)  = Signal<WSSspectatorSessionEntity, ULCError>.pipe();
    let (playerDisconnectedSignal, playerDisconnectedObserver)  = Signal<WSPlayerDisconnectedEntity, ULCError>.pipe();
    let (gameWinnerResultSignal, gameWinnerResultObserver)      = Signal<[Int], ULCError>.pipe();
    let (gameRoundResultSignal, gameRoundResultObserver)        = Signal<WSRoundResultEntity, ULCError>.pipe();
    let (gameStateSignal, gameStateObserver)                    = Signal<WSGameStateEntity, ULCError>.pipe();
    let (gameFinalResultSignal, gameFinalResultObserver)        = Signal<WSGameResult, ULCError>.pipe();
    let (sessionStateSignal, sessionStateObserver)              = Signal<WSSessionState, ULCError>.pipe();
    let (gameFoundSignal, gameFoundObserver)                    = Signal<WSGameCreateEntity, ULCError>.pipe();
    let (playerReadySignal, playerReadyObserver)                = Signal<WSPlayerReadyEntity, ULCError>.pipe();
    let (gameRoundStartSignal, gameRoundStartObserver)          = Signal<WSRoundStartEntity, ULCError>.pipe();
    
    var wsSessionViewModel:WSSessionViewModel?
    var tmpArr = [Int]()
    
    func initData(model: AnyObject?) {
        guard let game = model as? WSGameCreateEntity else {
            return
        }
        self._game.value = game
    }
    
    func fetchGameData() -> SignalProducer<(WSGameCreateEntity), ULCError> {
        return SignalProducer { [unowned self]
            observer, disposable in
            
            if let game = self._game.value {
                if let players = game.game?.players {
                    players.forEach { it in
                        if it.id == self.currentId {
                            self._currentPlayer.value = it
                        } else {
                            self._opponentPlayer.value = it
                        }
                    }
                }
                observer.sendCompleted();
            }
        }
    }
    
    func handleUnityMessage(message: AnyObject) {
        
        if let jsonResult = convertStringToDictionary(message as!  String) {
            
            if let category = Mapper<UnityMessage>().map(jsonResult) {
                if let type = category.type{
                    switch type {
                    case 0:
                        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
                            self?.wsSessionViewModel!.sendReadyMessage(self?.currentPlayer.value?.id)
                        }
                        break
                    case 1:
                        if let move = Mapper<UnityMessage>().map(jsonResult){
                            if let message = move.message{
                                if let messageResult = convertStringToDictionary(message) {
                                    if let moveMessage = Mapper<WSGameMoveMessage>().map(messageResult) {
                                        wsSessionViewModel!.sendMoveMessage(moveMessage); // MARK force unwrap
                                    }
                                }
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func initSessionViewModel(sessionID:Int) {
        wsSessionViewModel = WSSessionViewModel(sessionId: sessionID)
        
        if let ws = wsSessionViewModel{
            
            ws.startRoundSignal
                .observeOn(UIScheduler())
                .observeResult { [unowned self] observer in
                    
                    guard let message = observer.value else {
                        return
                    }
                    self.gameRoundStartObserver.sendNext(message)
            }
            
            ws.gameFoundSignal
                .observeOn(UIScheduler())
                .observeResult{ [unowned self] observer in
                    
                    guard let message = observer.value else {
                        return
                    }
                    
                    self.gameFoundObserver.sendNext(message)
            }
            
            ws.gameStateSignal
                .observeOn(UIScheduler())
                .observeResult{ [unowned self] observer in
                    
                    guard let message = observer.value else {
                        return
                    }
                    
                    self.gameStateObserver.sendNext(message)
            }
            
            ws.gameMessageSignal
                .observeOn(UIScheduler())
                .observeResult{ [weak self] observer in
                    
                    guard let message = observer.value else {
                        return
                    }
                    
                    self?.gameMessageObserver.sendNext(message)
            }
            
            ws.spectatorConnectedSignal
                .observeOn(UIScheduler())
                .observeResult{[weak self] observer in
                    guard let message = observer.value else {
                        return
                    }
                    self?.spectatorConnectedObserver.sendNext(message)
            }
            
            ws.userDisconnectedSignal
                .observeOn(UIScheduler())
                .observeResult{[weak self] observer in
                    guard let message = observer.value else {
                        return
                    }
                    self?.playerDisconnectedObserver.sendNext(message)
            }
            
            ws.gameRoundResultSignal
                .observeOn(UIScheduler())
                .observeResult { [weak self] observer in
                    guard let message = observer.value, let strongSelf = self else {
                        return
                    }
                    
                    self?.gameRoundResultObserver.sendNext(message)
                    self?.tmpArr.append(message.winner_id)
                    self?.gameWinnerResultObserver.sendNext(strongSelf.tmpArr)
            }
            
            ws.gameResultSignal.observeOn(UIScheduler())
                .observeResult{[unowned self] observer in
                    guard let message = observer.value else {
                        return
                    }
                    self.gameFinalResultObserver.sendNext(message)
            }
            
            ws.sessionStateSignal
                .observeOn(UIScheduler())
                .observeResult{[unowned self] observer in
                    guard let message = observer.value else {
                        return
                    }
                    self.sessionStateObserver.sendNext(message)
            }
            
            ws.playerReadySignal
                .observeOn(UIScheduler())
                .observeResult{[unowned self] observer in
                    guard let message = observer.value else {
                        return
                    }
                    self.playerReadyObserver.sendNext(message)
            }
        }
    }
    
    func plusVote(id:Int?){
        if let id = id{
            self.wsSessionViewModel?.votePlus(id)
        }
    }
    
    func minusVote(id:Int?){
        if let id = id{
            self.wsSessionViewModel?.voteMinus(id)
        }
    }
    
    func endSession(){
        wsSessionViewModel?.endSession()
    }
    
    func donePerfomance() {
        self.wsSessionViewModel?.donePerfomance()
    }
    
    func initUnitySpectator(gameEntity:GameSessionsEntity) {
        do {
            let para: NSMutableDictionary = NSMutableDictionary()
            para.setValue(0, forKey: "type")
            para.setValue(-1, forKey: "user_id")
            para.setValue(gameEntity.id, forKey: "game_id")
            para.setValue(gameEntity.players.first?.id, forKey: "left_player_id")
            let jsonData = try NSJSONSerialization.dataWithJSONObject(para, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            UnitySendMessage("MessageRouter", "OnMessage", jsonString)
            
        }catch{
            
        }
    }
    
    func cleanUpUnityState(){
        do {
            let para: NSMutableDictionary = NSMutableDictionary()
            para.setValue(999, forKey: "type")
            let jsonData = try NSJSONSerialization.dataWithJSONObject(para, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            UnitySendMessage("MessageRouter", "OnMessage", jsonString)
        }catch{
        }
    }
    
    func sendGameMessage(textMessage:String){
        if let wsSessionViewModel = wsSessionViewModel{
            wsSessionViewModel.sendMessage(textMessage)
        }
    }
    
    func lookingGameToWatch(category: Int, except: Int?){
        if let wsSessionViewModel = wsSessionViewModel{
            wsSessionViewModel.lookingGameToWatch(category, except: except)
        }
    }
}
