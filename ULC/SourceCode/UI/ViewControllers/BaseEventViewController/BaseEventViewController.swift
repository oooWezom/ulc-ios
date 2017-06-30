//
//  BaseEventViewController.swift
//  ULC
//
//  Created by Alex on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol ViewsConfigurable {
    
    func configureViews();
    func configureTableView();
}
//FIX IT
class NotificationTapGestureRecognizer: UITapGestureRecognizer {
    var gameEntity: WSNotifyGameEntity?
    var talkEntity: WSNotifyTalkEntity?
}

class BaseEventViewController: UITableViewController, ViewsConfigurable {
    
    var userProfileID: Int!;
    
    let wsProfileViewModel = WSProfileViewModel();
    
    let ulcButton = ULCButton.instanciateFromNib();
    let customAlertMessageController = CustomMessageAlertController()
    
    //Mark - Private properties
    private let notificationView = NotificationVeiw.instanciateFromNib();
    private let window = UIApplication.sharedApplication().keyWindow
    private var tapOnNotificationRecognizer = NotificationTapGestureRecognizer()
    
    private let presenter = PresenterImpl()
    
    lazy var pagingSpinner: UIActivityIndicatorView = { [unowned self] in
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
        spinner.color = UIColor(named: .LoginButtonNormal);
        spinner.hidesWhenStopped = true
        return spinner
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        customAlertMessageController.blockCloseOnTap = true
        
        configureViews();
        configureTableView();
        attachWSSignals()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.Plain, target:nil, action:nil)
        
        ulcButton.playULCButton.addTarget(self, action: #selector(open2Play), forControlEvents: .TouchUpInside)
        ulcButton.talkULCButton.addTarget(self, action: #selector(open2Talk), forControlEvents: .TouchUpInside)
        
        tapOnNotificationRecognizer = NotificationTapGestureRecognizer(target: self, action: #selector(tapOnNotification))
        notificationView.addGestureRecognizer(tapOnNotificationRecognizer)
    }
    
    func open2Play() {
        if let vc = R.storyboard.main.twoPlayViewController() {
            ulcButton.hidden = true
            ulcButton.playULCButton.enabled = false
            ulcButton.talkULCButton.enabled = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func open2Talk() {
        if let vc = R.storyboard.main.twoTalkViewController() {
            ulcButton.removeFromSuperview();
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func ubdateULCButtonConstraints() {
        
        if let _ = ulcButton.superview {
            ulcButton.snp_remakeConstraints(closure: { (make) in
                make.width.height.equalTo(92);
                make.bottom.right.equalTo(0);
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.translucent = false;
        self.navigationController?.hidesBarsOnSwipe = true
        
        if let navigationView = navigationController?.view where !ulcButton.isDescendantOfView(navigationView) {
            navigationView.addSubview(ulcButton);
            ulcButton.setStartPosition();
            ulcButton.hidden = false;
            ubdateULCButtonConstraints()
        }
        wsProfileViewModel.resume();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        ulcButton.hidden = true;
        ulcButton.closeULCButton { [weak self] in
            if let strongSelf = self {
                if let _ = strongSelf.ulcButton.superview {
                    strongSelf.ulcButton.removeFromSuperview();
                }
            }
        }
        wsProfileViewModel.pause();
        customAlertMessageController.blockCloseOnTap = false
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        
        if let _ = notificationView.superview {
            notificationView.snp_remakeConstraints(closure: { (make) in
                make.width.equalTo(self.view.width)
                make.height.equalTo(notificationView.height)
                make.top.left.equalTo(0);
            })
        }
    }
    
    func configureViews() {}
    
    func tapOnNotification(sender: NotificationTapGestureRecognizer) {
        notificationView.closeNotificationView()
        if let gameNotification = sender.gameEntity {
            let gameEntity = GameSessionsEntity.create(gameNotification.game)
            //presenter.openSpectatorGameSessionVC(gameEntity, viewControllerType: .Normal);
            presenter.openSpectatorViewController(gameEntity, viewControllerType: .Normal)
        } else if let talkNotification = sender.talkEntity {
            let talkEntity = TalkSessionsResponseEntity.createTalkSessionsResponseEntity(talkNotification)
            presenter.openSpectatorTalkSessionVC(talkEntity, viewControllerType: .Normal);
        }
    }
    
    func configureTableView() {
        tableView.showsVerticalScrollIndicator = false;
        tableView.showsHorizontalScrollIndicator = false;
        tableView.separatorStyle = .None;
    }
    
    func attachWSSignals() {
        
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
                    self.presenter.openTalkContainerVC(message.id, message: message)
                }
        }
      
      wsProfileViewModel.notifyGameStartedHandler.signal
        .observeOn(UIScheduler())
        .observeResult { [unowned self] observer in
          if observer.value?.game?.players.first?.id == self.wsProfileViewModel.currentId || observer.value?.game?.players.last?.id == self.wsProfileViewModel.currentId{
            return;
          }
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
            .observeResult { [unowned self] observer in
                
                if let notification = observer.value, let window = self.window where !self.notificationView.isTimerStarting() {
                    self.notificationView.updateViewWithModel(notification, sessionType: .TalkSession)
                    self.notificationView.width = window.width
                    window.windowLevel = UIWindowLevelAlert
                    window.addSubview(self.notificationView)
                    
                    self.tapOnNotificationRecognizer.gameEntity = nil
                    self.tapOnNotificationRecognizer.talkEntity = notification
                }
        }
    }
    
    func addRefreshControll() {
        refreshControl = UIRefreshControl()
        if let refreshControl = refreshControl {
            tableView.addSubview(refreshControl)
            refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        }
    }
    
    func refresh() {}
    
    deinit {
        notificationView.closeNotificationView()
        if let _ = ulcButton.superview {
            ulcButton.removeFromSuperview();
        }
    }
}

extension UIViewController {
    
    final func addMenuButton() {
        if let menuImage = R.image.menu_main_icon() {
            self.addLeftBarButtonWithImage(menuImage)
        }
    }
    
    final func addBackButton() {
        let leftBarButtonItem = UIBarButtonItem(image: R.image.back_button_icon(), style: .Plain, target: self, action: #selector(popViewController));
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    
    func popViewController() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    final func removeBackButton() {
        self.navigationItem.leftBarButtonItem = nil;
    }
}
