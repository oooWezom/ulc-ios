//
//  PlayerInfoView.swift
//  ULC
//
//  Created by Alexey on 10/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

enum Position {
    case Left
    case Right
}

public class PlayerInfoView: UIView {
    
    var gradientView = GradientView()
    var circleAvatarView = UIImageView()
    var separatorView = UIView()
    var usernameLabel = UILabel()
    var levelLabel = UILabel()
    var cameraSwitchButton = UIButton()
    var firstLevelIndicatorImageView = UIImageView()
    var secondLevelIndicatorImageView = UIImageView()
    var thirdLevelIndicatorImageView = UIImageView()
    var placeholderView = UIView()
    var followView = UIView()
    var reportView = UIView()
    var followImageView = UIImageView()
    var reportImageView = UIImageView()
    var followLabel = UILabel()
    var reportLabel = UILabel()
    var optionButton = UIButton()
    var followButton = UIButton()
    var reportButton = UIButton()
    var position:Position = .Left
    
    // MARK font properties
    var usernameFontSize: CGFloat = 17.0
    var levelFontSize: CGFloat = 15.0
    var optionsFontSize: CGFloat = 16.0
    
    init(position:Position) {
        super.init(frame: CGRectZero)
        self.position = position
        configureViews()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func reinit(position:Position) {
        self.position = position
        configureViews()
    }
    
    func configureViews() {
        self.addSubview(gradientView)
        self.addSubview(circleAvatarView)
        self.addSubview(separatorView)
        self.addSubview(usernameLabel)
        self.addSubview(levelLabel)
        self.addSubview(firstLevelIndicatorImageView)
        self.addSubview(secondLevelIndicatorImageView)
        self.addSubview(thirdLevelIndicatorImageView)
        self.addSubview(placeholderView)
        
        placeholderView.addSubview(cameraSwitchButton)
        placeholderView.addSubview(followView)
        placeholderView.addSubview(reportView)
        followView.addSubview(followImageView)
        reportView.addSubview(reportImageView)
        followView.addSubview(followLabel)
        reportView.addSubview(reportLabel)
        
        self.addSubview(optionButton)
        self.followView.addSubview(followButton)
        self.reportView.addSubview(reportButton)
        
        cameraSwitchButton.hidden = true
        
        if let switchCameraImage = R.image.switch_camera() {
            cameraSwitchButton.setImage(switchCameraImage, forState: .Normal)
        }
        
        if let follow = R.image.follow_user_icon() {
            followImageView.image = follow
        }
        
        if let report = R.image.report_user_icon() {
            reportImageView.image = report
        }
        
        followLabel.text = R.string.localizable.follow()
        reportLabel.text = R.string.localizable.report()
        followLabel.textColor = UIColor.whiteColor()
        reportLabel.textColor = UIColor.whiteColor()
        gradientView.initBlackGradient([1.0, 0.0])
        
        if position == .Right {
            usernameLabel.textAlignment = .Right
            levelLabel.textAlignment = .Right
            followLabel.textAlignment = .Right
            reportLabel.textAlignment = .Right
        } else {
            usernameLabel.textAlignment = .Left
            levelLabel.textAlignment = .Left
            followLabel.textAlignment = .Left
            reportLabel.textAlignment = .Left
        }
        
        placeholderView.hidden = true
        usernameLabel.textColor = .whiteColor()
        levelLabel.textColor = .whiteColor()
        usernameLabel.font = UIFont(name: usernameLabel.font.fontName, size: 15)
        levelLabel.font = UIFont(name: usernameLabel.font.fontName, size: 15)
        self.needsUpdateConstraints()
    }
    
    func resizeWinnerFont(winner:Winner) {
        if winner == .first{
            usernameLabel.font = UIFont(name: usernameLabel.font.fontName, size: 10)
            levelLabel.font = UIFont(name: usernameLabel.font.fontName, size: 10)
        } else {
            
        }
    }
    
    func showCameraSwitchButton() {
        followView.hidden = true
        reportView.hidden = true
        self.placeholderView.bringSubviewToFront(cameraSwitchButton)
        cameraSwitchButton.hidden = false
    }
    
    func hideIndicators(hidden:Bool) {
        firstLevelIndicatorImageView.hidden  = hidden
        secondLevelIndicatorImageView.hidden = hidden
        thirdLevelIndicatorImageView.hidden  = hidden
    }
    
    func updateIndicators(ids: [Int]) {
        let roundImage = UIImage(color: .grayColor(), size: CGSize(width: 20.0, height: 20.0))?.alpha(0.7);
        let count = ids.count
        
        if count == 1 {
            firstLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor()); }
        if count == 2 {
            secondLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor()); }
        if count == 3 {
            thirdLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor()); }
    }
    
    func updateIndicatorsFromState(winsCount:Int) {
        let roundImage = UIImage(color: .grayColor(), size: CGSize(width: 20.0, height: 20.0))?.alpha(0.7);
        
        if winsCount == 1 {
            firstLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor()); }
        if winsCount == 2 {
            firstLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
            secondLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
        }
        if winsCount == 3 {
            firstLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
            secondLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
            thirdLevelIndicatorImageView.image = roundImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
        }
    }
    
    func updateWithModel(model:AnyObject?) {
        guard let model = model as? WSPlayerEntity else{return}
        
        let url = NSURL(string: Constants.userContentUrl + model.avatar)
        
        if model.avatar == "" {
            if let image = R.image.mini_avatar_icon(){
                self.circleAvatarView.image = image
            }
        }else {
            if let url = url {
                KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil, completionHandler: {
                    (image, error, cacheType, imageURL) -> () in
                    if let image = image{
                        self.circleAvatarView.image = image.resize(200).circle(10, borderColor: UIColor.whiteColor())
                    }
                })
            }
        }
        
        let roundedImage = UIImage(color: UIColor.clearColor(), size: CGSize(width: 20.0, height: 20.0))?.alpha(0.9)
        
        firstLevelIndicatorImageView.image = roundedImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
        secondLevelIndicatorImageView.image = roundedImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
        thirdLevelIndicatorImageView.image = roundedImage?.resize(50).circle(5, borderColor: UIColor.whiteColor());
        usernameLabel.text = model.name;
        levelLabel.text = "\(model.level) level";
    }
    
    func updateFontSize(orientation: UIInterfaceOrientation, reverse:Bool) {
        
        if orientation.isPortrait {
            usernameFontSize = 13.0
            levelFontSize = 11.0
            optionsFontSize = 12.0
        } else {
            usernameFontSize = 17.0
            levelFontSize = 15.0
            optionsFontSize = 16.0
        }
        
        followLabel.font = UIFont.systemFontOfSize(optionsFontSize)
        reportLabel.font = UIFont.systemFontOfSize(optionsFontSize)
        usernameLabel.font = UIFont.systemFontOfSize(usernameFontSize)
        levelLabel.font = UIFont.systemFontOfSize(levelFontSize)
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        
        gradientView.snp_makeConstraints{(make) -> Void in
            make.top.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(60)
        }
        
        placeholderView.snp_remakeConstraints{
            (make) -> Void in
            make.top.equalTo(circleAvatarView.snp_bottom).offset(10)
            make.bottom.left.right.equalTo(self)
            
        }
        
        followButton.snp_remakeConstraints{
            (make) -> Void in
            make.top.left.right.bottom.equalTo(followView)
        }
        
        reportButton.snp_remakeConstraints{
            (make) -> Void in
            make.top.left.right.bottom.equalTo(reportView)
        }
        
        if position == .Right {
            
            circleAvatarView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(self).offset(-10)
                make.height.equalTo(self.snp_height).multipliedBy(0.2)
                make.width.equalTo(self.snp_height).multipliedBy(0.2)
                make.top.equalTo(self).offset(10)
            }
            
            thirdLevelIndicatorImageView.snp_remakeConstraints{
                (make) -> Void in
                make.left.equalTo(self).offset(10)
                make.height.equalTo(self.snp_height).multipliedBy(0.06)
                make.width.equalTo(self.snp_height).multipliedBy(0.06)
                make.bottom.equalTo(separatorView.snp_top)
            }
            
            secondLevelIndicatorImageView.snp_remakeConstraints{
                (make) -> Void in
                make.left.equalTo(thirdLevelIndicatorImageView.snp_right).offset(5)
                make.height.width.equalTo(thirdLevelIndicatorImageView)
                make.centerY.equalTo(thirdLevelIndicatorImageView)
            }
            
            firstLevelIndicatorImageView.snp_remakeConstraints{
                (make) -> Void in
                make.left.equalTo(secondLevelIndicatorImageView.snp_right).offset(5)
                make.height.width.equalTo(thirdLevelIndicatorImageView)
                make.centerY.equalTo(thirdLevelIndicatorImageView)
            }
            
            separatorView.snp_remakeConstraints{
                (make) -> Void in
                make.left.equalTo(self)
                make.right.equalTo(circleAvatarView.snp_left).offset(-10)
                make.height.equalTo(1)
                make.centerY.equalTo(circleAvatarView)
            }
            
            usernameLabel.snp_remakeConstraints{
                (make) -> Void in
                make.right.equalTo(separatorView)
                make.left.equalTo(firstLevelIndicatorImageView.snp_right)
                make.bottom.equalTo(separatorView.snp_top)
            }
            
            levelLabel.snp_remakeConstraints{
                (make) -> Void in
                make.right.equalTo(separatorView)
                make.left.equalTo(firstLevelIndicatorImageView.snp_right)
                make.top.equalTo(separatorView.snp_bottom)
            }
            
            usernameLabel.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(separatorView)
                make.left.equalTo(firstLevelIndicatorImageView.snp_right)
                make.bottom.equalTo(separatorView.snp_top)
            }
            
            levelLabel.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(separatorView)
                make.left.equalTo(firstLevelIndicatorImageView.snp_right)
                make.top.equalTo(separatorView.snp_bottom)
            }
            
            followView.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.equalTo(placeholderView)
                make.right.equalTo(placeholderView)
                make.height.equalTo(placeholderView).multipliedBy(0.20)
            }
            
            reportView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(followView.snp_bottom)
                make.left.right.equalTo(followView)
                make.height.equalTo(followView)
            }
            
            followImageView.snp_remakeConstraints{
                (make) -> Void in
                make.centerX.equalTo(circleAvatarView)
                make.centerY.equalTo(followView)
                make.height.width.equalTo(self.snp_height).multipliedBy(0.1)
            }
            
            reportImageView.snp_remakeConstraints {
                (make) -> Void in
                make.centerY.equalTo(reportView)
                make.centerX.equalTo(circleAvatarView)
                make.height.width.equalTo(followImageView)
            }
            
            followLabel.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(followImageView.snp_left).offset(-5)
                make.left.equalTo(followView)
                make.centerY.equalTo(followView)
            }
            
            reportLabel.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(reportImageView.snp_left).offset(-5)
                make.left.equalTo(reportView)
                make.centerY.equalTo(reportView)
            }
            
            optionButton.snp_remakeConstraints {
                (make) -> Void in
                make.top.right.equalTo(self)
                make.left.equalTo(usernameLabel)
                make.bottom.equalTo(placeholderView.snp_top)
            }
            
        } else {
            circleAvatarView.snp_remakeConstraints{(make) -> Void in
                make.left.equalTo(self).offset(10)
                make.height.equalTo(self.snp_height).multipliedBy(0.2)
                make.width.equalTo(self.snp_height).multipliedBy(0.2)
                make.top.equalTo(self).offset(10)
            }
            
            thirdLevelIndicatorImageView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(self).offset(-10)
                make.height.equalTo(self.snp_height).multipliedBy(0.06)
                make.width.equalTo(self.snp_height).multipliedBy(0.06)
                make.bottom.equalTo(separatorView.snp_top)
            }
            
            secondLevelIndicatorImageView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(thirdLevelIndicatorImageView.snp_left).offset(-5)
                make.height.width.equalTo(thirdLevelIndicatorImageView)
                make.centerY.equalTo(thirdLevelIndicatorImageView)
            }
            
            firstLevelIndicatorImageView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(secondLevelIndicatorImageView.snp_left).offset(-5)
                make.height.width.equalTo(thirdLevelIndicatorImageView)
                make.centerY.equalTo(thirdLevelIndicatorImageView)
            }
            
            separatorView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(self)
                make.left.equalTo(circleAvatarView.snp_right).offset(10)
                make.height.equalTo(1)
                make.centerY.equalTo(circleAvatarView)
            }
            
            usernameLabel.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(separatorView)
                make.right.equalTo(firstLevelIndicatorImageView.snp_left)
                make.bottom.equalTo(separatorView.snp_top)
            }
            
            levelLabel.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(separatorView)
                make.right.equalTo(firstLevelIndicatorImageView.snp_left)
                make.top.equalTo(separatorView.snp_bottom)
            }
            
            followView.snp_remakeConstraints {
                (make) -> Void in
                make.top.right.equalTo(placeholderView)
                make.left.equalTo(placeholderView)
                make.height.equalTo(placeholderView).multipliedBy(0.2)
            }
            
            cameraSwitchButton.snp_remakeConstraints {
                (make) -> Void in
                make.centerX.equalTo(circleAvatarView)
                make.top.equalTo(placeholderView)
                make.left.equalTo(placeholderView)
            }
            
            reportView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(followView.snp_bottom)
                make.left.right.equalTo(followView)
                make.height.equalTo(followView)
            }
            
            followImageView.snp_remakeConstraints {
                (make) -> Void in
                make.centerX.equalTo(circleAvatarView)
                make.centerY.equalTo(followView)
                make.height.width.equalTo(self.snp_height).multipliedBy(0.1)
            }
            
            reportImageView.snp_remakeConstraints {
                (make) -> Void in
                make.centerY.equalTo(reportView)
                make.centerX.equalTo(circleAvatarView)
                make.height.width.equalTo(followImageView)
            }
            
            followLabel.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(followImageView.snp_right).offset(5)
                make.right.equalTo(followView)
                make.centerY.equalTo(followView)
            }
            
            reportLabel.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(reportImageView.snp_right).offset(5)
                make.right.equalTo(reportView)
                make.centerY.equalTo(reportView)
            }
            
            optionButton.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.equalTo(self)
                make.right.equalTo(usernameLabel)
                make.bottom.equalTo(placeholderView.snp_top)
            }
        }
    }
}
