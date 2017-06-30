//
//  UIViewController+KeyboardWillChangeFrame.swift
//  ULC
//
//  Created by Alexey on 10/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension UIViewController {
    func keyboardWillChangeFrameNotification(notification: NSNotification, scrollBottomConstant: NSLayoutConstraint) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let keyboardBeginFrame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardEndFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let isBeginOrEnd = keyboardBeginFrame.origin.y == screenHeight || keyboardEndFrame.origin.y == screenHeight
        let heightOffset = keyboardBeginFrame.origin.y - keyboardEndFrame.origin.y - (isBeginOrEnd ? bottomLayoutGuide.length : 0)
        
        UIView.animateWithDuration(duration.doubleValue,
                                   delay: 0,
                                   options: UIViewAnimationOptions(rawValue: UInt(curve.integerValue << 16)),
                                   animations: { () in
                                    scrollBottomConstant.constant = scrollBottomConstant.constant + heightOffset
                                    self.view.layoutIfNeeded()
            },
                                   completion: nil
        )
    }
}
