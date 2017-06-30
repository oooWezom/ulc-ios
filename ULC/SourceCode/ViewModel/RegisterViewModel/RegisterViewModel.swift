//
//  RegisterViewModel.swift
//  ULC
//
//  Created by Alexey on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import Moya

class RegisterViewModel: GeneralViewModel {
    
    var cocoaActionRegistration: CocoaAction!
    var registrationSignalProducer: Action<(), (), ULCError>!;
    var languageArray = [Int]()
    var inputValidData = MutableProperty<Bool>(false);

	let emailProperty = MutableProperty<String?>("");
	let usernameProperty = MutableProperty<String?>("");
	let passwordProperty = MutableProperty<String?>("");
    let confirmPasswordProperty = MutableProperty<String?>("");
    let dateOfBirthProperty = MutableProperty<String?>("");
    let sexProperty = MutableProperty<Int?>(1);
	let agreementProperty = MutableProperty<Bool>(false);
    let languageSetProperty = MutableProperty<String?>("");
    
    var emailSignalProducer: SignalProducer<Bool, NoError>!;
    var usernameSignalProducer: SignalProducer<Bool, NoError>!;
    var passwordSignalProducer: SignalProducer<Bool, NoError>!;
    var confirmPasswordSignalProducer: SignalProducer<Bool, NoError>!;
    var dateOfBirthSignalProducer: SignalProducer<Bool, NoError>!;
    var languagesSignalProducer: SignalProducer<Bool, NoError>!;
	var agreementSignalProducer: SignalProducer<Bool, NoError>!;
    
    override func configureSignals() {
        
        // MARK Register Producers

		agreementSignalProducer = agreementProperty.producer

        emailSignalProducer = emailProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where text?.characters.count <= 50 && value.isValidEmail || value == "" else {
                    return false
                }
                return true
        }
        
        usernameSignalProducer = usernameProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value.characters.count >= 3 && value.characters.count <= 20 || value == "" else {
                    return false;
                }
                return true;
        }
        
        passwordSignalProducer = passwordProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value.characters.count >= 8 && value.characters.count <= 32 || value == "" else {
                    return false;
                }
                return true;
        }
        
        confirmPasswordSignalProducer = confirmPasswordProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value == self.passwordProperty.value && value.characters.count >= 8 || value == "" else {
                    return false
                }
                return true;
        }
        
        dateOfBirthSignalProducer = dateOfBirthProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value.characters.count == 10 || value == "" else {
                    return false;
                }
                return true
        }
        
        languagesSignalProducer = languageSetProperty
            .producer
            .map { (text: String?) -> Bool in
                guard let value = text where value == "" else {
                    return true;
                }
                return false
        }
        
        inputValidData <~ combineLatest([agreementSignalProducer,emailSignalProducer, usernameSignalProducer, passwordSignalProducer, confirmPasswordSignalProducer, dateOfBirthSignalProducer, languagesSignalProducer])
            .flatMap((.Latest), transform: { (credentionals: [Bool]) -> SignalProducer<Bool, NoError> in
                return SignalProducer<Bool, NoError> {
                    
                    observer, disposable in
                    
                    if self.isTextFieldEmpty() && !credentionals.contains(false){
                        observer.sendNext(true);
                    } else {
                        observer.sendNext(false);
                    }
                    observer.sendCompleted();
                }
            });
        
        // MARK Registration Action
        registrationSignalProducer = Action<(),(), ULCError> { [unowned self] _ in
            return self.registerUser()
        }
        
        cocoaActionRegistration = CocoaAction(registrationSignalProducer, input:());
    }
    
    func registerUser() -> SignalProducer<(), ULCError> {
        
        return SignalProducer<(), ULCError> { [unowned self]
            observer, disposable in
            
            let email = self.emailProperty.value!
            let userName = self.usernameProperty.value!
            let passwors = self.passwordProperty.value!
            let dateOfBirth = self.dateOfBirthProperty.value!
            let sex = self.sexProperty.value!
            let language = self.languageArray
            
            networkProvider.request(.Registration(email, userName, passwors, dateOfBirth, sex, language), completion: { result in
                switch(result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            
                            if let status = json[MapperKey.result] as? String where status == "ok"{
                                observer.sendNext();
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
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            });
        };

	}
    
    private func isTextFieldEmpty() -> Bool {
        if  self.emailProperty.value! != "" &&
            self.usernameProperty.value! != "" &&
            self.passwordProperty.value! != "" &&
            self.confirmPasswordProperty.value! != "" &&
            self.dateOfBirthProperty.value! != "" &&
            self.languageSetProperty.value! != "" {
            return true
        } else {
            return false
        }
    }
}
