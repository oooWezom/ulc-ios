//
//  SpectatorTalkSessionViewModel.swift
//  ULC
//
//  Created by Vitya on 9/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper
import RealmSwift

class SpectatorTalkSessionViewModel: GeneralViewModel {
    
    var currentUserInfo: AnyProperty<UserEntity?> { return AnyProperty(_currentUserInfo) }
    private let _currentUserInfo = MutableProperty<UserEntity?>(nil);
    
    func getCurrentUserInfo() -> SignalProducer<(), ULCError> {
        return fetchCurrentUserInfo()
    }
    
    private func fetchCurrentUserInfo() -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { [unowned self]
            observer, disposable in
            do {
                let realm = try Realm()
                self._currentUserInfo.value = realm.objects(UserEntity.self).first
                observer.sendCompleted();
            } catch{
                observer.sendFailed(ULCError.ERROR_DATA)
            }
        }
    }
}
