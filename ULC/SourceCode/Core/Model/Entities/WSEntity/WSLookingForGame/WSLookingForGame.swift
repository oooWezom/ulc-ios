//
//  WSLookingForGame.swift
//  ULC
//
//  Created by Alexey on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper
import Realm
import RealmSwift

class WSLookingForGame: WSBaseTypeEntity {

	var result = 0
	var message = ""
    var game: WSGameEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
        super.mapping(map);
		result      <- map[MapperKey.result]
		message     <- map[MapperKey.message]
        game        <- map[MapperKey.game]
	}
}
