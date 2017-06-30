//
//  TwoPlayViewModel.swift
//  ULC
//
//  Created by Alexey on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper
import RealmSwift
import Result

class TwoPlayViewModel: GeneralViewModel {

	var games: AnyProperty<[GameSessionsEntity]?> { return AnyProperty(_games) }
	private var _games = MutableProperty<[GameSessionsEntity]?>(nil);
    
	let realmResultsCache = RealmResultsCache()

	override func configureSignals() {
	}

	func loadActiveSessions() -> SignalProducer<Void, ULCError> {
		return fetchActiveSessions();
	}

	func fillGames() {
		var gameEntities = [GameEntity]()
		gameEntities.append(GameEntity(title: "Random", gameId: GameID.RANDOM.rawValue, isChecked: false))
		gameEntities.append(GameEntity(title: "X-cows", gameId: GameID.X_COWS.rawValue, isChecked: false))
		gameEntities.append(GameEntity(title: "Land it", gameId: GameID.LAND_IT.rawValue, isChecked: false))
		gameEntities.append(GameEntity(title: "Rock-spock", gameId: GameID.ROCK_SPOCK.rawValue, isChecked: false))
		gameEntities.append(GameEntity(title: "Math2", gameId: GameID.MATH2.rawValue, isChecked: false))
		gameEntities.append(GameEntity(title: "Spin the discs", gameId: GameID.SPIN_THE_DISKS.rawValue, isChecked: false))

		gameEntities.forEach { it in
			realmResultsCache.update(it, isUpdate: false)
		}
	}

	func getGamesArray() -> [GameEntity] {
		return realmResultsCache.getArray(GameEntity)
	}

	func reloadData() {
		if let _ = games.value {
			_games.value?.removeAll();
			_games.value = nil;
		}
	}

	private func fetchActiveSessions() -> SignalProducer<Void, ULCError> {
        _games.value?.removeAll();
        _games.value = nil;

        
		return SignalProducer { [weak self]
			observer, disposable in

			networkProvider.request(.ActiveGameSessions(), completion: { result in
				switch (result) {
				case let .Success(response):
					do {
						guard let json = try response.mapJSON() as? [String: AnyObject] else {
							observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
							return
						}
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
							  let items = Mapper<GameSessionsEntity>().mapArray(jsonString) else {
								observer.sendCompleted();
								return
						}
						if self?._games.value != nil {
							for (_, object) in items.enumerate() {
                                if let strongSelf = self where !strongSelf._games.value!.contains(object) {
                                    strongSelf._games.value!.insert(object, atIndex: 0);
                                }
							}
						} else {
							if self?.games.value == nil {
								self?._games.value = items
							} else {
								self?._games.value?.appendContentsOf(items);
							}
						}
						observer.sendCompleted();
					} catch {
						observer.sendFailed(ULCError.ERROR_DATA)
					}
					break;

				case .Failure(_):
					observer.sendFailed(ULCError.ERROR_DATA)
					break;
				}
			})
		}
	}
}
