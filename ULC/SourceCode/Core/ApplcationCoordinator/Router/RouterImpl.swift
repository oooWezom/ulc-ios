//
//  RouterImpl.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import REFrostedViewController

final class RouterImpl: Router {
    
    private(set) weak var rootController: ULCNavigationViewController?
    
    init(rootController: ULCNavigationViewController) {
        self.rootController = rootController
    }
    
    func present(controller: UIViewController?) {
        present(controller, animated: true)
    }
    
    func present(controller: UIViewController?, animated: Bool) {
        guard let controller = controller else { return }
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.presentViewController(controller, animated: animated, completion: nil)
        }
    }
    
    func present(controller: UIViewController?, animated: Bool, completition: RouterHandler) {
        guard let controller = controller else { return }
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.presentViewController(controller, animated: animated, completion: completition);
        }
    }
    
    func push(controller: UIViewController?)  {
        push(controller, animated: true)
    }
    
    func push(controller: UIViewController?, animated: Bool)  {
        guard let controller = controller else { return }
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.pushViewController(controller, animated: true);
        }
    }
    
    func popController()  {
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.popViewControllerAnimated(false)
        }
    }
    
    func popController(animated: Bool )  {
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.popViewControllerAnimated(animated)
        }
    }
    
    func dismissController() {
        dismissController(true)
    }
    
    func dismissController(animated: Bool) {
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.dismissViewControllerAnimated(animated, completion: nil)
        }
    }
    
    func dismissController(animated: Bool, completition: RouterHandler) {
        dispatch_after(0, dispatch_get_main_queue()) { [weak self] in
            self?.navigationRootViewController()?.dismissViewControllerAnimated(animated, completion: completition)
        }
    }
    
    func openOnMenu(controller: UIViewController?) {
        dispatch_after(0, dispatch_get_main_queue()) {
            if let vc = controller, let containerViewController = UIApplication.topViewController() as? REFrostedViewController {
                let navigationController = ULCNavigationViewController(rootViewController: vc);
                containerViewController.contentViewController = navigationController;
                containerViewController.hideMenuViewController();
            }
        }
    }
    
    private func navigationRootViewController() -> UINavigationController? {
        
        guard let containerViewController = UIApplication.topViewController() as? REFrostedViewController else {
            return self.rootController;
        }
        
        if let navigationController = containerViewController.contentViewController as? ULCNavigationViewController {
            return navigationController;
        }
        
        return nil;
    }
    
    func changeRootViewController(controller: UIViewController) {
        if let containerVC = UIApplication.topViewController() {
            
            containerVC.dismissViewControllerAnimated(false, completion: { [weak self] _ in
                guard let strongSelf = self, let nav = strongSelf.rootController else {
                    return;
                }
                if let loginVC = R.storyboard.main.loginViewController() {
                    nav.setViewControllers([loginVC], animated: true);
                }
            })
        }
    }
    
    func openAlertViewController(alertViewController: UIAlertController) {
        if let containerViewController = UIApplication.topViewController() as? REFrostedViewController {
            containerViewController.presentViewController(alertViewController, animated: true, completion:nil)
        }
    }
}
