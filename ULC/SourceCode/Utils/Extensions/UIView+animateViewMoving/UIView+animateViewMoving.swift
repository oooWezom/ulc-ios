//
//  UIView+animateViewMoving.swift
//  ULC
//
//  Created by Vitya on 9/3/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:NSTimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.frame = CGRectOffset(self.frame, 0,  movement)
        UIView.commitAnimations()
    }
}

extension UIView {
    func animateConstraintWithDuration(duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, options: UIViewAnimationOptions, completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration, delay:delay, options:options, animations: { [weak self] in
            self?.layoutIfNeeded() ?? ()
            }, completion: completion)
    }
}
