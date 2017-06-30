//
//  UIViewController+Menu.swift
//  ULC
//
//  Created by Alex on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import REFrostedViewController

extension UIViewController {
    
    public func addLeftBarButtonWithImage(buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.showMenu))
        navigationItem.leftBarButtonItem = leftButton;
    }
    
    func showMenu() {
        if self.frostedViewController != nil {
            // Dismiss keyboard (optional)
            self.view.endEditing(true);
            self.frostedViewController.view.endEditing(true);
            
            // Present the view controller
            self.frostedViewController.presentMenuViewController();
        }
    }
    
    func closeMenu() {
        if self.frostedViewController != nil {
            self.frostedViewController.hideMenuViewController();
        }
    }
}
