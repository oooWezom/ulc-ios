//
//  ChangePasswordViewController.swift
//  ULC
//
//  Created by Vitya on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ChangePasswordViewController: UIViewController {
    
	@IBOutlet weak var oldPasswordLabel: UILabel!
	@IBOutlet weak var changePasswordLabel: UILabel!
	@IBOutlet weak var newPasswordLabel: UILabel!
	@IBOutlet weak var repeatPasswordLabel: UILabel!

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    
    @IBOutlet weak var incorrectOldPasswordImageView: UIImageView!
    @IBOutlet weak var incorrectNewPasswordImageview: UIImageView!
    @IBOutlet weak var incorrectRepeatPasswordImageView: UIImageView!
    
    private var rightButton = UIBarButtonItem()
    
    private let viewModel = ChangePasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSignals()
    }
    
    func configureView() {
        self.title = R.string.localizable.password() //#MARK localized

        rightButton = UIBarButtonItem(title: R.string.localizable.done(), style: .Plain, target: self, action: #selector(doneButtonTouch)); //#MARK localize
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(named: .DoneButtonDisable)], forState: .Disabled)
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(named: .DoneButtonEnable)], forState: .Normal)
        
        self.navigationItem.rightBarButtonItem = rightButton;
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.Plain, target:nil, action:nil)
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        
        oldPasswordTextField.secureTextEntry        = true
        newPasswordTextField.secureTextEntry        = true
        repeatNewPasswordTextField.secureTextEntry  = true
        rightButton.enabled                         = false
        
        hideKeyboardWhenTappedAround()

		changePasswordLabel.text = R.string.localizable.change_password().uppercaseString

		oldPasswordLabel.text = R.string.localizable.old_password()
		newPasswordLabel.text = R.string.localizable.new_password()
		repeatPasswordLabel.text = R.string.localizable.repeat_new_password()
    }
    
    private func configureSignals() {
        
        // MARK show error images when text fields are incorrect
        incorrectOldPasswordImageView.rac_hidden    <~ viewModel.oldPasswodProducer
        incorrectNewPasswordImageview.rac_hidden    <~ viewModel.newPasswordProducer
        incorrectRepeatPasswordImageView.rac_hidden <~ viewModel.repeatNewPasswordProducer
        
        let oldPasswordProducer                     = racTextProducer(oldPasswordTextField)
        let newPasswordProducer                     = racTextProducer(newPasswordTextField)
        let repeatNewPasswordProducer               = racTextProducer(repeatNewPasswordTextField)
        
        viewModel.oldPasswodProperty                <~ oldPasswordProducer
        viewModel.newPasswordProperty               <~ newPasswordProducer
        viewModel.repeatNewPasswordProperty         <~ repeatNewPasswordProducer
        
        rightButton.rac_enabled                     <~ viewModel.inputValidData
    }
    
    func doneButtonTouch() {
        viewModel.changePassword().producer.startWithSignal { (signal, disposable) in
            
            signal.observeCompleted {
                self.showAlertMessage(R.string.localizable.success(), message: R.string.localizable.changes_have_been_successfully_saved(), completitionHandler: nil) //#MARK localized
            }
            
            signal.observeFailed { (error: ULCError) in
                self.showULCError(error)
            }
        }
    }
    
    func racTextProducer(textField: UITextField, throttleValue: Double = 0.5) -> SignalProducer<String?, NoError> {
        return textField
            .rac_textSignal()
            .toSignalProducer()
            .flatMapError({ error in return SignalProducer<AnyObject?, NoError>.empty })
            .map({ text in (text as? String)! })
            .throttle(throttleValue, onScheduler: QueueScheduler.mainQueueScheduler)
    }
}
