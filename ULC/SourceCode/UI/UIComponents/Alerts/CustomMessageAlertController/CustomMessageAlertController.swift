//
//  CustomMessageAlertController.swift
//  ULC
//
//  Created by Vitya on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Starscream
import Foundation

protocol StartGameDelegate: class {
    func openUnityViewController()
    func cancelStartGame()
}

class CustomMessageAlertController: UIViewController, UserInviteMessageDelegate, UserMessageDelegate, GameStartDelegate, UITextFieldDelegate {
    
    let chooseCategoryTableView = ChooseCategoryTableView.instanciateFromNib()
    
    // MARK private properties
    private let userMessageView = UserMessageView.instanciateFromNib();
    private let searchOpponentView = SearchOpponentView.instanciateFromNib();
    private let gameStartView = GameStartView.instanciateFromNib();
    private let reportUserAlertView = ReportUserAlertView.instanciateFromNib();
    private let customInviteMessageView = UserInviteMessageView.instanciateFromNib();
    
    private let alphaView = UIView()
    private var myMutableString = NSMutableAttributedString()
    
    private let viewModel = UserProfileViewModel()
    private weak var wsProfileViewModel: WSProfileViewModel?
    private weak var wsTalkViewModel: WSTalkViewModel?
    
    var blockCloseOnTap = false

