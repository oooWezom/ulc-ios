//
//  CircleAvatarView.swift
//  ULC
//
//  Created by Alex on 6/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher
import Foundation

class CircleAvatarView: UIView, NibLoadableView {
    
    private let bottomCircleView    = CAShapeLayer()
    private let blueCircleView      = CAShapeLayer()
    private let circleLayer         = CAShapeLayer()
    
    private var heartImage          = UIImage(named: "heart_profle_icon");
    private var levelImage          = UIImage(named: "level_profile_icon");
    private var levelImageRound     = UIImage(named: "level_profile_icon_round");
    
    private let heartButton         = UIButton(type: .Custom);
    private let levelButton         = UIButton(type: .Custom);
    
    private let startAngle          = CGFloat(-M_PI_2);
    
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        layer.cornerRadius = self.width * 0.5;
        layer.masksToBounds = true;
        clipsToBounds = true
        avatarImageView.image = R.image.defaulf_camera_icon();
        
        setup();
    }
    
    private func setup() {
        
        avatarImageView.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: nil);
        avatarImageView.clipsToBounds = true
        
        bottomCircleView.path = UIBezierPath(roundedRect: CGRectMake(0, 0, self.width, self.height), cornerRadius: self.width * 0.5).CGPath
        bottomCircleView.fillColor = UIColor.clearColor().CGColor;
        bottomCircleView.strokeColor = UIColor.whiteColor().CGColor;
        bottomCircleView.lineWidth = 10;
        layer.addSublayer(bottomCircleView)
        
        blueCircleView.path = UIBezierPath(roundedRect: CGRectMake(0, 0, self.width, self.height), cornerRadius: self.width * 0.5).CGPath
        blueCircleView.fillColor = UIColor.clearColor().CGColor;
        blueCircleView.strokeColor = UIColor(named:.AvatarExpColor).CGColor
        blueCircleView.lineWidth = 4;
        layer.addSublayer(blueCircleView)
        
        backgroundColor = UIColor(named: .EventCellBackgound);
        
        addShadow();
        
        changePhotoButton.bringSubviewToFront(self);
        //self.animateCircleTo(2.0)
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.blackColor().CGColor;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowOpacity = 0.95;
        layer.shadowRadius = 32.0;
    }
    
    private func animateCircleTo(duration: NSTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        circleLayer.strokeEnd = 1.0
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }
    
    func updateViewWithModel(model: AnyObject?) {
        guard let userEntity = model as? UserEntity where !userEntity.name.isEmpty else {
            return;
        }
        if !userEntity.avatar.isEmpty {
            updateCircleAvatar(userEntity.avatar);
        }
        updateUserExperience(userEntity);
        
    }
    
    final func updateCircleAvatar(url: String) {
        
        let imageCache  = ImageCache.defaultCache;
        let avatarURL   = NSURL(string: Constants.userContentUrl + url)!;
        let resource    = Resource(downloadURL: avatarURL, cacheKey: url)
        
        var defaultImage = R.image.defaulf_camera_icon();
        if let tmpAvatarImage = avatarImageView.image {
            defaultImage = tmpAvatarImage;
        }
        
        avatarImageView.kf_setImageWithResource(resource,
                                                placeholderImage: defaultImage,
                                                optionsInfo: [.BackgroundDecode],
                                                progressBlock: nil,
                                                completionHandler: { (image, error, cacheType, imageURL) in
                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                                        if let image = image {
                                                            imageCache.storeImage(image,
                                                                originalData: nil,
                                                                forKey: url,
                                                                toDisk: true,
                                                                completionHandler: nil);
                                                        }
                                                    })
        })
    }
    
    private func updateUserExperience(userEntity: UserEntity) {
        
        
        let expirience = (userEntity.expirience * 100) / (userEntity.expMax == 0 ? 1 : userEntity.expMax);
        
        let radius = self.width * 0.5
        let endAngle = startAngle + CGFloat(CGFloat(expirience) * 0.01 * 360).degreesToRadians
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.width * 0.5, y: self.height * 0.5),
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
        
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor(named: .LoginButtonNormal).CGColor
        circleLayer.lineWidth = 4.0;
        layer.addSublayer(circleLayer)
        
        if userEntity.level < 10 {
            if let levelImageRound = levelImageRound {
                levelButton.setBackgroundImage(levelImageRound, forState: .Normal)
                levelButton.setBackgroundImage(levelImageRound, forState: .Highlighted)
                
                let avatarX = self.avatarImageView.xCenter - levelImageRound.size.width * 0.5
                let newX = avatarX + radius * cos(endAngle);
                let avatarY = self.avatarImageView.yCenter - levelImageRound.size.height * 0.5
                let newY = avatarY + radius * sin(endAngle);
                
                levelButton.frame = CGRectMake(newX, newY, levelImageRound.size.width, levelImageRound.size.height);
                self.addSubview(levelButton);
            }
        } else {
            if let levelImage = levelImage {
                levelButton.setBackgroundImage(levelImage, forState: .Normal)
                levelButton.setBackgroundImage(levelImage, forState: .Highlighted)
                
                let avatarX = self.avatarImageView.xCenter - levelImage.size.width * 0.5
                let newX = avatarX + radius * cos(endAngle);
                let avatarY = self.avatarImageView.yCenter - levelImage.size.height * 0.5
                let newY = avatarY + radius * sin(endAngle);
                
                levelButton.frame = CGRectMake(newX, newY, levelImage.size.width, levelImage.size.height);
                self.addSubview(levelButton);
            }
        }
        
        levelButton.setTitle(String(userEntity.level), forState: .Normal)
        levelButton.setTitle(String(userEntity.level), forState: .Highlighted)
        
        if let levelLabel = levelButton.titleLabel {
            levelLabel.font =  UIFont(name: levelLabel.font.fontName, size: 16)
            levelLabel.adjustsFontSizeToFitWidth = true;
        }
        
        if let heartImage = heartImage {
            heartButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 3, 3);
            
            if let heartLabel = heartButton.titleLabel {
                heartLabel.font =  UIFont(name: heartLabel.font.fontName, size: 16)
                heartLabel.adjustsFontSizeToFitWidth = true;
            }
            
            var userLikes = String(userEntity.likes)
            
            if userEntity.likes > 999_999_999 {
                let roundLikes = userEntity.likes.roundDivision(1000_000_000)
                userLikes = String(roundLikes) + "b"
            } else if userEntity.likes > 999_999 {
                let roundLikes = userEntity.likes.roundDivision(1000_000)
                userLikes = String(roundLikes) + "m"
            } else if userEntity.likes > 999 {
                let roundLikes = userEntity.likes.roundDivision(1000)
                userLikes = String(roundLikes) + "k"
            }
            
            heartButton.setTitle(userLikes, forState: .Normal)
            heartButton.setTitle(userLikes, forState: .Highlighted)
            heartButton.setBackgroundImage(heartImage, forState: .Normal)
            heartButton.setBackgroundImage(heartImage, forState: .Highlighted)
            
            let heartAngle = endAngle + CGFloat(M_PI)
            
            let heartX = self.avatarImageView.xCenter - heartImage.size.width * 0.5
            let newX = heartX + radius * cos(heartAngle);
            let heartY = self.avatarImageView.yCenter - heartImage.size.height * 0.5
            let newY = heartY + radius * sin(heartAngle);
            
            heartButton.frame = CGRectMake(newX, newY, heartImage.size.width, heartImage.size.height);
            self.addSubview(heartButton);
        }
        changePhotoButton.bringSubviewToFront(self);
    }
}
