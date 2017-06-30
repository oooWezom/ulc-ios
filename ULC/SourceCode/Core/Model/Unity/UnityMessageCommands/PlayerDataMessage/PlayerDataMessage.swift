//
//  PlayerData.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class PlayerDataMessage: UnityMessage {

	var id: Int?
	var ready: Bool?
	var wins: Int?
	var category: String?
	var file: String?
	var disks: [Int]?

	required convenience init?(_ map: Map) {
		self.init()
	}
    
    override func mapping(map: Map) {
        super.mapping(map);
		id          <- map[MapperKey.id]
		ready       <- map[MapperKey.ready]
		wins        <- map[MapperKey.wins]
		category    <- map[MapperKey.category]
		file        <- map[MapperKey.file]
		disks       <- map[MapperKey.disks]
	}
}
