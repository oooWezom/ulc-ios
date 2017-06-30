//
//  STLoadingGroup.swift
//  ULC
//
//  Created by Vitya on 11/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

typealias STEmptyCallback = () -> ()

protocol STLoadingable {
    var isLoading: Bool { get }
    
    func resumeLoading()
    func startLoading()
    func stopLoading(finish: STEmptyCallback?)
}

protocol STLoadingConfig {
    var animationDuration: NSTimeInterval { get }
    var lineWidth: CGFloat { get }
    var loadingTintColor: UIColor { get }
}
