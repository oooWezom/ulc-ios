import Foundation
import ReactiveCocoa
import Result
import ObjectMapper
import RealmSwift
import SwiftKeychainWrapper

class UserProfileViewModel: GeneralViewModel {

    var userEntity:     AnyProperty<UserEntity?>     { return AnyProperty(_userEntity) }
    var selfEvents:     AnyProperty<[SelfEvent]?>    { return AnyProperty(_selfEvents) }
    var countersEntity: AnyProperty<CountersEntity?> { return AnyProperty(_countersEntity) }
	var selfEvent:     AnyProperty<SelfEvent?>    { return AnyProperty(_selfEvent) }
    
    // Mark - Private properties

	private let _selfEvent     = MutableProperty<SelfEvent?>(nil);

    private let _userEntity     = MutableProperty<UserEntity?>(nil);
    private let _selfEvents     = MutableProperty<[SelfEvent]?>(nil);
    private let _countersEntity = MutableProperty<CountersEntity?>(nil);

	func loadEventsData(eventID:Int) -> SignalProducer<SelfEvent, ULCError> {

		return SignalProducer {[weak self] observer, disposable in
			networkProvider.request(.EventsByID(eventID), completion: { [weak self] result in

				switch (result) {

				case let .Success(response):

					do {
						guard let json = try response.mapJSON() as? [String: AnyObject]  else {
							observer.sendFailed(ULCError.ERROR_DATA_CORRUPTION)
							return;
						}

						guard let jsonString = json[ApiManagerKey.response] as? [String:AnyObject] where !jsonString.isEmpty,
							let event = Mapper<SelfEvent>().map(jsonString),let strongSelf = self else {
								return
						}
						strongSelf._selfEvent.value = event
						observer.sendCompleted()
					} catch {

					}

					break

				case .Failure(_):

					break

				}
			})
		}
	}
    
