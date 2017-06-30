//
//  LanguageEntity.swift
//  ULC
//
//  Created by Vitya on 7/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class LanguageEntity: BaseEntity {
    
    dynamic var displayName = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        displayName <- map[MapperKey.display_name]
    }
}
