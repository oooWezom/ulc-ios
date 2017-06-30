//
//  NewsFeedViewModel.swift
//  ULC
//
//  Created by Alex on 6/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper
import RealmSwift

protocol NewsFeedFiltering: NavigationStackProtocol, ViewModelTargetType {
    
    func openNewsFeedFilter();
    
    func loadFollowingEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError>;
    func loadGameEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError>;
    func loadTalkEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError>
    func reloadFollowingEvents() -> SignalProducer<([SelfEvent]), ULCError>;
    
    var feedType: FeedType { get set };
    var followingEvents: AnyProperty<[SelfEvent]?> { get };
    
}

class NewsFeedFilterViewModel: GeneralViewModel, NewsFeedFiltering {
    
    internal private(set) var is2PlayProperty       = MutableProperty<Bool>(true)
    internal private(set) var is2TalkProperty       = MutableProperty<Bool>(true)
    internal private(set) var isFollowingProperty   = MutableProperty<Bool>(true)
    
    var followingEvents: AnyProperty<[SelfEvent]?> { return AnyProperty(_followingEvents)}
    
    var filter: Int {
        
        get {
            let returnValue = (playSession.rawValue | talkSession.rawValue | followingSession.rawValue)
            return returnValue;
        }
    }
    
    var feedType:FeedType {
        
        get {
            return innerFeedType;
        }
        
        set {
            innerFeedType = newValue;
        }
    }
    
    //MARK private properties
    private var _followingEvents = MutableProperty<[SelfEvent]?>(nil);
    
    private var playSession         = EventType.EmptySession;
    private var talkSession         = EventType.EmptySession;
    private var followingSession    = EventType.EmptySession;
    
    private var innerFeedType = FeedType.All;
    
    override init() {
        super.init();
        
        configureSignals();
    }
    
    
    func openNewsFeedFilter() {
        presenter.openNewsFeedFilter(self);
    }
    
    func popViewControllerAnimated() {
        presenter.backToPreviousVC();
    }
    
    func reloadFollowingEvents() -> SignalProducer<([SelfEvent]), ULCError> {
        if let _ = _followingEvents.value {
            _followingEvents.value?.removeAll();
        }
        _followingEvents.value = nil;
        currentOffset = 0;
        return loadFollowingEvents(userID, ifNeedMore: false);
    }
    
    func loadFollowingEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError> {
        
        var filters = 0;
        switch feedType {
        case .Games:
            filters = EventType.GameSession.rawValue;
            break;
        case .Talk:
            filters = EventType.TalkSession.rawValue;
            break;
        default:
            filters = filter;
            break;
        }
        
        userID = userId;
        let value = fetchFollowingEvents(userId, offset: currentOffset, isNeedMore: ifNeedMore, filters: filters);
        currentOffset += 10;
        return value;
    }
    
    override func configureSignals() {
        
        feedType = FeedType.All;
        
        is2PlayProperty.producer.startWithNext { [unowned self] (value: Bool) in
            if value {
                self.playSession = EventType.GameSession;
            } else {
                self.playSession = EventType.EmptySession;
            }
        }
        
        is2TalkProperty.producer.startWithNext { [unowned self] (value: Bool) in
            if value {
                self.talkSession = EventType.TalkSession;
            } else {
                self.talkSession = EventType.EmptySession;
            }
        }
        
        isFollowingProperty.producer.startWithNext { [unowned self] (value: Bool) in
            if value {
                self.followingSession = EventType.StartFollow
            } else {
                self.followingSession = EventType.EmptySession
            }
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey(Constants.firstStart) {
            is2PlayProperty.value       = NSUserDefaults.standardUserDefaults().boolForKey(Constants.playFilter);
            is2TalkProperty.value       = NSUserDefaults.standardUserDefaults().boolForKey(Constants.talkFilter);
            isFollowingProperty.value   = NSUserDefaults.standardUserDefaults().boolForKey(Constants.followingFilter);
        } else {
            is2PlayProperty.value       = true
            is2TalkProperty.value       = true
            isFollowingProperty.value   = true
        }
    }
    
    private func fetchFollowingEvents(userId: Int, offset: Int, isNeedMore: Bool, filters: Int) -> SignalProducer<([SelfEvent]), ULCError> {
        
        if !is2PlayProperty.value && !is2TalkProperty.value && !isFollowingProperty.value {
            return SignalProducer { observer, disposable in
                self._followingEvents.value?.removeAll();
                observer.sendCompleted();
            }
            
        } else {
            
            return SignalProducer {
                observer, disposable in
                networkProvider.request(.NewsFeed(userId, offset, filters), completion: { [weak self] result in
                    
                    switch(result) {
                    case let .Success(response):
                        do {
                            guard let json = try response.mapJSON() as? [String:AnyObject] else {
                                observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                                return
                            }
                            guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                                    let items = Mapper<SelfEvent>().mapArray(jsonString) else {
                                    observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                                    return
                            }
                            
                            if items.isEmpty {
                                observer.sendCompleted();
                                return;
                            }
                            
                            if isNeedMore {
                                if let _ = self?._followingEvents.value {
                                    self?._followingEvents.value!.appendContentsOf(items)
                                }
                            } else {
                                if let _ = self?._followingEvents.value {
                                    for (_, object) in items.enumerate() {
                                        if let strongSelf = self where !strongSelf._followingEvents.value!.contains(object) {
                                            strongSelf._followingEvents.value!.insert(object, atIndex: 0)
                                        }
                                    }
                                } else {
                                    self?._followingEvents.value = items
                                }
                            }
                            observer.sendCompleted();
//                            do {
//                                let realm = try Realm()
//                                try realm.write {
//                                    realm.add(items, update: true)
//                                    
//                                }
//                            } catch {}
                        } catch{ }
                        break;
                    case .Failure(_):
                        break;
                        
                    }
                    })
            }}
    }
    
    func loadGameEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError> {
        userID = userId;
        let value = fetchFollowingEvents(userId, offset: 0, isNeedMore: ifNeedMore, filters: EventType.GameSession.rawValue | 0 | 0);
        currentOffset += 10;
        return value;
    }
    
    func loadTalkEvents(userId: Int, ifNeedMore: Bool) -> SignalProducer<([SelfEvent]), ULCError> {
        userID = userId;
        let value = fetchFollowingEvents(userId, offset: 0, isNeedMore: ifNeedMore, filters: EventType.TalkSession.rawValue | 0 | 0);
        currentOffset += 10;
        return value;
    }
    
    deinit {
        _followingEvents.value?.removeAll();
    }
}
