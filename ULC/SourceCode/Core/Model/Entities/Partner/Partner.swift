//
//  Partner.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Partner: EventBaseEntity {
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
    }
    
    static func partherFromUser(user: UserEntity) -> Partner {
        let parther = Partner();
        parther.id = user.id;
        parther.name = user.name;
        parther.avatar = user.avatar;
        parther.level = user.level
        parther.status = user.status;
        
        return parther;
    }
}
