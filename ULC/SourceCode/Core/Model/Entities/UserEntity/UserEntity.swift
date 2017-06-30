//
//  UserEntiry.swift
//  ULC
//
//  Created by Alex on 6/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class UserEntity: EventBaseEntity {
    
    dynamic var statusDesc = ""
    dynamic var gamesWin = 0
    dynamic var talks = 0
    dynamic var likes = 0
    dynamic var accountStatusID = 0
    dynamic var sex = 0
    dynamic var blockMessages = false;
    dynamic var backgroundAvatarUrl = ""
    dynamic var expirience = 0
    dynamic var followers = 0
    dynamic var warningBan = false
    dynamic var gamesLoss = 0
    dynamic var aboutInfo = ""
    dynamic var login = ""
    dynamic var disabled = false
    dynamic var following = 0
    dynamic var totalGames = 0
    dynamic var block = 0
    dynamic var privateData = false
    dynamic var expMax = 0;
    dynamic var link = 0
    
    var languages = List<IntObject>()
    var talk: TalkSessionsResponseEntity?
    var game: GameSessionsEntity?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        statusDesc          <- map[MapperKey.status_desc]
        gamesWin            <- map[MapperKey.games_win]
        talks               <- map[MapperKey.talks]
        status              <- map[MapperKey.status]
        likes               <- map[MapperKey.likes]
        accountStatusID     <- map[MapperKey.account_status_id]
        sex                 <- map[MapperKey.sex]
        blockMessages       <- map[MapperKey.block_messages];
        backgroundAvatarUrl <- map[MapperKey.background];
        name                <- map[MapperKey.name];
        expirience          <- map[MapperKey.exp];
        followers           <- map[MapperKey.followers];
        warningBan          <- map[MapperKey.warning_ban];
        gamesLoss           <- map[MapperKey.games_loss];
        aboutInfo           <- map[MapperKey.about];
        login               <- map[MapperKey.login];
        disabled            <- map[MapperKey.disabled];
        following           <- map[MapperKey.following];
        totalGames          <- map[MapperKey.games_total];
        block               <- map[MapperKey.block];
        privateData         <- map[MapperKey.privateData];
        expMax              <- map[MapperKey.exp_max];
        link                <- map[MapperKey.link]
        talk                <- map[MapperKey.talk]
        game                <- map[MapperKey.game]
        
        languages <- (map[MapperKey.languages], TransformOf<List<IntObject>, [Int]> (
            fromJSON: { result in
                guard let items = result else {
                    return List<IntObject>()
                }
                let tmpItems = items as [Int]
                let tmpLanguages = List<IntObject>();
                
                for (_, item) in tmpItems.enumerate() {
                    let language = IntObject();
                    language.value = item
                    tmpLanguages.append(language);
                }
                return tmpLanguages },
            
            toJSON: { result in
                guard let languages = result else {
                    return []
                }
                var items = [Int]()
                for language in languages {
                    items.append(language.value)
                }
                return items }));
        
    }
    
    override static func ignoredProperties() -> [String] {
        return ["talk", "game"]
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class IntObject: Object {
     dynamic var value = 0
}

