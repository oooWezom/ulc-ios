//
//  ChangePasswordViewModel.swift
//  ULC
//
//  Created by Vitya on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

class ChangePasswordViewModel: GeneralViewModel {
    
    let oldPasswodProperty = MutableProperty<String?>("");
    let newPasswordProperty = MutableProperty<String?>("");
    let repeatNewPasswordProperty = MutableProperty<String?>("");
    
    var oldPasswodProducer: SignalProducer<Bool, NoError>!;
    var newPasswordProducer: SignalProducer<Bool, NoError>!;
    var repeatNewPasswordProducer: SignalProducer<Bool, NoError>!;
    
    var inputValidData = MutableProperty<Bool>(false);
    
    override func configureSignals() {
        
        // MARK Register Producers
        oldPasswodProducer = oldPasswodProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value.characters.count >= 1 && value.characters.count <= 32 || value == "" else {
                    return false;
                }
                return true;
        }
        
        newPasswordProducer = newPasswordProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value.characters.count >= 8 && value.characters.count <= 32 || value == "" else {
                    return false
                }
                return true;
        }

        repeatNewPasswordProducer = repeatNewPasswordProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value == self.newPasswordProperty.value || value == "" else{
                    return false;
                }
                return true;
        }
        
        inputValidData <~ combineLatest([oldPasswodProducer, newPasswordProducer, repeatNewPasswordProducer])
            .flatMap((.Latest), transform: { (credentionals: [Bool]) -> SignalProducer<Bool, NoError> in
                return SignalProducer<Bool, NoError> {
                    
                    observer, disposable in
                    
                    if self.isTextFieldsEmpty() && credentionals[0] && credentionals[1] && credentionals[2] {
                        observer.sendNext(true);
                    } else {
                        observer.sendNext(false);
                    }
                    observer.sendCompleted();
                }
            });
    }
    
    func changePassword() -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { [unowned self]
            observer, disposable in
            
			let password = self.oldPasswodProperty.value!
			let newPassword = self.newPasswordProperty.value!
            
            networkProvider.request(.UpdatePassword(password, newPassword), completion: { result in
                switch(result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if  let status = json[MapperKey.result] as? String where status == "ok" {
                                
                                observer.sendCompleted();
                                
                            } else {
                                if let errorString = json[MapperKey.message] as? String where !errorString.isEmpty,
                                    let error = json[MapperKey.error] as? Int where error == ULCError.ERROR_WRONG_LOGIN_OR_PASSWORD._code {
                                    observer.sendFailed( .ERROR_WRONG_LOGIN_OR_PASSWORD);
                                }
                            }
                        }
                    } catch {
                        observer.sendFailed( .ERROR_DATA);
                    }
                    break;
                case .Failure(_):
                    observer.sendFailed( .ERROR_DATA);
                    break;
                }
            });
        };
    }
    
    private func isTextFieldsEmpty() -> Bool {
        
        if  self.oldPasswodProperty.value! != "" &&
            self.newPasswordProperty.value! != "" &&
            self.repeatNewPasswordProperty.value! != "" {
            
            return true
            
        } else {
            return false
        }
    }
}
