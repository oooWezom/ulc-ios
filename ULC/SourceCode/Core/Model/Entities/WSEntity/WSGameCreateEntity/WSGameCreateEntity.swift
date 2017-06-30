//
//  WSGameCreateEntity.swift
//  ULC
//
//  Created by Alexey on 8/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameCreateEntity: WSBaseTypeEntity {

	var game: WSGameEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		game <- map[MapperKey.game]
	}
    
   static func create(model: WSGameEntity) -> WSGameCreateEntity {
        let result = WSGameCreateEntity()
        result.game = model
        return result
    }
}
