//
//  ChooseGameViewModel.swift
//  ULC
//
//  Created by Alexey on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ChooseGameViewModel: GeneralViewModel {

	let realmResultsCache = RealmResultsCache()

	override func configureSignals() {

	}

	func getGamesArray() -> [GameEntity] {
		return realmResultsCache.getArray(GameEntity)
	}

}