    func loadUserDataProfile(userProfileID: Int) -> SignalProducer <(UserEntity), ULCError> {
        
        return SignalProducer {[weak self] observer, disposable in
            
            do {
                let realm = try Realm()
                if let strongSelf = self {
                    if userProfileID == 0 {
                        //profile for current user
                        if let selfEntity = realm.objectForPrimaryKey(UserEntity.self, key: strongSelf.currentId) where !selfEntity.name.isEmpty {
                            strongSelf._userEntity.value = selfEntity;
                        }
                    } else {
                        //profile for not current user
                        if let selfEntity = realm.objectForPrimaryKey(UserEntity.self, key: userProfileID) where !selfEntity.name.isEmpty {
                            strongSelf._userEntity.value = selfEntity;
                        }
                    }
                }
            } catch {}
            
            networkProvider.request(.Profile(userProfileID), completion: { [weak self] result in
                
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String: AnyObject]  else {
                            observer.sendFailed(ULCError.ERROR_DATA_CORRUPTION)
                            return;
                        }
                        if let jsonString = json[ApiManagerKey.response] as? [String: AnyObject] where !jsonString.isEmpty {
                            if let user = Mapper<UserEntity>().map(jsonString), let strongSelf = self {
                                strongSelf._userEntity.value = user
                                
                                observer.sendNext(user);
                                
                                do {
                                    let realm = try Realm()
                                    try realm.write({
                                        realm.add(user, update: true)
                                    })
                                } catch {
                                }
                            }
                        }
                        if  let resultString    = json[MapperKey.result] as? String,
                            let status          = json[MapperKey.error] as? Int
                            where resultString  == MapperKey.error {
                            observer.sendFailed(ULCError.error(status));
                        }
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA_CORRUPTION);
                    break;
                }
            });
        }
    }
    
    func loadSelfEvents(isNeedMore: Bool = true) -> SignalProducer<([SelfEvent]), ULCError> {
        if isNeedMore {
            currentOffset += 10;
        }
        return fetchEvents(self.userID, offset: isNeedMore ? currentOffset : 0, isNeedMore: isNeedMore);
    }
    
    func updateAvatarOrBackground(avatarUrlData: String, backgorunUrlData: String) -> SignalProducer<String, ULCError> {
        
        return SignalProducer { [weak self] observer, disposable in
            
            networkProvider.request(.UpdateProfile(avatarUrlData, backgorunUrlData), completion: { result in
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String: AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_DATA);
                            return
                        }
                        if let resultString = json[ApiManagerKey.result] as? String where resultString == "ok",
                            let responseDataUpdate = json[ApiManagerKey.response] as? [String: AnyObject] {
                            
                            guard let newImageFileName = responseDataUpdate[!avatarUrlData.isEmpty ? ApiManagerKey.avatar : ApiManagerKey.background] as? String else {
                                observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: ApiManagerKey.response))
                                return;
                            }
                            
                            dispatch_async(GCD.serialQueue(), {
                                do {
                                    guard let userEntity = self?.getSelfUser() else {
                                        return;
                                    }
                                    let realm = try Realm();
                                    try realm.write({
                                        if !avatarUrlData.isEmpty {
                                            userEntity.avatar = newImageFileName;
                                        } else {
                                            userEntity.backgroundAvatarUrl = newImageFileName;
                                        }
                                    });
                                    observer.sendNext(newImageFileName);
                                    observer.sendCompleted();
                                } catch {
                                    observer.sendFailed(ULCError.ERROR_DATA)
                                }
                            })
                        } else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: ApiManagerKey.response));
                        }
                    } catch {}
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: ApiManagerKey.response));
                    break;
                }
            })
        }
    }
    
    func updateProfileData(userName: String, sex: Int, about: String, languages: [Int], blockMessages: Bool, blockAccount: Bool, privateData: Bool) -> SignalProducer<(), ULCError> {
        
        return SignalProducer { observer, disposable in
            
            networkProvider.request(.UpdateAllProfile(userName, sex, about, languages, blockMessages, blockAccount, privateData), completion: { result in
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String: AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_DATA);
                            return
                        }
                        
                        if let resultString = json[ApiManagerKey.result] as? String where resultString == "ok" {
                            observer.sendCompleted();
                        } else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: ApiManagerKey.response));
                        }
                    } catch { }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            })
        }
    }
    
    func reportUser(userId: Int) -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { observer, disposable in
            
            networkProvider.request(.ReportUser(userId), completion: { result in
                switch (result) {
                case .Success(_):
                    observer.sendCompleted()
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            });
        };
    }
    
    func addToBlackList(userID: Int) -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { observer, disposable in
            
            networkProvider.request(.AddToBlackList(userID), completion: { result in
                switch (result) {
                case .Success(_):
                    observer.sendCompleted()
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            });
        };
    }
    
    func removeFromBlackList(userID: Int) -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { observer, disposable in
            
            networkProvider.request(.RemoveFromBlacklist(userID), completion: { result in
                switch (result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if let status = json[ApiManagerKey.result] as? String where status == "ok" {
                                observer.sendCompleted();
                            } else {
                                observer.sendFailed(.ERROR_DATA)
                            }
                        }
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA)
                    break;
                }
            });
        };
    }
    
    // MARK: - Private functions
    private func fetchEvents(userId: Int, offset: Int, isNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError> {
        
        return SignalProducer {
            observer, disposable in
            
            networkProvider.request(.SelfEvents(userId, offset), completion: { [weak self] result in
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String: AnyObject] else {
                            return
                        }
                        
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                            let items = Mapper<SelfEvent>().mapArray(jsonString) else {
                                return
                        }
                        
                        if isNeedMore {
                            if self?._selfEvents.value != nil {
                                self?._selfEvents.value!.appendContentsOf(items)
                            }
                            // observer.sendNext(items);
                        } else {
                            if self?.selfEvents.value == nil {
                                self?._selfEvents.value = items
                            // observer.sendNext(items);
                            } else {
                                for (_, object) in items.enumerate() {
                                    if let strongSelf = self where !strongSelf._selfEvents.value!.contains(object) {
                                        strongSelf._selfEvents.value!.insert(object, atIndex: 0)
                                    }
                                }
                            }
                        }
                        observer.sendCompleted();
                    } catch { }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA)
                    break;
                }
            })
        }
    }
    
    func getCounters() -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { observer, disposable in
            
            networkProvider.request(.Counters(), completion: { [weak self] result in
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String:AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                            return
                        }
                        
                        guard let jsonString = json[ApiManagerKey.response] as? [String:AnyObject] where !jsonString.isEmpty,
                            let items = Mapper<CountersEntity>().map(jsonString) else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                        }
                        
                        self?._countersEntity.value = items
                        observer.sendCompleted()
                        
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA)
                    break;
                }
                });
        }
    }

	func openProfile(key:String?) -> SignalProducer<(), ULCError> {

		return SignalProducer<(), ULCError> { observer, disposable in
			if let key = key {
				networkProvider.request(.ConfirmNewAccount(key), completion: { [weak self] result in
					switch (result) {

					case let .Success(response):
						do {
							guard let json = try response.mapJSON() as? [String:AnyObject] else {
								observer.sendFailed(ULCError.ERROR_DATA)
								return
							}

							if	let result = json[MapperKey.result] as? String where result == "ok",
								let token = json[MapperKey.token] as? String where !token.isEmpty,
								let userId = json[MapperKey.id] as? Int where userId > -1 {

								KeychainWrapper.setString(token, forKey: Constants.keyChainValue)
								KeychainWrapper.setString(String(userId), forKey: Constants.currentUserId)

								observer.sendNext();
								observer.sendCompleted();

								self?.presenter.openContainerVC();
							}

						} catch {
							observer.sendFailed(ULCError.ERROR_DATA)
						}
						break

					case .Failure(_):
						observer.sendFailed(ULCError.ERROR_DATA)
						break
					}
					})
			}


		}
	}
    
    func getFollowersAndMessagesCounters() -> Int? {
        if let followersCount = countersEntity.value?.followers, let messagesCount = countersEntity.value?.messages {
            return followersCount + messagesCount
        }
        
        return nil
    }
    
    func updateOwnerWithUserEntity(value: UserEntity) {
        let owner = Owner.getOwnerEntity(value)
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(owner, update: true)
            })
        } catch {}
    }
    
    func updateOwner(owner: Owner?, value: Int) {
        guard let owner = owner else {
            return
        }
        
        do {
            let realm = try Realm()
            try realm.write({
                owner.link = value
            })
        } catch {}
    }
    
    deinit {
        _userEntity.value = nil;
        _selfEvents.value?.removeAll();
        _countersEntity.value = nil;
    }
}
