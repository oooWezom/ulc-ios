//
//  ContainerViewController.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import REFrostedViewController
import ReactiveCocoa
import ReachabilitySwift

class ContainerViewController: REFrostedViewController {
    
    let wsProfileViewModel: WSProfiling = WSProfileViewModel();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let controller = R.storyboard.main.currentUserProfileViewController() {
            controller.userProfileID = 0;
            let navigationController = ULCNavigationViewController(rootViewController: controller)
            self.contentViewController = navigationController
            
            if let menuImage = R.image.menu_main_icon() {
                controller.addLeftBarButtonWithImage(menuImage)
            }
        }
        // Add left menu
        if let controller = R.storyboard.main.menuViewController() {
            self.menuViewController = controller
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        configureWS();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        wsProfileViewModel.resume();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        wsProfileViewModel.pause();
    }
    
    func configureWS() {
        
        let newFollowerSignal = wsProfileViewModel.followerHandler.0;
        
        newFollowerSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.localNotificationKey) {
                    return;
                }
                
                guard let newFollower = observer.value?.user, let strongSelf = self else {
                    return
                }
                
                if (strongSelf.isViewLoaded() && strongSelf.view.window != nil) {
                    let localNotification = UILocalNotification()
                    localNotification.alertBody = "\(R.string.localizable.new_follower()) \(newFollower.name)" //#MARK localized
                    localNotification.category = ULCLocalNotificationCategory.NewFollower.rawValue
                    localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    localNotification.timeZone = NSTimeZone.defaultTimeZone()
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
        }
        
        let newInstantMessageSignal = wsProfileViewModel.newInstantMessageHadler.0;
        
        newInstantMessageSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.localNotificationKey) {
                    return;
                }
                
                guard let newMessage = observer.value?.message,
                    let sender = newMessage.sender,
                    let strongSelf = self else {
                        return
                }
                
                if (strongSelf.isViewLoaded() && strongSelf.view.window != nil) {
                    let localNotification = UILocalNotification()
                    localNotification.alertBody = "\(sender.name): \(newMessage.text)"
                    localNotification.userInfo = sender.toJSON() as [NSObject: AnyObject]
                    localNotification.category = ULCLocalNotificationCategory.NewMessage.rawValue
                    localNotification.timeZone = NSTimeZone.defaultTimeZone();
                    localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
        }
        
        let reachabilitySignal = wsProfileViewModel.reachibilityHandler.0;
        
        reachabilitySignal.observeResult { observer in
            guard let value = observer.value else {
                return;
            }
            
            switch value {
                
            case Reachability.NetworkStatus.ReachableViaWiFi.description:
                Swift.debugPrint(value)
                break;
                
            case Reachability.NetworkStatus.ReachableViaWWAN.description:
                Swift.debugPrint(value)
                break;
                
            case Reachability.NetworkStatus.NotReachable.description:
                Swift.debugPrint(value)
                break;
                
            default:
                break;
            }
        }
        
        wsProfileViewModel.getCurrentApiVersion()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] signal, _ in
                signal.observeResult{ result in
                    guard let value = result.value else {
                        return;
                    }
                    switch value {
                    case .OLD_VERSION:
                        self?.showUpdateAlert();
                        break;
                    default:
                        break;
                    }
                }
        }
    }
    
    deinit{
        print("DEINIT CONTAINER VC")
    }
}
