//
//  CategoryViewModel.swift
//  ULC
//
//  Created by Alex on 8/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper
import RealmSwift

protocol Categoring: VersionApiCheckable {
    func fetchTalkCategoryIcons();
    func fetchTalkCategoryFromDB() -> [TalkCategory]?;
    var categories: AnyProperty<[TalkCategory]?> { get };
    var categoryToken: NotificationToken! { get };
}

class CategoryViewModel: GeneralViewModel, Categoring {
    
    var categoryToken: NotificationToken! = nil;
    var categories: AnyProperty<[TalkCategory]?> { return AnyProperty(_categories) };
    //MARK private properties
    private let _categories = MutableProperty<[TalkCategory]?>(nil);
    
    func fetchTalkCategoryIcons() {
        setupNotification();
        networkProvider.request(.TalkCategory(), completion: { result in
            switch (result) {
            case let .Success(response):
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    do {
                        if let json: [String: AnyObject] = try response.mapJSON() as? [String: AnyObject] {
                            if let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty {
                                if let category = Mapper<TalkCategory>().mapArray(jsonString) {
                                    do {
                                        let realm = try Realm()
                                        try realm.write({
                                            realm.add(category, update: true)
                                        })
                                    } catch {
                                    }
                                }
                            }
                        }
                    } catch {
                    }})
                break;
                
            case .Failure(_):
                break;
            }
        });
    }
    
    func fetchTalkCategoryFromDB() -> [TalkCategory]? {
        do {
            let realm = try Realm()
            return realm.objects(TalkCategory.self).toArray()
        } catch{
            return nil
        }
    }
    
    func fetchColorCategoryAvatarURL (categoryID: Int) -> String? {
        do {
            let realm = try Realm()
            if let iconUrl = realm.objectForPrimaryKey(TalkCategory.self, key: categoryID)?.icon {
                var path = String()
                if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
                    path = Constants.smallTalkCategoryIconUrl
                } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
                    path = Constants.threeXsmallTalkCategoryIconUrl
                }
                return path + iconUrl
            } else {
                return nil
            }
        } catch {
            return nil;
        }
    }
    
    func fetchWhiteCategoryAvatarURL (categoryID: Int) -> String? {
        do {
            let realm = try Realm()
            if let iconUrl = realm.objectForPrimaryKey(TalkCategory.self, key: categoryID)?.icon {
                var path = "";
                UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue ?
                    (path = Constants.whiteSmallTalkCategoryIconUrl) :
                    (path = Constants.whiteThreeXsmallTalkCategoryIconUrl)
                return path + iconUrl
            } else {
                return nil
            }
        } catch {
            return nil;
        }
    }
    
    func fetchCategoryName (categoryID: Int) -> String? {
        do {
            let realm = try Realm()
            return realm.objectForPrimaryKey(TalkCategory.self, key: categoryID)?.name
        } catch {
            return nil;
        }
    }
    
    func fetchCategory(categoryID: Int) -> SignalProducer<TalkCategory, ULCError> {
        return SignalProducer<TalkCategory, ULCError> { observer, disposable in
            do {
                let realm = try Realm()
                if let category = realm.objectForPrimaryKey(TalkCategory.self, key: categoryID) {
                    observer.sendNext(category);
                }
            } catch {
                observer.sendFailed(ULCError.ERROR_DATA_CORRUPTION);
            }
        }
    }
    
    private func setupNotification() {
        do {
            let realm = try Realm();
            realm.autorefresh = true;
            //fetch data from cache if possible
            let cachedData = realm.objects(TalkCategory.self)
            if !cachedData.isEmpty {
                let tmpItems = Array(cachedData)
                if !tmpItems.isEmpty {
                    _categories.value = Array(tmpItems)
                }
            }
            //setup token
            categoryToken = realm.objects(TalkCategory.self).addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .Update(let items, deletions: _, insertions: _, modifications: _):
                    let tmpItems = Array(items);
                    self?._categories.value = tmpItems;
                    break;
                default:
                    break;
                }})
        } catch {}
    }
    
    deinit {
        if categoryToken != nil {
            categoryToken.stop();
        }
    }
}
