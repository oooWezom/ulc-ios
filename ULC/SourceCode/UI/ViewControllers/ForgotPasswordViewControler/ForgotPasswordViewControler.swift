//  Created by Vitya on 6/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MBProgressHUD

class ForgotPasswordViewControler: BaseViewController {
    
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var confirmLabel: UILabel!
    
	@IBOutlet weak var recoveryPasswordLabel: UILabel!
    @IBOutlet weak var bottomCoverImageView: UIImageView!
    @IBOutlet weak var topCoverImageView: UIImageView!
    @IBOutlet weak var incorrectEmalImageView: UIImageView!
    
    private let viewModel = ForgotPasswordViewModel();
    private let presenter = PresenterImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure();
    }
    
    private func configure() {
        configureViews();
        cameraWithBlurEffect(topCoverImageView, bottomCoverImageView: bottomCoverImageView)
        configureSignals();
    }
    
    private func configureViews() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonNormal)), forState: .Normal)
        nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonSelected)), forState: .Selected)
        nextButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .ForgotPasswordButtonSelected)), forState: .Highlighted)
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        
        confirmLabel.hidden = true
		self.title = R.string.localizable.forget_password()
        
        self.hideKeyboardWhenTappedAround()

		recoveryPasswordLabel.text = R.string.localizable.recover_email()
		emailTextField.placeholder = R.string.localizable.email_placeholder()
		nextButton.setTitle(R.string.localizable.next_button_title(), forState: .Normal)

		#if DEBUG
		emailTextField.text = "adamluissean@gmail.com"
		#endif
    }
    
    private func configureSignals() {
        
        // MARK button enable when email is valid
        nextButton.rac_enabled <~ viewModel.emailInputValid
        
        // MARK errorIcon show when email is invalid
        incorrectEmalImageView.rac_hidden <~ viewModel.emailInputValidError
        
        let emailProducer = self.racTextProducer(emailTextField)
        viewModel.emailProperty <~ emailProducer
        
        nextButton.addTarget(viewModel.cocoaActionRestorePassword, action: CocoaAction.selector, forControlEvents: .TouchUpInside);
        
        viewModel.restorePasswordSignalProducer.executing.producer.observeOn(UIScheduler()).startWithNext { [unowned self] (value: Bool) in
            if value {
                self.view.endEditing(true);
                self.nextButton.enabled = false
                MBProgressHUD.showHUDAddedTo(self.view, animated: true);
            }
        }
        
        viewModel.restorePasswordSignalProducer
            .events
            .observeOn(UIScheduler())
            .observeNext{ [unowned self] (event) in
                self.confirmLabel.hidden = false
                switch event {
                    
                case .Completed:
                    self.confirmSuccess()
                    
                    break
                    
                case .Failed(let error):
                    self.confirmFailed(error)
                    
                    break;
                    
                case .Next(_):
                    break;
                    
                default:
                    self.confirmLabel.text = R.string.localizable.confirm_send_email()
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    break;
                }
        }

    }
    
    private func confirmSuccess() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        self.confirmLabel.text = R.string.localizable.confirm_send_email()
        self.emailTextField.enabled = false
        self.nextButton.hidden = true
    }
    
    private func confirmFailed(error: NSError) {
        self.nextButton.enabled = true
        self.confirmLabel.text = error.domain
        self.incorrectEmalImageView.hidden = false
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
}
