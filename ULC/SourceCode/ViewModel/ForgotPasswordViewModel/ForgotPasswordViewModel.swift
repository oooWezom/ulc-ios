//
//  ForgotPasswordViewModel.swift
//  ULC
//
//  Created by Vitya on 6/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ForgotPasswordViewModel: GeneralViewModel {
    
    var cocoaActionRestorePassword: CocoaAction!
    var restorePasswordSignalProducer: Action<(), (), NSError>!;
    
    let emailProperty = MutableProperty<String?>(nil);
    
    // MARK Private properties
    let emailInputValid = MutableProperty<Bool>(false)
    let emailInputValidError = MutableProperty<Bool>(true)
    
    override func configureSignals() {
        
        // MARK ForgotPassword Producers
        let emailSignalProducer = emailProperty
            .producer
            .map { (text: String?) -> Bool in
                if let returnValue = text where returnValue.characters.count > 2 && returnValue.characters.count < 50 && returnValue.isValidEmail {
                    return true;
                }
                return false;
        }
        
        let emailErrorSignalProducer = emailProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where text?.characters.count <= 50 && value.isValidEmail || value == "" else {
                    return false
                }
                return true
        }
        
        emailInputValid <~ emailSignalProducer
        emailInputValidError <~ emailErrorSignalProducer
        
        // MARK restorePassword Action
        restorePasswordSignalProducer = Action<(),(), NSError>(enabledIf: emailInputValid) { [unowned self] _ in
            return self.restorePassword()
        }
        
        cocoaActionRestorePassword = CocoaAction(restorePasswordSignalProducer, input:());
    }
    
    func restorePassword() -> SignalProducer<(), NSError> {
        
        return SignalProducer<(), NSError> { [unowned self] observer, disposable in
            
            let email = self.emailProperty.value!
            
            networkProvider.request(.RestorePassword(email), completion: { result in
                switch(result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if let status = json["result"] as? String where status == "ok" {
                                
                                observer.sendNext();
                                observer.sendCompleted();
                                
                            } else {
                                if let errorString = json["message"] as? String where !errorString.isEmpty {
                                    let error =  NSError(domain: errorString, code: -1, userInfo: nil);
                                    observer.sendFailed(error);
                                }
                            }
                        }
                    } catch {
                        let error = NSError(domain: "Error fetch data from server", code: -1, userInfo: nil)
                        observer.sendFailed(error)
                    }
                    break;
                    
                case let .Failure(error):
                    
                    var message = "";
                    guard let error = error as? CustomStringConvertible else {
                        message = "Failure fetch data from server"
                        break
                    }
                    message = error.description
                    observer.sendFailed(NSError(domain: message, code: -1, userInfo: nil))
                    break;
                }
            });
        };
    }
}
