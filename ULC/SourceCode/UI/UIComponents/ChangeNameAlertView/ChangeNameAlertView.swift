//
//  ChangeNameAlertView.swift
//  ULC
//
//  Created by Vitya on 10/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ChangeNameAlertView: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
	@IBOutlet weak var changeSessinNameLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var alertBackgroundView: UIView!
    
    @IBAction func closeAlertView(sender: AnyObject) {
        hideAlertMessage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSignals()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setFocusOnTextView()
    }
    
    func configureView() {
        
        messageTextField.delegate = self
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        okButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        okButton.enabled = false
        
        alertBackgroundView.layer.masksToBounds = true
        alertBackgroundView.layer.cornerRadius = 10
        
        hideKeyboardWhenTappedAround()

		changeSessinNameLabel.text = R.string.localizable.change_session_name()
		okButton.setTitle(R.string.localizable.ok(), forState: .Normal)
		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
    }
    
    private func configureSignals() {
        
        messageTextField.rac_text.producer
            .map { [unowned self] text in
                self.okButton.enabled = !text.isEmpty
            }
            .start()
    }
    
    func setFocusOnTextView() {
        messageTextField.text = ""
        okButton.enabled = false
        messageTextField.becomeFirstResponder()
    }
    
    func showAlertMessage() {
        
        if let topVC = UIApplication.topViewController() {
            self.view.frame = topVC.view.bounds
            
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            self.didMoveToParentViewController(topVC)
        }
    }
    
    func hideAlertMessage() {
        view.removeFromSuperview()
        
        removeFromParentViewController()
    }
    
    // UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        view.animateViewMoving(true, moveValue: 100)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        view.animateViewMoving(false, moveValue: 100)
    }
}
