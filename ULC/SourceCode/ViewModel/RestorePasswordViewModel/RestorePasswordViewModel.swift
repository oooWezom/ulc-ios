//
//  RestorePasswordViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/24/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SwiftKeychainWrapper

class RestorePasswordViewModel: GeneralViewModel {

	var restorePasswordSignalProducer: Action<(), (), NSError>!;

	let passwordProperty = MutableProperty<String?>("")
	let repeatPasswordProperty = MutableProperty<String?>("")

	var inputValidData = MutableProperty<Bool>(false);

	var passwordSignalProducer: SignalProducer<Bool, NoError>!;
	var repeatPasswordSignalProducer: SignalProducer<Bool, NoError>!;

	override func configureSignals() {
		passwordSignalProducer = passwordProperty
			.producer
			.map { (text:String?) -> Bool in
				guard let value = text where value.characters.count >= 8 && value.characters.count <= 32 || value == "" else {
					return false
				}
				return true
		}

		repeatPasswordSignalProducer = repeatPasswordProperty
		.producer
			.map { (text:String? ) -> Bool in

				guard let value = text where value == self.passwordProperty.value || value == "" else{
					return false;
				}
				return true
		}

		inputValidData <~ combineLatest([passwordSignalProducer,repeatPasswordSignalProducer])
			.flatMap((.Latest), transform: { (credentionals: [Bool]) -> SignalProducer<Bool, NoError> in
				return SignalProducer<Bool, NoError> {
					observer, disposable in
					if self.isTextFieldsEmpty() && credentionals[0] && credentionals[1] {
						observer.sendNext(true);
					} else {
						observer.sendNext(false);
					}
					observer.sendCompleted();
				}
			});
	}

	private func isTextFieldsEmpty() -> Bool {

		if  self.passwordProperty.value! != "" &&
			self.repeatPasswordProperty.value! != "" {
			return true

		} else {
			return false
		}
	}

	func restorePassword(key:String, password:String) -> SignalProducer<(), ULCError> {

		return SignalProducer<(), ULCError> { [unowned self]
			observer, disposable in
			networkProvider.request(.ConfirmRestorePassword(key, password), completion: { [weak self] result in

				switch(result) {

				case let .Success(response):
					do {
						guard let json = try response.mapJSON() as? [String:AnyObject] else {
							observer.sendFailed(ULCError.ERROR_DATA)
							return
						}

						if	let result = json[MapperKey.result] as? String where result == "ok",
									let token = json[MapperKey.token] as? String where !token.isEmpty,
									let userId = json[MapperKey.id] as? Int where userId > -1 {

							KeychainWrapper.setString(token, forKey: Constants.keyChainValue)
							KeychainWrapper.setString(String(userId), forKey: Constants.currentUserId)

							observer.sendNext();
							observer.sendCompleted();

							if result == "error" {
								observer.sendFailed(ULCError.ERROR_DATA)
							} else {
								self?.presenter.openContainerVC();
							}



						}

					} catch {

					}
					break

				case .Failure(_):
					observer.sendFailed(ULCError.ERROR_DATA)
					break

				}

			})
		}
	}
}