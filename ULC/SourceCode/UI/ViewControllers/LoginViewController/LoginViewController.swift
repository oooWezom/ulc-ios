//
//  ViewController.swift
//  ULC
//
//  Created by Alex on 5/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import Result
import MBProgressHUD

class LoginViewController: BaseViewController {

	// MARK IB Outlets
	@IBOutlet weak var bottomCoverImageView: UIImageView!
	@IBOutlet weak var topCoverImageView: UIImageView!

	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var fbButton: UIButton!
	@IBOutlet weak var vkButton: UIButton!
	@IBOutlet weak var forgetPasswordButton: UIButton!
	@IBOutlet weak var singUpButton: UIButton!

	@IBOutlet weak var userNameTextFiled: LoginTextField!
	@IBOutlet weak var userPasswordTextFiled: LoginTextField!
    
    @IBOutlet weak var watchButton: UIButton!
    
	// MARK private properties
	private let session                = AVCaptureSession()
    private var availableCameraDevices = [];
	private var frontCameraDevice: AVCaptureDevice?;

	override func viewDidLoad() {
		super.viewDidLoad()
        availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
		configure();
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let value = UIInterfaceOrientation.Portrait.rawValue
		UIDevice.currentDevice().setValue(value, forKey: "orientation")

		self.navigationController?.hideTransparentNavigationBar()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.presentTransparentNavigationBar()
	}

	private func configure() {
		configureViews();
		cameraWithBlurEffect(topCoverImageView, bottomCoverImageView: bottomCoverImageView)
		confgiureSignals();

#if DEBUG
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
        //self.userNameTextFiled.text       = "victor1506@rambler.ru";
        //self.userPasswordTextFiled.text   = "12345678";
        
        //self.userNameTextFiled.text       = "b2987214@trbvn.com";
        //self.userPasswordTextFiled.text   = "k12345678";
        
        //self.userNameTextFiled.text         = "Bob";
        //self.userPasswordTextFiled.text     = "InUlcWeTrust";
        
        //self.userNameTextFiled.text       = "adamluissean@gmail.com";
        //self.userPasswordTextFiled.text  = "123456789";
        
        //self.userNameTextFiled.text       = "qa.wezom@gmail.com";
        //self.userPasswordTextFiled.text   = "12345678";
        
        //self.userNameTextFiled.text       = "test.wezom@mail.ru";
        //self.userPasswordTextFiled.text   = "12345678";
        
        //self.userNameTextFiled.text       = "yiruwomaj@stexsy.com";
        //self.userPasswordTextFiled.text   = "12345678";
        
        self.userNameTextFiled.text       = "mobile.dev.1";
        self.userPasswordTextFiled.text   = "3349";
    }
#endif
	}

	private func configureViews() {

		singUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
		forgetPasswordButton.titleLabel?.adjustsFontSizeToFitWidth = true

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

		fbButton.setImage(R.image.fb_login_pressed_icon(), forState: .Selected);
		fbButton.setImage(R.image.fb_login_pressed_icon(), forState: .Highlighted);

		vkButton.setImage(R.image.vk_login_pressed_icon(), forState: .Selected)
		vkButton.setImage(R.image.vk_login_pressed_icon(), forState: .Highlighted)

		userPasswordTextFiled.secureTextEntry = true;

		userNameTextFiled.placeholder = R.string.localizable.email_placeholder()
		userPasswordTextFiled.placeholder = R.string.localizable.password_placeholder()
		signInButton.setTitle(R.string.localizable.log_in(), forState: .Normal)
		singUpButton.setTitle(R.string.localizable.sing_up(), forState: .Normal)
		forgetPasswordButton.setTitle(R.string.localizable.forget_password(), forState: .Normal)
        
        watchButton.setTitle(R.string.localizable.watch(), forState: .Normal);
	}

	private func confgiureSignals() {

		let userNameProducer = racTextProducer(userNameTextFiled).takeUntil(self.rac_willDeallocSignalProducer())
		let userPasswordProducer = racTextProducer(userPasswordTextFiled).takeUntil(self.rac_willDeallocSignalProducer())
        
		loginViewModel.userNameProperty <~ userNameProducer
		loginViewModel.userPasswordProperty <~ userPasswordProducer

		signInButton.addTarget(loginViewModel.cocoaActionLogin, action: CocoaAction.selector, forControlEvents: .TouchUpInside);

		loginViewModel.loginSignalProducer
            .executing
            .producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self](value: Bool) in
			if value {
				self?.view.endEditing(true);
				MBProgressHUD.showHUDAddedTo(self?.view, animated: true);
			}
		}

		loginViewModel.loginSignalProducer
			.events
			.observeOn(UIScheduler())
			.observeNext { [weak self](event) in
				switch event {

				case .Completed:
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
					break

				case .Failed(let error):
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
					self?.showULCError(error)
					break;

				case .Next(_):
					break;

				default:
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
					break;
				}
		}
        signInButton.rac_enabled <~ loginViewModel.loginInputValid;
	}
    
    @IBAction func launchAnonymousMode(sender: AnyObject) {
        loginViewModel.launchAnonymousMode();
    }
}
