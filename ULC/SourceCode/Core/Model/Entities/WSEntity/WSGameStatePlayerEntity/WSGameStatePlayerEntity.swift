//
//  WSGameStatePlayerEntity.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameStatePlayerEntity: WSBaseEntity {

	var ready = false
	var wins = 0
  var category = ""
  var file = ""
  var disks = [Int]()

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		super.mapping(map);
		ready       <- map[MapperKey.ready]
		wins        <- map[MapperKey.wins]
        category    <- map[MapperKey.category]
        file        <- map[MapperKey.file]
        disks       <- map[MapperKey.disks]
	}
}
