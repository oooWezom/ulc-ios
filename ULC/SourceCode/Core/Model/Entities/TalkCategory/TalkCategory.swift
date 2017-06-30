//
//  TalkCategory.swift
//  ULC
//
//  Created by Vitya on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class TalkCategory: BaseEntity {
    
    dynamic var created_date = ""
    dynamic var created_timestamp = 0
    dynamic var enabled = 0
    dynamic var icon = ""
    dynamic var name = ""
    dynamic var name_ru = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        created_date        <- map[MapperKey.created_date]
        created_timestamp   <- map[MapperKey.created_timestamp]
        enabled             <- map[MapperKey.enabled]
        icon                <- map[MapperKey.icon]
        name                <- map[MapperKey.name]
        name_ru             <- map[MapperKey.name_ru]
    }
}

