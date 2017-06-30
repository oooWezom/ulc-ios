//
//  MessageCell.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate
import RealmSwift
import SwiftKeychainWrapper

class ConversationCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var followersMaskImageView: UIImageView!
    @IBOutlet weak var opponentAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postedTimeLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    private let userAvatarImageView = UIImageView();
    private let userStatusView = UIView();
    
    private let userTextLabel = UILabel();
    private let opponentTextLabel = UILabel();
    
    private let littleMaskImageView = UIImageView(image: R.image.follower_little_mask());

    lazy var userID: Int = {
        
        guard let value = KeychainWrapper.stringForKey(Constants.currentUserId) else {
            return 0
        }
        guard let returnValue = Int(value) else {
            return 0
        }
        return returnValue;
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        opponentTextLabel.numberOfLines = 0;
        opponentTextLabel.textAlignment = .Left;
        
        postedTimeLabel.text = ""
        postedTimeLabel.adjustsFontSizeToFitWidth = true;
        
        setViewsBackgroundColor(UIColor.whiteColor())
    }
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let model = model as? ConversationEntity else {
            return;
        }
        
        if let parther = model.parther {
            userNameLabel.text = parther.name;
            
            if !parther.avatar.isEmpty {
                let stringUrl = Constants.userContentUrl + parther.avatar
                let url = NSURL(string: stringUrl)!
                opponentAvatarImageView.kf_setImageWithURL(url,
                                                           placeholderImage: R.image.default_small_avatar(),
                                                           optionsInfo: [.BackgroundDecode],
                                                           progressBlock: nil,
                                                           completionHandler: nil);
            }
            
            if let userStatus = UserStatus(rawValue: parther.status) {
                
                switch userStatus {
                case .Online:
                    statusImageView.image = R.image.online_status_icon();
                    break;
                case .Talking:
                    statusImageView.image = R.image.talk_status_icon();
                    break;
                case .Playing:
                    statusImageView.image = R.image.play_status_icon();
                    break;
                default:
                    statusImageView.image = nil;
                    break;
                }
            }
        }
        
        
        if let lastMessage = model.lastConversation {
            
            let interval = NSTimeInterval(Double(lastMessage.postedTimestamp));
            let date =  NSDate(timeIntervalSince1970: interval);
            
            if NSDate().monthsFrom(date) > 1 {
                if let dateString = date.toString(DateFormat.Custom("d MMM")) {
                    postedTimeLabel.text = dateString
                }
            } else if NSDate().weeksFrom(date) > 1 {
                if let dateString = date.toString(DateFormat.Custom("d MMM")) {
                    postedTimeLabel.text = dateString
                }
            } else if NSDate().daysFrom(date) > 1 {
                if let dateString = date.toString(DateFormat.Custom("d MMM")) {
                    postedTimeLabel.text = dateString
                }
            } else if NSDate().daysFrom(date) < 1{
                if let dateString = date.toString(DateFormat.Custom("HH:mm")) {
                    postedTimeLabel.text = dateString
                }
            } else {
                postedTimeLabel.text = R.string.localizable.yesterday()
            }
        }
        
        if model.lastConversation?.senderID == userID {
            
            do {
                
                let realm = try Realm()
                if let userEntity = realm.objects(UserEntity.self).filter(NSPredicate(format: "id == %d", userID)).first {
                    
                    opponentTextLabel.removeFromSuperview();
                    
                    contentView.addSubview(userStatusView);
                    userStatusView.addSubview(userAvatarImageView);
                    userStatusView.addSubview(userTextLabel);
                    userStatusView.addSubview(littleMaskImageView);
                    
                    setUserAvatar(userEntity.avatar);
                    
                    if let lastConversation = model.lastConversation {
                        userTextLabel.text = lastConversation.text;
                    }
                    
                }
            } catch{
                return;
            }
            
        } else {
            
            userStatusView.removeFromSuperview();
            userAvatarImageView.removeFromSuperview();
            userTextLabel.removeFromSuperview();
            littleMaskImageView.removeFromSuperview();
            
            if let lastConversation = model.lastConversation  where !lastConversation.text.isEmpty {
                contentView.addSubview(opponentTextLabel);
                opponentTextLabel.text = lastConversation.text;
            }
        }
        
        if model.unreadCount == 0 && model.lastConversation?.deliveredTimestamp == 0 {
            userStatusView.backgroundColor = UIColor(named: .UnreadMessageBackgroundColor)
            userTextLabel.backgroundColor = UIColor.clearColor()
            littleMaskImageView.image = R.image.follower_little_orange_mask()
        } else if model.unreadCount == 0 {
            self.setViewsBackgroundColor(UIColor.whiteColor())
            followersMaskImageView.image = R.image.followers_mask_icon();
            littleMaskImageView.image = R.image.follower_little_mask()
        } else {
            self.setViewsBackgroundColor(UIColor(named: .UnreadMessageBackgroundColor))
            followersMaskImageView.image = R.image.follower_big_orange_mask();
            littleMaskImageView.image = R.image.follower_little_orange_mask()
        }
        
        setNeedsUpdateConstraints();
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        if let _ = userStatusView.superview {
            
            userStatusView.snp_remakeConstraints { (make) in
                make.left.equalTo(opponentAvatarImageView.snp_right).offset(5);
                make.right.equalTo(postedTimeLabel);
                make.bottom.equalTo(opponentAvatarImageView);
                make.height.equalTo(46);
            }
            
            userAvatarImageView.snp_remakeConstraints { (make) in
                make.width.height.equalTo(42);
                make.centerY.equalTo(userStatusView);
                make.left.equalTo(5);
            }
            
            littleMaskImageView.snp_remakeConstraints { (make) in
                make.edges.equalTo(userAvatarImageView);
            }
            
            userTextLabel.snp_remakeConstraints(closure: { (make) in
                make.left.equalTo(littleMaskImageView.snp_right).offset(5);
                make.right.equalTo(postedTimeLabel);
                make.bottom.equalTo(opponentAvatarImageView);
                make.top.equalTo(userNameLabel.snp_bottom).offset(5);
            })
        }
        
        if let _ = opponentTextLabel.superview {
            
            opponentTextLabel.snp_remakeConstraints { (make) in
                make.left.equalTo(opponentAvatarImageView.snp_right).offset(5);
                make.right.equalTo(postedTimeLabel);
                make.bottom.equalTo(opponentAvatarImageView);
                make.top.equalTo(userNameLabel.snp_bottom).offset(5);
            }
        }
    }
    
    private func setUserAvatar(stringURL: String) {
        let stringUrl = Constants.userContentUrl + stringURL
        let url = NSURL(string: stringUrl)!
        userAvatarImageView.kf_setImageWithURL(url,
                                                   placeholderImage: R.image.default_small_avatar(),
                                                   optionsInfo: [.BackgroundDecode],
                                                   progressBlock: nil,
                                                   completionHandler: nil);
    }
    
    private func setViewsBackgroundColor(color: UIColor) {

        self.backgroundColor = color
        userTextLabel.backgroundColor = color
        userNameLabel.backgroundColor = color
        postedTimeLabel.backgroundColor = color
        opponentTextLabel.backgroundColor = color
        userStatusView.backgroundColor = color
    }
}
