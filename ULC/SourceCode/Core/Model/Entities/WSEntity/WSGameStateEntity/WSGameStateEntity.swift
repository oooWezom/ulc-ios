//
//  WSGameState.swift
//  ULC
//
//  Created by Alexey on 8/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSGameStateEntity: WSBaseTypeEntity {

	var data: WSGameStateDataEntity?

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map);
		data <- map[MapperKey.data]
	}
}
