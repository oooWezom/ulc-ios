//
//  Timer+Actor.swift
//  ULC
//
//  Created by Alex on 9/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

private class TimerActor {
    
    let fireBlock: (() -> Void)
    
    init(_ block: () -> Void) {
        fireBlock = block
    }
    
    @objc func fire() {
        fireBlock()
    }
}

extension NSTimer {
    
    public class func new(interval: NSTimeInterval, block: (() -> Void)) -> NSTimer {
        let timerActor = TimerActor(block)
        return self.init(timeInterval: interval, target: timerActor, selector: #selector(fire), userInfo: nil, repeats: false)
    }
    
    public static func after(interval: NSTimeInterval, block: (() -> Void)) -> NSTimer {
        let timer = NSTimer.new(interval, block: block)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        return timer
    }
}

