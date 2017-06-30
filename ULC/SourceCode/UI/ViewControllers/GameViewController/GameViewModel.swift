//
//  GameViewModel.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa

class GameViewModel: GeneralViewModel {
    
    // Outputs
    var leftPlayerModel: AnyProperty<WSPlayerEntity?> { return AnyProperty(mLeftPlayerModel) }
    var rightPlayerModel: AnyProperty<WSPlayerEntity?> { return AnyProperty(mRightPlayerModel) }
    var gameModel: AnyProperty<WSGameEntity?> { return AnyProperty(mGameModel) }
    
    // Inputs
    private var mLeftPlayerModel = MutableProperty<WSPlayerEntity?>(nil)
    private var mRightPlayerModel = MutableProperty<WSPlayerEntity?>(nil)
    private var mGameModel = MutableProperty<WSGameEntity?>(nil)
    private let unityManager = UnityManager()
    
    private var model: WSGameCreateEntity?
    
    init(model:AnyObject?) {
        super.init()
        
        // MARK initialize when GameViewController
        if let model = model as? WSGameCreateEntity,
            let game = model.game {
            self.mGameModel.value = game
            
            //unityManager.sendMessage("ScenesRouter", method: "onSceneSwitch", value: "\(game.game)")
            unityManager.sendMessage("MessageRouter", method: "SwitchScene", value: "\(game.game)")
            initPlayers(model.game?.players,gameMode: .GAME)
            self.model = model
        }
        
        // MARK initialize when SpectatorViewController
        if let model = model as? GameSessionsEntity {
  
            //unityManager.sendMessage("ScenesRouter", method: "onSceneSwitch", value: "\(model.game)")
            unityManager.sendMessage("MessageRouter", method: "SwitchScene", value: "\(model.game)")
            
            
            self.mGameModel.value = WSGameEntity.create(model)
            initPlayers(model.players, gameMode: .SPECTATOR)
        }
    }
    
    private func initPlayers(players:[WSPlayerEntity]?, gameMode:GameMode) {
        guard let players = players else { return }
        if !players.isEmpty {
            switch gameMode {
            case .GAME:
                for player in players {
                    if player.id == self.currentId {
                        self.mLeftPlayerModel.value = player
                    } else {
                        self.mRightPlayerModel.value = player
                    }
                }
                break
            case .SPECTATOR:
                self.mLeftPlayerModel.value = players[0]
                self.mRightPlayerModel.value = players[1]
                break
                
            default:
                break
            }
        } else {
            return
        }
    }
    
    func initialUnityGame() {
        var user_id = 0
        var leftPlayerId = 0
        guard let model = model else { return }
            
            guard let gameID =  model.game?.id else {
                return;
            }
            
            if let players = model.game?.players {
                players.forEach { it in
                    if it.id == currentId {
                        user_id = it.id
                    } else {
                        leftPlayerId = it.id
                    }
                }
            }
        
        let initModel = GameInitMessage()
        initModel.game_id = gameID
        initModel.user_id = user_id
        initModel.leftPlayerId = leftPlayerId
        initModel.type = UnityEvents.INIT_GAME.rawValue
        initModel.base_url = Constants.GAMES_IMAGES_URL

        if let jsonString = initModel.toJSONString() {
            UnityManager().sendMessage("MessageRouter", method: "OnMessage", value: jsonString)
        }
    }
    
    func initUnitySpectator(gameEntity:GameSessionsEntity) {
        
        let initModel = GameInitMessage()
        initModel.game_id = gameEntity.id
        initModel.user_id = -1
        initModel.leftPlayerId = gameEntity.players.first?.id
        initModel.type = UnityEvents.INIT_GAME.rawValue
        initModel.base_url = Constants.GAMES_IMAGES_URL
        
        if let jsonString = initModel.toJSONString() {
            UnityManager().sendMessage("MessageRouter", method: "OnMessage", value: jsonString)
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
}