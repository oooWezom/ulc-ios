//
//  NSTimeInterval + Extention.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/28/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

extension NSTimeInterval {

	var minuteSecondMS: String {
		return String(format:"%0.2d:%0.2d:%0.2d",hour, minute, second)
	}
    
    var hourMinuteSecondMS: String {
        return String(format:"%d:%02d:%02d", hour, minute, second)
    }

	var hour: Int {
		return Int(self / 3600.0 % 60)
	}

	var minute: Int {
		return Int(self / 60.0 % 60)
	}
	var second: Int {
		return Int(self % 60)
	}
	var millisecond: Int {
		return Int(self * 1000 % 1000 )
	}
}

extension Int {
	var msToSeconds: Double {
		return Double(self) / 1000
	}
}

extension Double {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}