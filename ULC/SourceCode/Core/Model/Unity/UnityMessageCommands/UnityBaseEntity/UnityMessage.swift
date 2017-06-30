//
//  UnityMessage.swift
//  ULC
//
//  Created by Alexey on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class UnityMessage: Mappable {

	var type: Int?
	var message: String?

	required convenience init?(_ map: Map) {
		self.init()
	}

	func mapping(map: Map) {
		type    <- map[MapperKey.type]
		message <- map[MapperKey.message]
	}
}
