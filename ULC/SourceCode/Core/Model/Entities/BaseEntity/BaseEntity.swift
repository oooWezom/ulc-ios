//
//  BaseEntity.swift
//  ULC
//
//  Created by Alex on 6/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import ObjectMapper

class BaseEntity: Object, Mappable {
    
    dynamic var id = 0
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map[MapperKey.id]
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let object = object as? BaseEntity else {
            return false;
        }
        return self.id == object.id;
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
