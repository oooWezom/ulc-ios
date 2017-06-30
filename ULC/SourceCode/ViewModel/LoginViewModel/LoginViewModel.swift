//
//  LoginViewModel.swift
//  ULC
//
//  Created by Alex on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import Moya
import SwiftKeychainWrapper

class LoginViewModel: GeneralViewModel, Logining {
    
    var cocoaActionLogin: CocoaAction!
    var loginSignalProducer: Action<(), (), ULCError>!;
    
    let userNameProperty = MutableProperty<String?>(nil);
    let userPasswordProperty = MutableProperty<String?>(nil);
    
    // MARK Private properties
    let loginInputValid = MutableProperty<Bool>(false)
    
    override func configureSignals() {
        
        // MARK Login Producers
        let userNameSignalProducer = userNameProperty
            .producer
            .map { (text: String?) -> String in
                return text.or("");
                }
        
        let userPassworSignalProducer = userPasswordProperty
            .producer
            .map { (text: String?) -> String in
                return text.or("");
                }
        
        loginInputValid <~ combineLatest([userNameSignalProducer, userPassworSignalProducer]).flatMap((.Latest), transform: { (credentionals: [String]) -> SignalProducer<Bool, NoError> in
            return SignalProducer<Bool, NoError> {
                
                observer, disposable in
                
                if let userName = credentionals.first where userName.characters.count > 2 && userName.characters.count < 32,
                   let password = credentionals.last where  password.characters.count >= 1 {
                    observer.sendNext(true);
                } else {
                    observer.sendNext(false);
                }
                observer.sendCompleted();
            }
        });
        // MARK Login Action
        loginSignalProducer = Action<(),(), ULCError>(enabledIf: loginInputValid) { [unowned self] _ in
            return self.loginUser()
        }
        
        cocoaActionLogin = CocoaAction(loginSignalProducer, input:());
    }
    
    func loginUser() -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { [unowned self]
            observer, disposable in
            
            let user = self.userNameProperty.value!
            let password = self.userPasswordProperty.value!
            
            networkProvider.request(.Login(user,password), completion: { [weak self] result in
                switch(result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if  let status = json[MapperKey.result] as? String where status == "ok",
                                let token = json[MapperKey.token] as? String where !token.isEmpty,
                                let userId = json[MapperKey.id] as? Int where userId > -1 {
                                
                                KeychainWrapper.setString(token, forKey: Constants.keyChainValue)
                                KeychainWrapper.setString(String(userId), forKey: Constants.currentUserId)
                                
                                NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.runAfterDelete);
                                NSUserDefaults.standardUserDefaults().synchronize();
                                
                                observer.sendNext();
                                observer.sendCompleted();
                                
                                self?.presenter.openContainerVC();
         
                            } else {
                                if let errorString = json[MapperKey.message] as? String where !errorString.isEmpty,
                                    let error = json[MapperKey.error] as? Int where error == ULCError.ERROR_WRONG_LOGIN_OR_PASSWORD._code {
                                    observer.sendFailed( .ERROR_WRONG_LOGIN_OR_PASSWORD);
                                }
                            }
                        }
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            });
        };
    }
    
    func logOut() -> SignalProducer<(), ULCError> {
        return SignalProducer<(), ULCError> { observer, disposable in
            networkProvider.request(.LogOut(), completion: { result in
                switch (result) {
                case .Success(_):
                    KeychainWrapper.removeObjectForKey(Constants.keyChainValue);
                    KeychainWrapper.removeObjectForKey(Constants.currentUserId);
                    observer.sendCompleted()
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA)
                    break;
                }
            });
        };
    }
    
    func launchAnonymousMode() {
        presenter.openMainAnonymousVC();
    }
}
