//
//  UIView+SpringAnimation.swift
//  ULC
//
//  Created by Alex on 9/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

public func spring(duration: NSTimeInterval, delay: NSTimeInterval, damping: CGFloat, velocity: CGFloat, animations: () -> Void) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [UIViewAnimationOptions.CurveEaseOut], animations: {
        animations()
        }, completion: nil)
}

public func animate(duration: NSTimeInterval, delay: NSTimeInterval, animations: () -> Void, completion: () -> Void) {
    
    UIView.animateWithDuration(duration, delay: delay, options: [], animations: {
        animations()
        }, completion: { finished in
            completion()
    })
}

public func animate(duration: NSTimeInterval, delay: NSTimeInterval, animations: () -> Void) {
    
    UIView.animateWithDuration(duration, delay: delay, options: [], animations: {
        animations()
        }, completion: { finished in
    })
}

