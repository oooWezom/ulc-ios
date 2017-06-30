//
//  ChangePasswordViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/23/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

class RestorePasswordViewController: BaseViewController {

	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var restorePasswordLabel: UILabel!
	@IBOutlet weak var passwordTextField: LoginTextField!
	@IBOutlet weak var repeatePasswordTextField: LoginTextField!
	@IBOutlet weak var nextButton: UIButton!
	@IBOutlet weak var bottomCoverImageView: UIImageView!
	@IBOutlet weak var topCoverImageView: UIImageView!
	@IBOutlet weak var incorrectPasswordImageView: UIImageView!
	@IBOutlet weak var incorrectRepeatPasswordImageView: UIImageView!

	private let viewModel = RestorePasswordViewModel();
	var key:String?

	@IBAction func nextAction(sender: AnyObject) {
		if let key = key, let password = repeatePasswordTextField.text where !password.isEmpty {
			viewModel.restorePassword(key, password: password).startWithCompleted {
				self.viewModel.presenter.openContainerVC()
			}

			viewModel.restorePassword(key, password: password).startWithFailed {_ in 
				self.statusLabel.text = R.string.localizable.error()
			}

		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}

	private func configure() {
		configureView()
		cameraWithBlurEffect(topCoverImageView, bottomCoverImageView: bottomCoverImageView)
		configureSignals()
	}

	func configureView() {
		self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
		self.hideKeyboardWhenTappedAround()

		nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonNormal)), forState: .Normal)
		nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonSelected)), forState: .Selected)
		nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonSelected)), forState: .Highlighted)

		nextButton.setTitle(R.string.localizable.next(), forState: .Normal)

		restorePasswordLabel.text = R.string.localizable.enter_new_password()
		self.title = R.string.localizable.restore_password_view_controller()

		passwordTextField.placeholder = R.string.localizable.new_password().lowercaseString
		repeatePasswordTextField.placeholder = R.string.localizable.repeat_new_password().lowercaseString

		passwordTextField.secureTextEntry = true
		repeatePasswordTextField.secureTextEntry = true
	}

	func configureSignals() {
		incorrectPasswordImageView.rac_hidden <~ viewModel.passwordSignalProducer
		incorrectRepeatPasswordImageView.rac_hidden <~ viewModel.repeatPasswordSignalProducer

		let passwordProducer = racTextProducer(passwordTextField)
		let repeatPasswordProducer = racTextProducer(repeatePasswordTextField)

		viewModel.passwordProperty <~ passwordProducer
		viewModel.repeatPasswordProperty <~ repeatPasswordProducer

		nextButton.rac_enabled <~ viewModel.inputValidData
	}

}