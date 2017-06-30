//
//  AdvancedSearchViewModel.swift
//  ULC
//
//  Created by Alex on 8/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper

class AdvancedSearchViewModel: GeneralViewModel {
    
    var usersProfile: AnyProperty<[UserEntity]?> { return AnyProperty(_usersProfile) }
    
    var languages = MutableProperty<[Int]>([])
    var gender    = MutableProperty<Int>(0)
    var status    = MutableProperty<Int>(0);
    var level     = MutableProperty<(Int, Int)>(1, 100)
    
    //MARK: Private property
    private let _usersProfile = MutableProperty<[UserEntity]?>(nil);
    
    
    func fetchUsersProfiles(name: String = "") -> SignalProducer<[UserEntity], ULCError> {
        
        var parameters = [String:AnyObject]();
        
        if !name.isEmpty {
            parameters[MapperKey.name] = name;
        }
        
        if !languages.value.isEmpty {
            parameters[MapperKey.languages] = languages.value;
        }
        
        parameters[MapperKey.sex]       = gender.value;
       // parameters[MapperKey.status]    = status.value;
        parameters["min_level"]         = level.value.0;
        parameters["max_level"]         = level.value.1;
        
        
        if !parameters.isEmpty {
            
            return SignalProducer <[UserEntity], ULCError> { observer, disposable in
                
                var dictionaryString = "";
                
                do {
                    let jsonData        = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
                    let jsonString      = NSString(data:  jsonData, encoding: NSUTF8StringEncoding)! as String
                    dictionaryString    = jsonString;
                } catch {
                    observer.sendFailed(ULCError.ERROR_DATA);
                    return;
                }
                
                networkProvider.request(.ProfilesParamsSearch(dictionaryString), completion: { [weak self] (result) in
                    
                    switch (result) {
                    case let .Success(response):
                        do {
                            guard let json = try response.mapJSON() as? [String: AnyObject] else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                            }
                            guard let jsonString = json[ApiManagerKey.response] as? [AnyObject],
                                let items = Mapper<UserEntity>().mapArray(jsonString) else {
                                    observer.sendFailed(ULCError.ERROR_DATA);
                                    return;
                            }
                            self?._usersProfile.value = items
                            observer.sendCompleted();
                        } catch { }
                        break;
                        
                    case .Failure(_):
                        Swift.debugPrint("");
                        break;
                    }})
            }
            
        } else {
            
            return SignalProducer <[UserEntity], ULCError> { observer, disposable in
                
                networkProvider.request(.ProfilesSearch(), completion: { [unowned self] result in
                    
                    switch (result) {
                    case let .Success(response):
                        do {
                            guard let json = try response.mapJSON() as? [String: AnyObject] else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                            }
                            guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                                let items = Mapper<UserEntity>().mapArray(jsonString) else {
                                    observer.sendFailed(ULCError.ERROR_DATA);
                                    return;
                            }
                            self._usersProfile.value = items
                            observer.sendCompleted();
                        } catch { }
                        break;
                        
                    case .Failure(_):
                        break;
                    }
                });
            }
            
        }
    }
    
    func resetUsersProfiles() {
        self._usersProfile.value?.removeAll();
        
        languages.value = []
        gender.value    = 0;
        status.value    = 0;
        level.value     = (1, 100)
    }
}
