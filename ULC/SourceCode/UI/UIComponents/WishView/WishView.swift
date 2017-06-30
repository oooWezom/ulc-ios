//
//  WishView.swift
//  ULC
//
//  Created by Alexey on 9/27/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class WishView:UIView {

    var descriptionLabel = UILabel()
    var finishButton = UIButton()
    var levelFontSize: CGFloat = 15.0
    var wishViewFontSize: CGFloat = 15.0
    
    init() {
        super.init(frame: CGRectZero)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func addCustomView() {
        addSubview(descriptionLabel)
        addSubview(finishButton)
        self.backgroundColor = UIColor.whiteColor()
        descriptionLabel.textColor = .blackColor()
        descriptionLabel.textAlignment = .Center
        descriptionLabel.numberOfLines = 0
        finishButton.alpha = 0.75
        finishButton.setTitle(R.string.localizable.ok(), forState: .Normal)
        finishButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Normal, cornerRadius: 2)
        finishButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        finishButton.layer.cornerRadius = 2;
        self.needsUpdateConstraints()
    }
    
    func updateFontSize(orientation: UIInterfaceOrientation) {
        if orientation.isPortrait {
            levelFontSize     = 11.0
            wishViewFontSize  = 9.0
        } else {
            levelFontSize     = 15.0
            wishViewFontSize  = 15.0
        }
        
        descriptionLabel.adjustsFontSizeToFitWidth = true
        finishButton.titleLabel?.font = UIFont.systemFontOfSize(levelFontSize)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        let buttonHeight = orientation.isLandscape ? 25 : 20
        let buttonWidth = orientation.isLandscape ? 70 : 50
        
        descriptionLabel.snp_remakeConstraints{
            (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(self).multipliedBy(0.6)
            make.centerX.equalToSuperview()
        }
        
        finishButton.snp_remakeConstraints{
            (make) in
            make.top.equalTo(descriptionLabel.snp_bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(buttonHeight)
            make.width.equalTo(buttonWidth)
        }
    }
    
    func damageConstraints(){

        descriptionLabel.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }
        
        finishButton.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }
    }
}
