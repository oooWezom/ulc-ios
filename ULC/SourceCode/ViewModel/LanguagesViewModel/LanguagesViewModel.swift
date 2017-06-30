//
//  LanguagesViewModel.swift
//  ULC
//
//  Created by Vitya on 6/16/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ObjectMapper
import RealmSwift

class LanguagesViewModel: GeneralViewModel {
    
    var languages: AnyProperty<[LanguageEntity]?> { return AnyProperty(_languages)}
    
    //Private
    private var _languages = MutableProperty<[LanguageEntity]?>(nil);
    
    override func configureSignals() {
        getLanguagesList();
    }
    
    func fetchLanguageById (languageID: Int) -> LanguageEntity? {
        do {
            let realm = try Realm()
            
            return realm.objectForPrimaryKey(LanguageEntity.self, key: languageID)
            
        } catch {
            return nil;
        }
    }
    
    func fetchLanguagesByIds (languageIDs: [Int]) -> [LanguageEntity]? {
        do {
            let realm = try Realm()
            var languagesArray = [LanguageEntity]()
            
            for id in languageIDs {
                if let language = realm.objectForPrimaryKey(LanguageEntity.self, key: id) {
                    languagesArray.append(language)
                }
            }
            
            return languagesArray
            
        } catch {
            return nil;
        }
    }
    
    func getLanguagesList() -> SignalProducer<[LanguageEntity], NSError> {
        
        return SignalProducer<[LanguageEntity], NSError> {
            observer, disposable in
            
            networkProvider.request(.LanguagesList(), completion: { result in
                switch(result) {
                case let .Success(response):
                    do {
                        guard   let json = try response.mapJSON() as? [String:AnyObject],
                            let languageObject = json[ApiManagerKey.response] as? [AnyObject] where !languageObject.isEmpty else {
                                return
                        }
                        
                        if let languages = Mapper<LanguageEntity>().mapArray(languageObject) {
                            self._languages.value = languages
                            do {
                                let realm = try Realm()
                                try realm.write({
                                    realm.add(languages, update: true)
                                }) } catch {
                                    Swift.debugPrint("error: \(error)")
                            }
                            observer.sendCompleted();
                        }
                        
                    } catch {
                        let error = NSError(domain: "Error fetch data from server", code: -1, userInfo: nil)
                        observer.sendFailed(error)
                    }
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(NSError(domain: "Error fetch data from server", code: -1, userInfo: nil))
                    break;
                }
            });
        };
    }
}
