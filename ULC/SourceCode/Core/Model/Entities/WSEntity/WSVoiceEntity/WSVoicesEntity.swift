//
//  WSVoicesEntity.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSVoicesEntity: WSBaseEntity {

	var total = 0
	var plus = 0
	var minus = 0

	required init?(_ map: Map) { }

	override func mapping(map: Map) {
		total   <- map[MapperKey.total]
		plus    <- map[MapperKey.plus]
		minus   <- map[MapperKey.minus]

	}

}
