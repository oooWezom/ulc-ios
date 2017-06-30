//
//  UIViewController+HideKeyboard.swift
//  ULC
//
//  Created by Vitya on 6/14/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension GeneralGameViewController {
    func hideKeyboardAndInterfaceWhenTappedAround() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeInterface))
        view.addGestureRecognizer(tap)
    }
    
    func changeInterface() {
        leftPlayerInfoView.hidden = leftPlayerInfoView.hidden ? false : true
        rightPlayerInfoView.hidden = rightPlayerInfoView.hidden ? false : true
        bottomView.hidden = bottomView.hidden ? false : true
        view.endEditing(true)
    }
}

extension UIView {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.endEditing(true)
    }
}
