//
//  RegisterViewController.swift
//  ULC
//
//  Created by Alexey on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import Result
import MBProgressHUD

class RegisterViewController: BaseViewController, LanguageDelegate {

    // MARK private properties
    private var cocoaAction: CocoaAction?
	private let viewModel = RegisterViewModel();
    private let presenter = PresenterImpl()
    private let datePicker = UIDatePicker()
    private let doneButton = UIButton(frame: CGRectMake(0, 0, 100, 50))
	private var agrrementIsChecked = false

    // MARK IB Outlets
	@IBOutlet weak var bottomCoverImageView: UIImageView!
	@IBOutlet weak var topCoverImageView: UIImageView!

	@IBOutlet weak var emailTextField: LoginTextField!
	@IBOutlet weak var usernameTextField: LoginTextField!
	@IBOutlet weak var passwordTextField: LoginTextField!
	@IBOutlet weak var confirmPasswordTextField: LoginTextField!
    @IBOutlet weak var languageTextField: LoginTextField!
    @IBOutlet weak var dateOfBirthTextField: LoginTextField!
    
    @IBOutlet weak var incorrectEmailImageView: UIImageView!
    @IBOutlet weak var incorrectUsernameImageView: UIImageView!
    @IBOutlet weak var incorrectPasswordImageView: UIImageView!
    @IBOutlet weak var incorrectConfirmImageView: UIImageView!
    @IBOutlet weak var incorrectDateOfBirthImageView: UIImageView!
    @IBOutlet weak var incorrectLanguageImageView: UIImageView!

	@IBOutlet weak var sexSegmentControl: UISegmentedControl!

	@IBOutlet weak var agreementLabel: UILabel!
	@IBOutlet weak var checkButton: UIButton!
	//@IBOutlet weak var agreeButton: UIButton!

	@IBAction func checkAction(sender: AnyObject) {
		checkAgreement()
	}

	/*
	@IBAction func agreeAction(sender: AnyObject) {
		checkAgreement()
	}
*/

	@IBAction func userSexSegmentControlAction(sender: AnyObject) {
		switch sexSegmentControl.selectedSegmentIndex
		{
		case 0:
			viewModel.sexProperty.value = 2;
			break

		case 1:
			viewModel.sexProperty.value = 1;
			break

		default:
			break;
		}
	}
    
