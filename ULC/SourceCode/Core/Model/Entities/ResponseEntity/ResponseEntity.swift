//
//  ResponseEntity.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/1/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseEntity: Mappable {

	var response: Events?

	required convenience init?(_ map: Map) {
		self.init()
	}

	func mapping(map: Map) {
		response <- map[MapperKey.response]
	}
}