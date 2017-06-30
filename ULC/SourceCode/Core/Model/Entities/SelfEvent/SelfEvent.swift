//
//  SelfEvent.swift
//  ULC
//
//  Created by Alex on 6/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

enum EventType: Int {
    case EmptySession
    case StartFollow
    case GameSession
    case TalkSession = 4
}

class SelfEvent: Owner {
    
    dynamic var typeId = 0;
    dynamic var created_timestamp = 0;
    dynamic var viewers = 0;
    dynamic var winner_id = 0;
    dynamic var exp1 = 0;
    dynamic var exp2 = 0;
    dynamic var spectators = 0
    dynamic var type_desc = "";
    dynamic var created_date = "";
    dynamic var category = 0;
    dynamic var leaver = 0;
    dynamic var session = 0;
    dynamic var game = 0;
    
    dynamic var owner:Owner?;
    dynamic var following: Owner?;
    dynamic var opponent:Owner?;
    var partners = List<Owner>();
    var playlist:PlaylistEntity?;
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        typeId              <- map[MapperKey.type]
        created_date        <- map[MapperKey.created_date]
        created_timestamp   <- map[MapperKey.created_timestamp]
        viewers             <- map[MapperKey.viewers]
        winner_id           <- map[MapperKey.winner]
        exp1                <- map[MapperKey.exp1]
        exp2                <- map[MapperKey.exp2]
        type_desc           <- map[MapperKey.type_desc]
        spectators          <- map[MapperKey.spectators]
        category            <- map[MapperKey.category]
        leaver              <- map[MapperKey.leaver]
        
        owner               <- map[MapperKey.owner]
        following           <- map[MapperKey.following]
        opponent            <- map[MapperKey.opponent]
        
        partners            <- (map[MapperKey.partners], ListTransform<Owner>())
        
        session             <- map[MapperKey.session]
        game                <- map[MapperKey.game]
        playlist            <- map[MapperKey.playlist]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["playlist"]
    }
}

