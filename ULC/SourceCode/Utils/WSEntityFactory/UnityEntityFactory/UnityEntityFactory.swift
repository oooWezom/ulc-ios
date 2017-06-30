//
//  UnityEntityFactory.swift
//  ULC
//
//  Created by Alexey on 8/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class UnityEntityFactory {
	let factory = UnityMessageEntityFactory();

	func createEntity(dictinary: [String: AnyObject]) -> Mappable? {
		return factory.createEntity(dictinary)
	}
}
