//
//  BlackListViewModel.swift
//  ULC
//
//  Created by Vitya on 7/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper

class BlackListViewModel: GeneralViewModel {

    var items: AnyProperty<[EventBaseEntity]?> { return AnyProperty(_items) };

    //MARK private properties
    private var _items = MutableProperty<[EventBaseEntity]?>(nil);
    
    override init() {
        super.init();
        
    }
    
    func fetchData(offset: Int, loadMore: Bool) -> SignalProducer<[EventBaseEntity], ULCError> {
        
        return fetchBlackList(offset, isNeedMore: loadMore)
    }
    
    func reloadBlackListData() {
        if let _ = items.value {
            _items.value?.removeAll();
            _items.value = nil;
        }
    }
    
    func removeDataAtIndex(index: Int) {
        if let _ = items.value {
            _items.value?.removeAtIndex(index)
        }
    }

    private func fetchBlackList(offset: Int, isNeedMore: Bool) -> SignalProducer<([EventBaseEntity]), ULCError> {
        
        return SignalProducer {
            observer, disposable in
            networkProvider.request(.BlackList(offset), completion: { [weak self] result in
                
                switch(result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String:AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                            return
                        }
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                            let items = Mapper<EventBaseEntity>().mapArray(jsonString) else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                        }
                        if isNeedMore {
                            self?._items.value?.appendContentsOf(items)
                        } else {
                            if self?._items.value == nil {
                                self?._items.value = items
                            } else {
                                for (_, object) in items.enumerate() {
                                    if let strongSelf = self where !strongSelf._items.value!.contains(object) {
                                        strongSelf._items.value!.insert(object, atIndex: 0)
                                    }
                                }
                            }
                        }
                        observer.sendCompleted();
                    } catch{}
                    break;
                case .Failure(_):
                    break;
                    
                }
                })
        }
    }
    
    func removeFromBlackList(userID: Int) -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { observer, disposable in
            
            networkProvider.request(.RemoveFromBlacklist(userID), completion: { result in
                switch(result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if let status = json[ApiManagerKey.result] as? String where status == "ok" {
                                observer.sendCompleted();
                            } else {
                                guard  let resultString = json[MapperKey.result] as? String,
                                    let status = json[MapperKey.error] as? Int
                                    where resultString == MapperKey.error  else {
                                        observer.sendFailed(ULCError.ERROR_DATA);
                                        return;
                                }
                                observer.sendFailed(ULCError.error(status));
                            }
                        }
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA_CORRUPTION)
                    }
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA)
                    break;
                }
            });
        };
    }
}
