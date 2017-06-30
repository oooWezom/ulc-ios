//
//  WSBaseViewController.swift
//  ULC
//
//  Created by Vitya on 10/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MBProgressHUD

class WSBaseViewController: UIViewController {
    
    let wsProfileViewModel = WSProfileViewModel()
    
    var isOpenedTalkContainerVC = false
    
    //Mark - Private properties
    private let presenter                    = PresenterImpl()
    private let notificationView             = NotificationVeiw.instanciateFromNib();
    private let customAlertMessageController = CustomMessageAlertController()
    private var tapOnNotificationRecognizer  = NotificationTapGestureRecognizer()
    private let window = UIApplication.sharedApplication().keyWindow
    
    var viewTypeController:ViewTypeController = .Normal
    let userProfileViewModel = UserProfileViewModel();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachWSSignals()
        
        tapOnNotificationRecognizer = NotificationTapGestureRecognizer(target: self, action: #selector(tapOnNotification))
        notificationView.addGestureRecognizer(tapOnNotificationRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        wsProfileViewModel.resume();
        isOpenedTalkContainerVC = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        wsProfileViewModel.pause();
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    private func attachWSSignals() {
        
        // MARK:- WS signals
        wsProfileViewModel.inviteToTalkRequestHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                
                if let message = observer.value {
                    self.customAlertMessageController.showUserInviteAlertMessage(message, wsProfileViewModel: self.wsProfileViewModel, wsTalkViewModel: nil)
                }
        }
        
        wsProfileViewModel.createTalkResultHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                
                if let message = observer.value?.talk {
                    self.customAlertMessageController.removeController()
                    
                    if !self.isOpenedTalkContainerVC {
                        self.presenter.openTalkContainerVC(message.id, message: message)
                        self.isOpenedTalkContainerVC = true
                    }
                }
        }
        
        wsProfileViewModel.notifyGameStartedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                if let notification = observer.value, let window = self.window where !self.notificationView.isTimerStarting() {
                    self.notificationView.updateViewWithModel(notification, sessionType: .GameSession)
                    self.notificationView.width = window.width
                    window.windowLevel = UIWindowLevelAlert
                    window.addSubview(self.notificationView)
                    
                    self.tapOnNotificationRecognizer.gameEntity = notification
                    self.tapOnNotificationRecognizer.talkEntity = nil
                }
        }
        
        wsProfileViewModel.notifyTalkStartedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if let notification = observer.value, let strongSelf = self, let window = strongSelf.window where !strongSelf.notificationView.isTimerStarting() {
                    strongSelf.notificationView.updateViewWithModel(notification, sessionType: .TalkSession)
                    strongSelf.notificationView.width = window.width
                    window.windowLevel = UIWindowLevelAlert
                    window.addSubview(strongSelf.notificationView)
                    
                    strongSelf.tapOnNotificationRecognizer.gameEntity = nil
                    strongSelf.tapOnNotificationRecognizer.talkEntity = notification
                }
        }
    }
    
    func tapOnNotification(sender: NotificationTapGestureRecognizer) {
        if let gameNotification = sender.gameEntity {
            let gameEntity = GameSessionsEntity.create(gameNotification.game)
            //presenter.openSpectatorGameSessionVC(gameEntity, viewControllerType: .Normal)
            presenter.openSpectatorViewController(gameEntity, viewControllerType: .Normal)
        } else if let talkNotification = sender.talkEntity {
            let talkEntity = TalkSessionsResponseEntity.createTalkSessionsResponseEntity(talkNotification)
            presenter.openSpectatorTalkSessionVC(talkEntity, viewControllerType: .Normal);
        }
    }
}
