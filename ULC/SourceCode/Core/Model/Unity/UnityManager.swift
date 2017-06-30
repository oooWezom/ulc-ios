//
//  UnityManager.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//
import ObjectMapper

class UnityManager: UnityManagerProtocol {
    
    func sendMessage(message: String) {
        UnitySendMessage(unityRouterName, "OnMessage", message)
    }
    
    //	func sendMessage(message: UnityMessage) {
    //		UnitySendMessage(unityRouterName, "OnMessage", "")
    //	}
    
    func sendMessage(router:String, method:String, value:String) {
        UnitySendMessage(router, method, value)
    }
    
    func resetUIToReady() {
        UnitySendMessage("UIController", "ResetUIToReady", "")
    }
    
    func sendMessage(dictionary: [String: AnyObject]) {
        
    }
    
    func onMessage(message: String) {
        
    }
    
    // MARK: exclude this method
    func initialUnity(model:WSGameEntity?, ownerID:Int) {
        var user_id = 0
        var leftPlayerId = 0
        
        if let model = model {
            let wsGameCreateEntity = WSGameCreateEntity.create(model)
            
            if let players = wsGameCreateEntity.game?.players {
                players.forEach { it in
                    if it.id == ownerID {
                        user_id = it.id
                    } else {
                        leftPlayerId = it.id
                    }
                }
            }
            
            let model = GameInitMessage()
            model.game_id = wsGameCreateEntity.game?.id
            model.user_id = user_id
            model.leftPlayerId = leftPlayerId
            model.type = UnityEvents.INIT_GAME.rawValue
            model.base_url = Constants.GAMES_IMAGES_URL
            
            if let json = model.toJSONString() {
                self.sendMessage(json)
            }
        }
    }
    
}
