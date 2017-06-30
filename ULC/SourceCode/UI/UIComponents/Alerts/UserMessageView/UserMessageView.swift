//
//  UserInviteMessageView.swift
//  ULC
//
//  Created by Vitya on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

protocol UserMessageDelegate {
    func timeIsOver()
}

class UserMessageView: UIView, NibLoadableView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var delegate: UserInviteMessageDelegate?
    
    var timer = NSTimer()
    var seconds = CGFloat()
    
    let maxSecondInterval: CGFloat = 10
    let timerStep: CGFloat = 0.1
    let outerCircle = CAShapeLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.roundedView(true, borderColor: UIColor(named: .NavigationBarColor), borderWidth: 2.0, cornerRadius: nil);
        
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        okButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        seconds = maxSecondInterval
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        setTimerProgressToAvatar()
		configureViews()
    }

	func configureViews(){
		okButton.setTitle(R.string.localizable.ok(), forState: .Normal) //#MARK localized
	}
    
    func setTimerProgressToAvatar() {
        let frameSize = avatarImageView.frame.size
        outerCircle.path = UIBezierPath(ovalInRect: CGRect(x: 2.5, y: 2.5, width: frameSize.width - 5, height: frameSize.height - 5)).CGPath
        outerCircle.lineWidth = 2
        outerCircle.lineCap = kCALineCapRound
        outerCircle.fillColor = UIColor.clearColor().CGColor
        outerCircle.strokeColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.addSublayer(outerCircle)
    }
    
    func hideTimeProgressToAvatar(hidden: Bool) {
        stop()
        outerCircle.hidden = hidden
    }
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timerStep.doubleValue, target: self, selector:  #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer.invalidate()
        seconds = maxSecondInterval
        outerCircle.strokeEnd = seconds * 0.1
    }
    
    func update() {
        if(seconds < 0)
        {
            stop()
            delegate?.inviteTimeIsOver()
        } else {
            seconds = seconds - timerStep
            outerCircle.strokeEnd = seconds * 0.1
        }
    }
    
    func updateViewWithModel(model: AnyObject?, message: AnyObject?, resultStatus: WSInviteToTalkResponseResult) {
        guard let userEntity = model as? UserEntity where !userEntity.name.isEmpty else {
            return;
        }
        
        guard let messageEntity = message as? WSInviteEntity else {
            return
        }
        
        switch resultStatus {
        case .SendedInvite:
            hideTimeProgressToAvatar(false)
            start()

            messageLabel.text = "\(R.string.localizable.waiting_for()) " + userEntity.name + " \(R.string.localizable.decision().lowercaseString)"
        case .AccepInvite:
             hideTimeProgressToAvatar(true)
            messageLabel.text = userEntity.name + " \(R.string.localizable.accepted_invite().lowercaseString)"
        case .DenyInvite:
             hideTimeProgressToAvatar(true)
            messageLabel.text = userEntity.name + " \(R.string.localizable.refused().lowercaseString)"
        case .DoNotDisturb:
             hideTimeProgressToAvatar(true)

            messageLabel.text = userEntity.name + " \(R.string.localizable.not_disturb_message()) " + String(messageEntity.time / 60) + " \(R.string.localizable.minutes().lowercaseString)"
        }

        if !userEntity.avatar.isEmpty {
            
            let stringUrl = userEntity.avatar;
            let imageCache = ImageCache.defaultCache;
            let avatarURL = NSURL(string: Constants.userContentUrl + stringUrl)!;
            let resource = Resource(downloadURL: avatarURL, cacheKey: stringUrl)
            
            avatarImageView.kf_setImageWithResource(resource,
                                                    placeholderImage: R.image.defaulf_camera_icon(),
                                                    optionsInfo: [.BackgroundDecode],
                                                    progressBlock: nil,
                                                    completionHandler: { (image, error, cacheType, imageURL) in
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                                            if let image = image {
                                                                imageCache.storeImage(image, originalData: nil, forKey: stringUrl, toDisk: true, completionHandler: nil);
                                                            }
                                                    })
            })
        }
    }
}
