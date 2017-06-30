//
//  WSInstantMessage.swift
//  ULC
//
//  Created by Alex on 8/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class WSInstantMessage: WSBaseTypeEntity {
    
    var recipientID = 0
    var text = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        text        <- map[MapperKey.text]
        recipientID <- map[MapperKey.recipient_id]
    }
}