    weak var startGameDelegate: StartGameDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isTimerRunning() {
            stopTimer()
            gameStartView.stop()
        }
    }
    
    private func configure() {
        configureViews();
    }
    
    private func configureViews() {
        
        customInviteMessageView.delegate = self
        customInviteMessageView.delayTimeTextField.delegate = self
        userMessageView.delegate = self
        gameStartView.delegate = self
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        alphaView.frame = self.view!.bounds
        alphaView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view!.addSubview(alphaView)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(someAction))
        alphaView.addGestureRecognizer(gesture)
        
        customInviteMessageView.cancelButton.addTarget(self, action: #selector(cancelButtonTouch), forControlEvents: .TouchUpInside)
        customInviteMessageView.okButton.addTarget(self, action: #selector(responseInviteButtonTouch), forControlEvents: .TouchUpInside)
        
        userMessageView.okButton.addTarget(self, action: #selector(okButtonTouch), forControlEvents: .TouchUpInside)
        
        searchOpponentView.cancelButton.addTarget(self, action: #selector(cancelSearchGame), forControlEvents: .TouchUpInside)
        gameStartView.cancelButton.addTarget(self, action: #selector(cancelGameStart), forControlEvents: .TouchUpInside)
        reportUserAlertView.cancelButton.addTarget(self, action: #selector(okButtonTouch), forControlEvents: .TouchUpInside)
    }
    
    func cancelSearchGame(){
        wsProfileViewModel?.cancelGameSearch()
        removeController()
    }
    
    func someAction(sender: UITapGestureRecognizer) {
        if !blockCloseOnTap {
            removeController()
        }
    }
    
    func cancelGameStart(){
        removeController()
        startGameDelegate?.cancelStartGame()
    }
    
    func okButtonTouch() {
        removeController()
    }
    
    func cancelButtonTouch() {
        if let senderId = customInviteMessageView.senderProfileID {
            wsProfileViewModel?.denyTalkSessionInvite(senderId)
            wsTalkViewModel?.denyTalkSessionInvite(senderId)
        }
        removeController()
    }
    
    func responseInviteButtonTouch() {
        guard let senderId = customInviteMessageView.senderProfileID else {
            return
        }
        
        if !customInviteMessageView.delayTimeTextField.hidden, let time = Int(customInviteMessageView.delayTimeTextField.text!) {
            wsProfileViewModel?.inviteResponseNotDisturb(time, senderId: senderId)
            wsTalkViewModel?.inviteResponseNotDisturb(time, senderId: senderId)
        } else {
            wsProfileViewModel?.acceptTalkSessionInvite(senderId)
            wsTalkViewModel?.acceptTalkSessionInvite(senderId)
        }
        
        removeController()
    }
    
    func reportButtonTouch(sender: UIButton) {
        
        self.viewModel.reportUser(sender.tag).start { [unowned self] observer in
            
            switch(observer.event) {
            case .Completed:
                self.removeAllSuperviewsAxceptAlhpaView()

                let alert = UIAlertController(title: R.string.localizable.reported(), message: R.string.localizable.user_has_been_reported(), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Default, handler: { [weak self] action in
                    self?.removeController()
                    }))
                self.presentViewController(alert, animated: true, completion: nil)
                alert.view.tintColor = UIColor(named: .OkButtonNormal)
                
            case .Failed(let error):
                self.removeAllSuperviewsAxceptAlhpaView()
                self.showULCError(error)
                
            default:
                self.removeAllSuperviewsAxceptAlhpaView()
                Swift.debugPrint("another response")
            }
        }
    }
    
    func showReportUserAlertView(model: AnyObject, userId: Int) {
        reportUserAlertView.sendButton.addTarget(self, action: #selector(reportButtonTouch), forControlEvents: .TouchUpInside)
        reportUserAlertView.sendButton.tag = userId
        reportUserAlertView.setFocusOnTextView()
        
        reportUserAlertView.updateViewWithModel(model)
        
        removeAllSuperviewsAxceptAlhpaView()
        
        if let topVC = UIApplication.topViewController() {
            view.frame = topVC.view.bounds
            reportUserAlertView.center = self.view.center
            
            self.view.addSubview(reportUserAlertView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            self.didMoveToParentViewController(topVC)
        }
    }
    
    func showChooseCategoryTableView(userID: Int) {
		self.blockCloseOnTap = false
        removeAllSuperviewsAxceptAlhpaView()
        
        if let topVC = UIApplication.topViewController() {
            view.frame = topVC.view.bounds
            chooseCategoryTableView.center = self.view.center
            
            view.addSubview(chooseCategoryTableView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            didMoveToParentViewController(topVC)
        }
    }
    
    func showUserAlertMessage(model: AnyObject?, message: WSInviteEntity, resultStatus: WSInviteToTalkResponseResult) {
        userMessageView.updateViewWithModel(model, message: message, resultStatus: resultStatus)
        removeAllSuperviewsAxceptAlhpaView()
        
        if let topVC = UIApplication.topViewController() {
            view.frame = topVC.view.bounds
            userMessageView.center = self.view.center
            
            self.view.addSubview(userMessageView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            didMoveToParentViewController(topVC)
        }
    }
    
    func showSearchOpponent(wsProfileViewModel: WSProfileViewModel) {
        removeAllSuperviewsAxceptAlhpaView()
        
        self.wsProfileViewModel = wsProfileViewModel
        
        if let topVC = UIApplication.topViewController() {
            self.view.frame = topVC.view.bounds
            searchOpponentView.updateView(view.frame.size.width * 0.85, height: searchOpponentView.frame.height, center: view.center)
            view.addSubview(searchOpponentView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            didMoveToParentViewController(topVC)
        }
    }
    
    func showGameStart() {
        removeAllSuperviewsAxceptAlhpaView()
        gameStartView.start()
        if let topVC = UIApplication.topViewController() {
            view.frame = topVC.view.bounds
            gameStartView.updateView(self.view!.frame.size.width * 0.85, height: searchOpponentView.frame.height, center: self.view.center)
            view.addSubview(gameStartView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            didMoveToParentViewController(topVC)
        }
    }
    
    func showUserInviteAlertMessage(model: AnyObject?, wsProfileViewModel: WSProfileViewModel?, wsTalkViewModel: WSTalkViewModel?) {

        if isTimerRunning() {
            stopTimer()
            gameStartView.stop()
        }
        
        blockCloseOnTap = true
        
        self.wsProfileViewModel = wsProfileViewModel
        self.wsTalkViewModel = wsTalkViewModel
        
        removeAllSuperviewsAxceptAlhpaView()
        updateInviteMessageView(model)
        customInviteMessageView.delayTimeTextField.hidden = true
        customInviteMessageView.start()
        
        if let topVC = UIApplication.topViewController() {
            self.view.frame = topVC.view.bounds
            customInviteMessageView.center = self.view.center
            
            self.view.addSubview(customInviteMessageView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            self.didMoveToParentViewController(topVC)
        }
    }
    
    func removeController() {
        userMessageView.stop()
        customInviteMessageView.stop()
        if let wsProfileViewModel = wsProfileViewModel{
            wsProfileViewModel.cancelGameSearch()
        }
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        removeAllSuperviewsAxceptAlhpaView()
    }
    
    func updateInviteMessageView(model: AnyObject?) {
        customInviteMessageView.updateViewWithModel(model)
    }
    
    func setMessageText(text: String, fontSize: CGFloat) {
        myMutableString = NSMutableAttributedString(string: text as String, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
        customInviteMessageView.messageLabel.attributedText = myMutableString
    }
    
    func setMessageTextWithBoldRange(text: String, fontSize: CGFloat, location: Int, length: Int) {
        myMutableString = NSMutableAttributedString(string: text as String,
                                                    attributes: [NSFontAttributeName: UIFont.systemFontOfSize(fontSize)])
        myMutableString.addAttribute(NSFontAttributeName,
                                     value: UIFont.boldSystemFontOfSize(fontSize),
                                     range: NSRange(location: location, length: length))
        
        customInviteMessageView.messageLabel.attributedText = myMutableString
    }
    
    func setHeight(height: CGFloat) {
        let height: NSLayoutConstraint = NSLayoutConstraint(item: view,
                                                            attribute: NSLayoutAttribute.Height,
                                                            relatedBy: NSLayoutRelation.Equal,
                                                            toItem: nil,
                                                            attribute: NSLayoutAttribute.NotAnAttribute,
                                                            multiplier: 1,
                                                            constant: height)
        view.addConstraint(height);
    }
    
    func stopTimer() {
        userMessageView.stop()
    }
    
    func hideTimerProgress(hidden: Bool) {
        userMessageView.hideTimeProgressToAvatar(hidden)
    }
    
    func isTimerRunning() -> Bool {
        return userMessageView.timer.valid
    }
    
    func getMessageViewDelegate() -> UserInviteMessageDelegate {
        return customInviteMessageView.delegate!
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    func textFieldDidEndEditing(textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    // MARK delegate methods
    func inviteTimeIsOver() {
        removeController()
    }
    
    func gameTimeIsOver() {
        removeController()
        openUnityViewController()
    }
    
    func timeIsOver() {
        removeController()
    }
    
    func openUnityViewController() {
        startGameDelegate?.openUnityViewController()
    }
    
    func removeAllSuperviewsAxceptAlhpaView() {
        let subviews = self.view.subviews
        for subview in subviews as [UIView] {
            if subview != alphaView {
                subview.removeFromSuperview()
            }
        }
    }
}
