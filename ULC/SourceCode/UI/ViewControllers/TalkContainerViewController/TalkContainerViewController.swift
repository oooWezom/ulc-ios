//
//  TalkContainerViewController.swift
//  ULC
//
//  Created by Vitya on 9/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import REFrostedViewController

class TalkContainerViewController: REFrostedViewController {
    
    var wsTalkSessionInfo = TalkSessionsResponseEntity()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        direction = REFrostedViewControllerDirection.Right
     
        // Add content UIViewController
        if let controller = R.storyboard.main.streamerSessionViewController() {
            let navigationController = ULCNavigationViewController(rootViewController: controller)
            self.contentViewController = navigationController
        }
        
        // Add right menu
        if let controller = R.storyboard.main.talkMenuViewController() {
            self.menuViewController = controller
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wsTalkViewModel = WSTalkViewModel(sessionId: wsTalkSessionInfo.id)
        
        // set value into content UIViewController
        if let navigationController = contentViewController as? ULCNavigationViewController,
            let contentController = navigationController.topViewController as? StreamerSessionViewController {
            
            contentController.wsTalkViewModel = wsTalkViewModel
            contentController.wsSessionInfo = wsTalkSessionInfo
        }
        
        // set value into content right menu
        if let menuController = menuViewController as? TalkMenuViewController {
            menuController.wsTalkViewModel = wsTalkViewModel
            menuController.wsTalkSessionInfo = wsTalkSessionInfo
        }
    }
}
