//
//  AppDelegate.swift
//  ULC
//
//  Created by Alex on 5/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher
import ObjectMapper
import REFrostedViewController
import Fabric
import Crashlytics
import SwiftKeychainWrapper
import RealmSwift
import ReactiveCocoa

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var topVC: ContainerViewController?
    var currentUnityController: UnityAppController!
    var unityWindow = UnityGetMainWindow()
    var shouldRotate = true
    lazy var presenter: Presenter = PresenterImpl();
    var categoryViewModel: Categoring!;
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true;
        application.statusBarHidden = true
        
        Fabric.with([Crashlytics.self]);
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: nil))
#if DEBUG
        registerSettingsBundles()
#endif
        //fetch category icons
        categoryViewModel = CategoryViewModel();
        categoryViewModel.fetchTalkCategoryIcons();
        
        currentUnityController = UnityAppController()
        let returnValue = self.currentUnityController.application(application, didFinishLaunchingWithOptions: launchOptions);
        assert(returnValue, "Unity wasn't inited");
        
        if let _view = UnityGetGLView() {
            _view.hidden = true
        }
        
        if let accessToken = KeychainWrapper.stringForKey(Constants.keyChainValue) where !accessToken.isEmpty && NSUserDefaults.standardUserDefaults().boolForKey(Constants.runAfterDelete) {
            let navigationController = ULCNavigationViewController(rootViewController: UIViewController())
            navigationController.navigationBarHidden = true
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            
            presenter.presentContainerVC()
        } else {
            
            if let viewController = R.storyboard.main.loginViewController() {
                KeychainWrapper.removeObjectForKey(Constants.keyChainValue);
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.runAfterDelete);
                NSUserDefaults.standardUserDefaults().synchronize();
                let navigationController = ULCNavigationViewController(rootViewController: viewController)
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }
        }
        UnitySendMessage("ScenesRouter", "onSceneSwitch", "10")
        return returnValue;
    }
    
    func registerSettingsBundles() {
        let appDefaults = [String: AnyObject]()
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("settings_url") {
            Constants.BASE_URL = "https://ulc.tv/"
            Constants.WS_BASE_URL = "wss://ulc.tv/ws/"
            Constants.VIDEOSTREAM_URL = "rtmp://ulc.tv/live/"
        } else {
            Constants.BASE_URL = "http://dev.ulc.tv/"
            Constants.WS_BASE_URL = "ws://dev.ulc.tv/ws/"
            Constants.VIDEOSTREAM_URL = "rtmp://dev.ulc.tv/live/"
        }
    }
    
    func showUnityWindow() {
        unityWindow.makeKeyAndVisible()
    }
    
    func hideUnityWindow() {
        unityWindow.makeKeyAndVisible()
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        Swift.debugPrint("OPEN_URL: \(url) \(url.host)")
        return true;
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let URLComponent = NSURLComponents(URL: userActivity.webpageURL!, resolvingAgainstBaseURL: true)
            
            if let fullUrl = userActivity.webpageURL, let url = URLComponent?.path {
                parseURL(url, url: fullUrl)
            }
            
            debugPrint(URLComponent?.path)
        }
        return true
    }
    
    func parseOptions(url: NSURL) -> [String: String] {
        var dict = [String: String]()
        
        if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value
            }
        }
        return dict
    }
    
    func parseURL(absoluteString: String, url: NSURL) {
        // uri looks like: <name>/<id>, for example: /event/1
        
        print("\(absoluteString) \(url)")
        
        let arrayOfURL = absoluteString.characters.split {
            $0 == "/"
            }.map(String.init)
        
        let link = detectLink(arrayOfURL)
        let key = parseOptions(url)["key"]
        
        let viewModel = UserProfileViewModel();
        
        switch link {
        case "":
            break
        case LinkType.Event.rawValue:
            handleEvent(arrayOfURL, viewModel: viewModel)
            break
        case LinkType.NewAccount.rawValue:
            handleNewAccount(key, viewModel: viewModel)
            break
        case LinkType.RestorePassword.rawValue:
            handleRestorePassword(key)
            break
        default:
            break
        }
    }
    
    func handleEvent(arrayOfURL: [String], viewModel: UserProfileViewModel) {
        if !eventPattern(arrayOfURL).isEmpty {
            let id = Int(eventPattern(arrayOfURL))
            if let eventID = id {
                viewModel.loadEventsData(eventID)
                    .takeUntil(self.rac_willDeallocSignalProducer())
                    .observeOn(UIScheduler())
                    .startWithCompleted {
                        if let event = viewModel.selfEvent.value {
                            self.presenter.openSelfSessionInfoVC(event)
                        }
                }
            }
        }
    }
    
    func handleNewAccount(key: String?, viewModel: UserProfileViewModel) {
        if let key = key {
            viewModel.openProfile(key).startWithCompleted {
                self.presenter.openContainerVC()
            }
        }
    }
    
    func handleRestorePassword(key: String?) {
        if let key = key {
            self.presenter.openRestorePasswordVC(key)
        }
    }
    
    // MARK refactor
    func detectLink(values: [String]) -> String {
        if !values.isEmpty {
            if values.first == "event" {
                return "event"
            } else if values.first == "confirm" {
                if values[1] == "new-account" {
                    return "new-account"
                } else if values[1] == "restore-password" {
                    return "restore-password"
                }
            }
        }
        return ""
    }
    
    
    func eventPattern(value: [String]) -> String {
        if !value.isEmpty && value.count == 2 {
            if let eventID = value.last {
                return eventID
            }
        }
        return ""
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        //currentUnityController.applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        //currentUnityController.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        //currentUnityController.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        currentUnityController.applicationDidBecomeActive(application)
        NSNotificationCenter.defaultCenter()
            .addObserverForName(UIApplicationDidReceiveMemoryWarningNotification,
                                object: nil,
                                queue: NSOperationQueue.mainQueue()) { (notificatopn: NSNotification) in
                                    Swift.debugPrint("+------ MEMORY WARNING ------+")
                                    KingfisherManager.sharedManager.cache.clearMemoryCache();
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        KeychainWrapper.removeObjectForKey(Constants.keyChainValue);
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.runAfterDelete);
        NSUserDefaults.standardUserDefaults().synchronize();
        currentUnityController.applicationWillTerminate(application)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        Swift.debugPrint("notification is here. Open alert window or whatever")
        // Must be called when finished
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        if application.applicationState == .Inactive {
            
            if notification.category == ULCLocalNotificationCategory.NewFollower.rawValue {
                presenter.openFollowsVC(0);
                
            } else if notification.category == ULCLocalNotificationCategory.NewMessage.rawValue,
                let partnerId = Mapper<Partner>().map(notification.userInfo)?.id {
                
                if let topVC = UIApplication.topViewController() as? REFrostedViewController {
                    topVC.hideMenuViewController()
                }
                presenter.openMessagesVC(partnerId);
            }
        }
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        
        guard let w = window, let rootVC = w.rootViewController, let presentedVC = rootVC.presentedViewController else {
            return .Portrait;
        }
        
        if let p = presentedVC as? ContainerViewController,
            let nc = p.contentViewController as? ULCNavigationViewController,
            let topVC = nc.topViewController,
            let _ = topVC as? SessionInfoViewController {
            return .All
        }
        
        if presentedVC is ContainerViewController || presentedVC is TwoPlaySpectactorViewController || presentedVC is SpectatorTalkSessionViewController {
            
            if presentedVC is StreamerSessionViewController ||
                presentedVC.presentedViewController is StreamerSessionViewController ||
                presentedVC is SpectatorTalkSessionViewController ||
                presentedVC.presentedViewController is SpectatorTalkSessionViewController ||
                presentedVC is TalkContainerViewController ||
                presentedVC.presentedViewController is TalkContainerViewController {
                
                if NSUserDefaults.standardUserDefaults().boolForKey(Constants.isPresentedVC) {
                    return .All
                } else {
                    return .Portrait
                }
            } else if presentedVC is GeneralGameViewController {
                if let controller = presentedVC as? GeneralGameViewController {
                    return checkOrientation(controller)
                }
            } else if presentedVC.presentedViewController is GeneralGameViewController {
                if let controller = presentedVC.presentedViewController as? GeneralGameViewController {
                    return checkOrientation(controller)
                }
            } else {
                return .Portrait;
            }
        }
        return .Portrait;
    }
    
    private func checkOrientation(controller: GeneralGameViewController) -> UIInterfaceOrientationMask {
        switch controller.orientation {
        case .PORTRAIT:
            return .Portrait
        case .LANDSCAPE:
            return .Landscape
        case .ALL:
            return [.LandscapeLeft, .LandscapeRight, .Portrait];
        }
    }
}

