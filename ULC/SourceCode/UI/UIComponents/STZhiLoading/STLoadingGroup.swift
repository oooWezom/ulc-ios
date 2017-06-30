//
//  STLoadingGroup.swift
//  ULC
//
//  Created by Vitya on 11/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

enum STLoadingStyle: String {
    case submit = "submit"
    case glasses = "glasses"
    case walk = "walk"
    case arch = "arch"
    case bouncyPreloader = "bouncyPreloader"
    case zhihu = "zhihu"
}

class STLoadingGroup {
    private var loadingView: STLoadingable
    private var finish: STEmptyCallback?
    
    init(side: CGFloat, style: STLoadingStyle) {
        
        let bounds = CGRect(origin: .zero, size: CGSize(width: side, height: side))
        switch style {
        case .zhihu:
            loadingView = STZhiHuLoading(frame: bounds)
        default:
            loadingView = STZhiHuLoading(frame: bounds)
        }
    }
}

extension STLoadingGroup {
    var isLoading: Bool {
        return loadingView.isLoading
    }
    
    func startLoading() {
        loadingView.startLoading()
    }
    
    func resumeLoading() {
        stopLoading()
        startLoading()
    }
    
    func stopLoading(finish: STEmptyCallback? = nil) {
        self.finish = finish
        loadingView.stopLoading(finish)
    }
}

extension STLoadingGroup {
    func show(inView: UIView?, offset: CGPoint = .zero, autoHide: NSTimeInterval = 0) {
        guard let loadingView = loadingView as? UIView else {
            return
        }
        if loadingView.superview != nil {
            loadingView.removeFromSuperview()
        }
        var showInView = UIApplication.sharedApplication().keyWindow ?? UIView()
        if let inView = inView {
            showInView = inView
        }
        let showInViewSize = showInView.frame.size
        loadingView.center = CGPoint(x: showInViewSize.width * 0.5, y: showInViewSize.height * 0.5)
        showInView.addSubview(loadingView)
    }
    
    func remove() {
        guard let loadingView = loadingView as? UIView else {
            return
        }
        if loadingView.superview != nil {
            stopLoading() {
                loadingView.removeFromSuperview()
            }
        }
    }
}
