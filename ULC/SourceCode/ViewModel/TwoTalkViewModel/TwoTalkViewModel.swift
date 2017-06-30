//
//  TwoTalkViewModel.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper
import RealmSwift

protocol TwoTalking {
    var talksSession: AnyProperty<[TalkSessionsResponseEntity]?> { get }
    var talksCategory: AnyProperty<[TalkCategory]> { get }
    
    func loadActiveSessions(let groupId: Int) -> SignalProducer<([SelfEvent]), ULCError>;
    func loadNewActiveSessions(let groupId: Int) -> SignalProducer<([SelfEvent]), ULCError>;
}

class TwoTalkViewModel: GeneralViewModel, TwoTalking {
    
    var talksSession: AnyProperty<[TalkSessionsResponseEntity]?> { return AnyProperty(_talksSession) }
    var talksCategory: AnyProperty<[TalkCategory]> { return AnyProperty(_talksCategory) }
    
    private var _talksSession = MutableProperty<[TalkSessionsResponseEntity]?>(nil);
    private var _talksCategory = MutableProperty<[TalkCategory]>([]);
    var groupId     = 0;
    
    override init() {
        super.init()
        configureDataBase()
    }
    
    func loadActiveSessions(let groupId: Int) -> SignalProducer<([SelfEvent]), ULCError> {
        if self.groupId != groupId {
            currentOffset = 0;
        }
        self.groupId = groupId;
        reloadData();
        return fetchActiveTalkSessions();
    }
    
    func loadNewActiveSessions(let groupId: Int) -> SignalProducer<([SelfEvent]), ULCError> {
        reloadData();
        return fetchActiveTalkSessions();
    }
    
    private func reloadData() {
        if let _ = talksSession.value {
            _talksSession.value?.removeAll();
            _talksSession.value = nil;
        }
    }
    
    func configureDataBase() {
        do {
            let realm = try Realm()
            _talksCategory.value = realm.objects(TalkCategory.self).toArray()
        } catch {
            Swift.debugPrint("impossible to get data from Data Base")
        }
    }
    
    private func fetchActiveTalkSessions() -> SignalProducer<([SelfEvent]), ULCError> {
        
        return SignalProducer { observer, disposable in
            networkProvider.request(.TalkByGroup(self.groupId, self.currentOffset), completion: { [weak self] result in
                guard let strongSelf = self else {
                    return;
                }
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String: AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                            return
                        }
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                              let items:[TalkSessionsResponseEntity] = Mapper<TalkSessionsResponseEntity>().mapArray(jsonString) else {
                                observer.sendCompleted();
                                return
                        }
                        if strongSelf._talksSession.value != nil {
                            for (_, object) in items.enumerate() {
                                if !strongSelf._talksSession.value!.contains(object) {
                                    strongSelf._talksSession.value!.insert(object, atIndex: 0)
                                }
                            }
                        } else {
                            if strongSelf.talksSession.value == nil {
                                strongSelf._talksSession.value = items
                            } else {
                                strongSelf._talksSession.value?.appendContentsOf(items);
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
