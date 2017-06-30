//
//  Logining.swift
//  ULC
//
//  Created by Alex on 10/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol Logining: ViewModelTargetType, VersionApiCheckable {
    
    var loginSignalProducer: Action<(), (), ULCError>! { get };
    var cocoaActionLogin: CocoaAction! { get };
    var userNameProperty: MutableProperty<String?> { get };
    var userPasswordProperty: MutableProperty<String?> { get };
    
    func loginUser() -> SignalProducer<(), ULCError>;
    func logOut() -> SignalProducer<(), ULCError>;
    
    func launchAnonymousMode();
    
    var loginInputValid: MutableProperty<Bool> { get }
}
