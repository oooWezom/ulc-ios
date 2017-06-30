//
//  GameEntity.swift
//  ULC
//
//  Created by Alexey on 7/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GameEntity: Object {

	dynamic var title: String = ""
	dynamic var gameId: Int = 0

	dynamic var isChecked = false // this field sould'nt be written to realm, changed only ChooseGameViewController

	convenience init(title: String, gameId: Int, isChecked: Bool) {
		self.init()
		self.title = title
		self.gameId = gameId
		self.isChecked = isChecked
	}

	override static func primaryKey() -> String? {
		return "gameId"
	}

	override static func ignoredProperties() -> [String] {
		return ["isChecked"]
	}

}

