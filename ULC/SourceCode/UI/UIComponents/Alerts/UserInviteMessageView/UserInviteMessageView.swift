//
//  UserMessageView.swift
//  ULC
//
//  Created by Vitya on 6/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol UserInviteMessageDelegate {
    func inviteTimeIsOver()
}

class UserInviteMessageView: UIView, NibLoadableView, UITextFieldDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var delayDecisionLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var delayTimeTextField: UITextField!
    
    var delegate: UserInviteMessageDelegate?
    
    var timer = NSTimer()
    var seconds = CGFloat()
    var senderProfileID: Int?;
    
    let maxSecondInterval: CGFloat = 10
    let timerStep: CGFloat = 0.1
    let outerCircle = CAShapeLayer()
    let maxMinutesValue = 1440
    
    private let categoryViewModel = CategoryViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(delayDecisionLabelTouch))
        delayDecisionLabel.addGestureRecognizer(tapGesture)
        
        avatarImageView.roundedView(true, borderColor: UIColor(named: .NavigationBarColor), borderWidth: 2.0, cornerRadius: nil);
        
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        delayDecisionLabel.userInteractionEnabled = true
        
        delayTimeTextField.tintColor = UIColor(named: .LoginButtonNormal)
        delayTimeTextField.keyboardType = .NumberPad
        delayTimeTextField.delegate = self
        
        seconds = maxSecondInterval
        
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        
        delayTimeTextField.hidden = true
        
        setTimerProgressToAvatar()
		configereViews()
    }

	func configereViews(){
		messageLabel.text = R.string.localizable.username_invite_title()
		delayDecisionLabel.text = R.string.localizable.delay_decision()
		delayTimeTextField.placeholder = R.string.localizable.minutes()
		okButton.setTitle(R.string.localizable.ok(), forState: .Normal)
		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
		//#MARK localized
	}

    func setTimerProgressToAvatar() {
        let frameSize = avatarImageView.frame.size
        outerCircle.path = UIBezierPath(ovalInRect: CGRect(x: 2.5, y: 2.5, width: frameSize.width-5, height: frameSize.height-5)).CGPath
        outerCircle.lineWidth = 2
        outerCircle.lineCap = kCALineCapRound
        outerCircle.fillColor = UIColor.clearColor().CGColor
        outerCircle.strokeColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.addSublayer(outerCircle)
    }
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timerStep.doubleValue, target: self, selector:  #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer.invalidate()
        seconds = maxSecondInterval
        outerCircle.strokeEnd = seconds * 0.1
    }
    
    func update() {
        if(seconds < 0)
        {
            stop()
            delegate?.inviteTimeIsOver()
        } else {
            seconds = seconds - timerStep
            outerCircle.strokeEnd = seconds * 0.1
        }
    }
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let inviteEntity = model as? WSInviteEntity, let sender = inviteEntity.sender else {
            return;
        }
        
        senderProfileID = sender.id

        messageLabel.text = (inviteEntity.sender?.name)! + " \(R.string.localizable.invites_session_message())"
        
        let avatarUrl = NSURL(string: Constants.userContentUrl + (inviteEntity.sender?.avatar)!);
        if let url = avatarUrl {
            avatarImageView.kf_setImageWithURL(url,
                                               placeholderImage: R.image.default_small_avatar(),
                                               optionsInfo: nil,
                                               progressBlock: nil,
                                               completionHandler: nil)
        }
        
        categoryViewModel.fetchCategory(inviteEntity.category)
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) -> () in
                observer.observeResult { observer in
                    
                    if let category = observer.value {
                        var url = String()
                        
                        if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
                            url = Constants.smallTalkCategoryIconUrl + category.icon
                        } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
                            url = Constants.threeXsmallTalkCategoryIconUrl + category.icon
                        }
                        self?.categoryImageView.kf_setImageWithURL(NSURL(string: url));
                    }
                }
        }
    }
    
    // MARK: - tapGesture method
    func delayDecisionLabelTouch() {
        delayTimeTextField.text = ""
        delayTimeTextField.hidden = false
        delayTimeTextField.becomeFirstResponder()
    }
    
    // MARK: - UITextField delegate method
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let inputStr = textField.text?.stringByAppendingString(string) else {
            return false
        }
        
        let inputInt = Int(inputStr)
        if inputInt > 0 && inputInt <= maxMinutesValue {
            return true
        } else {
            return false
        }
    }
}
