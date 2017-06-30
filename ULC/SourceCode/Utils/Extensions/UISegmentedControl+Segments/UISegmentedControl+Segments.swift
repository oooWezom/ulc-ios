//
//  UISegmentedControl+Segments.swift
//  ULC
//
//  Created by Alex on 2/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

extension UISegmentedControl {
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegmentWithTitle(segment, atIndex: self.numberOfSegments, animated: false)
        }
    }
}