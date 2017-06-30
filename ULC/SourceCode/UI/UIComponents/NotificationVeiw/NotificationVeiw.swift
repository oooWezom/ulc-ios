//
//  NotificationVeiw.swift
//  ULC
//
//  Created by Vitya on 8/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

class NotificationVeiw: UIView, NibLoadableView {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var talkCategoryImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
    //Mark - Private properties
    private var timer = NSTimer()
    private var seconds = CGFloat()
    
    private let categoryViewModel = CategoryViewModel()
    
    let currentWindow = UIApplication.sharedApplication().keyWindow

    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    func configureView() {
        userNameLabel.textColor = UIColor.whiteColor()
        statusDescriptionLabel.textColor = UIColor.whiteColor()
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        userAvatarImageView.roundedView(true, borderColor: UIColor(named: .NavigationBarColor), borderWidth: 2.0, cornerRadius: nil);
        
        closeButton.addTarget(self, action: #selector(closeNotificationView), forControlEvents: .TouchUpInside)
    }
    
    func closeNotificationView() {
        self.removeFromSuperview()
        currentWindow?.windowLevel = UIWindowLevelNormal
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:  #selector(update), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        seconds = 0
        timer.invalidate()
        closeNotificationView()
    }
    
    func update() {
        if seconds == 3
        {
            stopTimer()
        } else {
            seconds += 1
        }
    }
    
    func isTimerStarting() -> Bool {
        return timer.valid
    }
    
    func updateViewWithModel(model: AnyObject, sessionType: EventType) {
        
        startTimer()
        
        if sessionType == EventType.GameSession {
            guard let gameSessionModel = model as? WSNotifyGameEntity else {
                return
            }
            
            guard let game = gameSessionModel.game, let firstPlayer = game.players.first else {
                return
            }
            
            userNameLabel.text = firstPlayer.name
            statusDescriptionLabel.text = R.string.localizable.is_in_two_play()
            
            talkCategoryImageView.image = R.image.twoplay_user_icon()
            
            if !firstPlayer.avatar.isEmpty {
                
                let stringUrl = firstPlayer.avatar;
                let imageCache = ImageCache.defaultCache;
                let avatarURL = NSURL(string: Constants.userContentUrl + stringUrl)!;
                let resource = Resource(downloadURL: avatarURL, cacheKey: stringUrl)
                
                userAvatarImageView.kf_setImageWithResource(resource,
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
            
        } else if sessionType == EventType.TalkSession {
            guard   let talkSessionModel = model as? WSNotifyTalkEntity,
                    let talk = talkSessionModel.talk,
                    let streamer = talk.streamer else {
                return
            }

            userNameLabel.text = streamer.name
            statusDescriptionLabel.text = "\(R.string.localizable.is_in_two_talk()). \"\(talk.state_desc)\"" //#MARK localized

            if let talkCategoryIconURL = categoryViewModel.fetchWhiteCategoryAvatarURL(talk.category) {
                talkCategoryImageView.kf_setImageWithURL(NSURL(string: talkCategoryIconURL),
                                                           placeholderImage: nil,
                                                           optionsInfo: [.BackgroundDecode],
                                                           progressBlock: nil,
                                                           completionHandler: nil);
            }

            if !streamer.avatar.isEmpty {
                
                let stringUrl = streamer.avatar;
                let imageCache = ImageCache.defaultCache;
                let avatarURL = NSURL(string: Constants.userContentUrl + stringUrl)!;
                let resource = Resource(downloadURL: avatarURL, cacheKey: stringUrl)
                
                userAvatarImageView.kf_setImageWithResource(resource,
                                                        placeholderImage: R.image.defaulf_camera_icon(),
                                                        optionsInfo: [.BackgroundDecode],
                                                        progressBlock: nil,
                                                        completionHandler: { (image, error, cacheType, imageURL) in
                                                            if let image = image {
                                                                imageCache.storeImage(image, originalData: nil, forKey: stringUrl, toDisk: true, completionHandler: nil);
                                                            }
                })
            }

        }
    }

}
