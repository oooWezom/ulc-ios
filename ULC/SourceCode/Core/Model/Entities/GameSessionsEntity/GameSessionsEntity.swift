//
//  GameSessionsEntity.swift
//  ULC
//
//  Created by Alexey on 10/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class GameSessionsEntity : Object, Mappable {
    
    var id = 0
    var players = [WSPlayerEntity]()
    var spectators = 0
    var game = 0
    var state = 0
    var winsCount = 0
    var videoUrl = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
         id              <- map[MapperKey.id]
         game            <- map[MapperKey.game]
         state           <- map[MapperKey.state]
         players         <- map[MapperKey.players]
         winsCount       <- map[MapperKey.wins_count]
         spectators      <- map[MapperKey.spectators]
         videoUrl        <- map[MapperKey.videoUrl]
    }
    
    static func create(model:WSGameEntity?) -> GameSessionsEntity {
        let result = GameSessionsEntity()
        if let model = model {
            result.id = model.id
            result.players = model.players
            result.spectators = model.spectators
            result.game = model.game
            result.state = model.state
            result.videoUrl = model.videoUrl
        }
        return result;
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let object = object as? GameSessionsEntity else {
            return false;
        }
        return self.id == object.id;
    }
    
    override static func ignoredProperties() -> [String] {
        return ["players"]
    }
}
