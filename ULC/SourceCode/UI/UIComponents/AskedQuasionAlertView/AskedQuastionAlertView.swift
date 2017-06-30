//
//  AskedQuasionAlertView.swift
//  ULC
//
//  Created by Vitya on 9/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

class AskedQuastionAlertView: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
	@IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var alertBackgroundView: UIView!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBAction func closeAlertView(sender: AnyObject) {
        close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureSignals()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setFocusOnTextView()
        sendButton.enabled = false
    }

    private func configureView() {
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        userAvatarImageView.hidden = true
        messageTextView.delegate = self
        
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.borderWidth = 2
        userAvatarImageView.layer.borderColor = UIColor(named: .NavigationBarColor).CGColor
        
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        sendButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        sendButton.enabled = false
        
        alertBackgroundView.layer.masksToBounds = true
        alertBackgroundView.layer.cornerRadius = 10
        
        hideKeyboardWhenTappedAround()

		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
		sendButton.setTitle(R.string.localizable.send(), forState: .Normal)
		askLabel.text = R.string.localizable.ask()
    }
    
    private func configureSignals() {
        messageTextView.rac_textSignal()
            .toSignalProducer()
            .map { text in text as! String }
            .startWithResult { [unowned self] result in
                if let text = result.value {
                    self.sendButton.enabled = !text.isEmpty
                }
        }
        
    }

    func setFocusOnTextView() {
        messageTextView.text = ""
        messageTextView.becomeFirstResponder()
    }
    
    func showAlertMessage() {
        
        if let topVC = UIApplication.topViewController() {
            self.view.frame = topVC.view.bounds

            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            self.didMoveToParentViewController(topVC)
        }
    }
    
    // UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        view.animateViewMoving(true, moveValue: 100)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        view.animateViewMoving(false, moveValue: 100)
    }
    
    func close() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}