    @IBAction func setDateOfBirhTextField(sender: LoginTextField) {
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.maximumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -1, toDate: NSDate(), options: [])
        sender.inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }

    @IBAction func editLanguageTextField(sender: AnyObject) {
        if let languageViewController = presenter.getLanguageController() {
            languageViewController.delegate = self
            presenter.pushWithViewController(languageViewController)
            view.endEditing(true)
        }
    }

	private func checkAgreement() {
		if agrrementIsChecked {
			agrrementIsChecked = false
			viewModel.agreementProperty.value = false
			if let agreementCheckImage = R.image.agreement_uncheck(){
				checkButton.setImage(agreementCheckImage, forState: .Normal)
			}

		} else {
			agrrementIsChecked = true
			viewModel.agreementProperty.value = true
			if let agreementUncheckImage  = R.image.agreement_check(){
				checkButton.setImage(agreementUncheckImage, forState: .Normal)
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		configure();
    }
 
    private func configure() {
        configureViews();
        confgiureSignals();
	}
    
    private func configureViews() {

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        doneButton.addTarget(viewModel.cocoaActionRegistration, action: CocoaAction.selector, forControlEvents: .TouchUpInside)
        doneButton.contentHorizontalAlignment = .Right
		
        let enabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonEnable)]
        let disabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonDisable)]

		let doneString = R.string.localizable.done()

        let doneText = NSAttributedString(string: doneString, attributes: enabledAttribute)
        let notDoneText = NSAttributedString(string: doneString, attributes: disabledAttribute)

		//
		self.title = R.string.localizable.sing_up()
       // doneButton.titleLabel?.adjustsFontSizeToFitWidth = true
		//
		
        doneButton.setAttributedTitle(doneText, forState: .Normal)
        doneButton.setAttributedTitle(notDoneText, forState: .Disabled)
        
        let rightButton = UIBarButtonItem(customView: doneButton)
        
        self.navigationItem.setRightBarButtonItems([rightButton], animated: true)
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        
        self.hideKeyboardWhenTappedAround()
        
        incorrectLanguageImageView.hidden = true
        
        cameraWithBlurEffect(topCoverImageView, bottomCoverImageView: bottomCoverImageView)

		emailTextField.placeholder = R.string.localizable.email_placeholder()
		usernameTextField.placeholder = R.string.localizable.username_placeholder()
		passwordTextField.placeholder = R.string.localizable.password_placeholder()
		confirmPasswordTextField.placeholder = R.string.localizable.confirm_password()
		sexSegmentControl.setTitle(R.string.localizable.male(), forSegmentAtIndex: 0)
		sexSegmentControl.setTitle(R.string.localizable.female(), forSegmentAtIndex: 1)
		dateOfBirthTextField.placeholder = R.string.localizable.date_of_birth()
		languageTextField.placeholder = R.string.localizable.language()

		let termConditionsButtonAttrs = [
			NSFontAttributeName:UIFont.systemFontOfSize(17.0),
			NSUnderlineStyleAttributeName: 1
		]

		let termConditionsAttributedString = NSMutableAttributedString(string:"")

		let termConditionsButtonTitle = NSMutableAttributedString(string:R.string.localizable.terms_and_conditions(), attributes: termConditionsButtonAttrs)
		termConditionsAttributedString.appendAttributedString(termConditionsButtonTitle)


		let agreenentButtonAttrs = [
			NSFontAttributeName:UIFont.systemFontOfSize(17.0)
		]

		let agreementAttributedString = NSMutableAttributedString(string:"")

		let agreementButtonTitle = NSMutableAttributedString(string:R.string.localizable.agreement(), attributes: agreenentButtonAttrs)
		agreementAttributedString.appendAttributedString(agreementButtonTitle)

		let result = NSMutableAttributedString()

		result.appendAttributedString(agreementAttributedString)
		result.appendAttributedString(NSMutableAttributedString(string:" "))
		result.appendAttributedString(termConditionsAttributedString)

		let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.agreementAction))
		agreementLabel.userInteractionEnabled = true
		agreementLabel.addGestureRecognizer(tap)
		agreementLabel.attributedText = result

		checkAgreement()
    }

	func agreementAction(){
		presenter.openAgreementVC()
	}
    
	private func confgiureSignals() {
        
        // MARK button enable when email is valid
        doneButton.rac_enabled <~ viewModel.inputValidData
        
        // MARK show error images when text field is incorrect
        incorrectEmailImageView.rac_hidden <~ viewModel.emailSignalProducer
        incorrectUsernameImageView.rac_hidden <~ viewModel.usernameSignalProducer
        incorrectPasswordImageView.rac_hidden <~ viewModel.passwordSignalProducer
        incorrectConfirmImageView.rac_hidden <~ viewModel.confirmPasswordSignalProducer
        incorrectDateOfBirthImageView.rac_hidden <~ viewModel.dateOfBirthSignalProducer
        
		let emailProducer = self.racTextProducer(emailTextField)
		let userNameProducer = self.racTextProducer(usernameTextField)
		let passwordProducer = self.racTextProducer(passwordTextField)
        let confirmPasswordProducer = self.racTextProducer(confirmPasswordTextField)
        let dateOfBirthProduser = self.racTextProducer(dateOfBirthTextField)
        
        viewModel.emailProperty <~ emailProducer
        viewModel.usernameProperty <~ userNameProducer
        viewModel.passwordProperty <~ passwordProducer
        viewModel.confirmPasswordProperty <~ confirmPasswordProducer
        viewModel.dateOfBirthProperty <~ dateOfBirthProduser
        
        viewModel.registrationSignalProducer.executing.producer.observeOn(UIScheduler()).startWithNext { (value: Bool) in
            if value {
                self.view.endEditing(true);
                MBProgressHUD.showHUDAddedTo(self.view, animated: true);
            }
        }
        
        viewModel.registrationSignalProducer
            .events
            .observeOn(UIScheduler())
            .observeNext{ [unowned self] (event) in
                switch event {
                    
                case .Completed:
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.presenter.openConfirmRegisterVC()
                    break
                    
                case .Failed(let error):
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.showULCError(error)
                    break;
                    
                case .Next(_):
                    break;
                    
                default:
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    break;
                }
        }
	}
    
    func setLanguages(languages: [LanguageEntity]) {
        let namesArray = languages.map( { $0.displayName })
        let namesString = namesArray.joinWithSeparator(", ")
        self.languageTextField.text = namesString
        
        viewModel.languageArray = languages.map( { $0.id })

        viewModel.languageSetProperty <~ SignalProducer<String?, NoError> { (observer, disposable) in
            observer.sendNext(namesString)
            observer.sendCompleted()
            }.on()
    }
    
    func datePickerValueChanged(sender: UIDatePicker){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateOfBirthTextField.text = dateFormatter.stringFromDate(sender.date)
    }
}
