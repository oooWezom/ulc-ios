//
//  ULCNavigationViewController.swift
//  ULC
//
//  Created by Alex on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class ULCNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognized(_:))));
    }
    
    func panGestureRecognized(sender: UIPanGestureRecognizer) {
        
        self.view.endEditing(true);
        
        if self.frostedViewController != nil {
            self.frostedViewController.view.endEditing(true);
            self.frostedViewController.panGestureRecognized(sender);
        }
    }
}

