//
//  UIApplicationExtensions.swift
//  ULC
//
//  Created by Alex on 6/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        
        return base
    }
    
    class func topNavigationViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        guard let navigation = base as? ULCNavigationViewController else {
            return nil
        }
        return navigation
    }
    
    class func containerViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        guard let navigation = base as? ULCNavigationViewController else {
            return nil
        }
        if let vc = navigation.visibleViewController as? ContainerViewController {
            return vc;
        }
        return nil;
    }
}
