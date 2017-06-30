//
//  STZhiHuLoading.swift
//  ULC
//
//  Created by Vitya on 11/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Foundation

class STZhiHuLoading: UIView {
    
    private let cycleLayer: CAShapeLayer = CAShapeLayer()
    
    internal var isLoading: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateUI()
    }
}

extension STZhiHuLoading {
    internal func setupUI() {
        cycleLayer.lineCap = kCALineCapRound
        cycleLayer.lineJoin = kCALineJoinRound
        cycleLayer.lineWidth = lineWidth
        cycleLayer.fillColor = UIColor.clearColor().CGColor
        cycleLayer.strokeColor = loadingTintColor.CGColor
        cycleLayer.strokeEnd = 0
        layer.addSublayer(cycleLayer)
    }
    
    internal func updateUI() {
        cycleLayer.frame = bounds
        cycleLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
}

extension STZhiHuLoading: STLoadingConfig {
    var animationDuration: NSTimeInterval {
        return 2
    }
    
    var lineWidth: CGFloat {
        return 3
    }
    
    var loadingTintColor: UIColor {
        return .orangeColor()
    }
}

extension STZhiHuLoading: STLoadingable {
    internal func startLoading() {
        guard !isLoading else {
            return
        }
        isLoading = true
        self.alpha = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -1
        strokeStartAnimation.toValue = 1.0
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        cycleLayer.addAnimation(animationGroup, forKey: "animationGroup")
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = M_PI * 2
        rotateAnimation.repeatCount = Float.infinity
        rotateAnimation.duration = animationDuration * 4
        cycleLayer.addAnimation(rotateAnimation, forKey: "rotateAnimation")
    }
    
    internal func resumeLoading() {
        stopLoading()
        startLoading()
    }
    
    internal func stopLoading(finish: STEmptyCallback? = nil) {
        guard isLoading else {
            return
        }
        
        UIView.animateWithDuration(0.2, animations: { [weak self] _ in
            self?.alpha = 0
            }, completion: { _ in
                //self?.cycleLayer.removeAllAnimations()
                finish?()
        })
        self.cycleLayer.removeAllAnimations()
        self.isLoading = false
    }
}
