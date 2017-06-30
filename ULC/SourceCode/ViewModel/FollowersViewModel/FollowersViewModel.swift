//
//  FollowersViewModel.swift
//  ULC
//
//  Created by Alex on 7/5/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper

class FollowersViewModel: GeneralViewModel {
    
    internal private(set) var queryString = MutableProperty<String>("")
    var items: AnyProperty<[FollowerEntity]?> { return AnyProperty(_items) };
    
    internal private(set) var followerType = MutableProperty<Int>(0)
    
    //Mark - Private properties
    private let _items = MutableProperty<[FollowerEntity]?>(nil);
    private var typeFollower = FollowerType.Followers;
    
    override init() {
        super.init();
        
        followerType.producer.startWithNext { [unowned self] (value: Int) in
            self.reloadUserData();
        }
        
        queryString.producer.startWithNext { [unowned self] (value: String) in
            self.reloadUserData();
        }
    }
    
    func fetchData(userID: Int, loadMore: Bool) -> SignalProducer<[FollowerEntity], ULCError> {
        
        guard let followType = FollowerType(rawValue: self.followerType.value) else {
            fatalError("Error type of followers value");
        }
        typeFollower = followType;
        return fetchFollowers(userID, shouldLoadMore: loadMore);
    }
    
    func reloadUserData() {
        if let _ = items.value {
            _items.value!.removeAll();
        }
    }
    
    private func fetchFollowers (userID: Int, shouldLoadMore: Bool) -> SignalProducer<[FollowerEntity], ULCError> {
        
        return SignalProducer {
            
            observer, disposable in
            
            let dictionary = ["name": self.queryString.value];
            var dictString = "";
            
            do {
                let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
                let jsonString = NSString(data:  jsonData, encoding: NSUTF8StringEncoding)! as String
                dictString = jsonString;
            } catch {
                observer.sendFailed(ULCError.ERROR_DATA);
                return;
            }
            
            networkProvider.request(self.typeFollower == .Followers ?
                
                .Followers(userID, dictString, self.currentOffset) :
                .Following(userID, dictString, self.currentOffset), completion: { [weak self] result in
                    
                    switch (result) {
                        
                    case let .Success(response):
                        do {
                            
                            guard let json = try response.mapJSON() as? [String:AnyObject] else {
                                observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                                return
                            }
                            
                            guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                                let tmpItems = Mapper<FollowerEntity>().mapArray(jsonString) else {
                                    if json["result"] as? String == "ok" {
                                        self?.reloadUserData();
                                        observer.sendCompleted();
                                    } else {
                                        observer.sendFailed(ULCError.ERROR_DATA);
                                    }
                                    return
                            }
                            
                            if shouldLoadMore == true && self?._items.value != nil {
                                
                                for (_, object) in tmpItems.enumerate() {
                                    if let strongSelf = self where !strongSelf._items.value!.contains(object) {
                                        strongSelf._items.value!.insert(object, atIndex: 0);
                                    }
                                }
                            } else {
                                if self?._items.value == nil {
                                    self?._items.value = tmpItems;
                                } else {
                                    self?._items.value!.appendContentsOf(tmpItems);
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
