//
//  UserProfileViewController.swift
//  ULC
//
//  Created by Alex on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import RealmSwift

class UserProfileViewController: GeneralUserProfileViewController, ChooseCategoryDelegate {
    
    private let blockButton     = UIButton(type: .Custom);
    private let reportButton    = UIButton(type: .Custom);
    private let inviteButton    = UIButton(type: .Custom);
    private let chatButton      = UIButton(type: .Custom);
    private let followButton    = UIButton(type: .Custom);
    private let twoPlayButton   = UIButton(type: .Custom);
    
    private let blockLabel      = UILabel();
    private let reportLabel     = UILabel();
    private let inviteLabel     = UILabel();
    private let chatLabel       = UILabel();
    private let followLabel     = UILabel();
    private let twoPlayLabel    = UILabel();
    
    private let topOffset = -10;
    
    private let messagesViewModel = MessagesViewModel();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: .LoginButtonNormal);
        userHeaderView.photoButton.hidden = true;
        addViews();
        attachSignals();
        configureView();
    }
    
    private func configureView() {
        userHeaderView.addRightGradient()
        
        customAlertMessageController.chooseCategoryTableView.delegate = self
        
        blockButton.addTarget(self, action: #selector(blockButtonTouch), forControlEvents: .TouchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTouch), forControlEvents: .TouchUpInside)
        inviteButton.addTarget(self, action: #selector(inviteButtonTouch), forControlEvents: .TouchUpInside)
        followButton.addTarget(self, action: #selector(followButtonTouch), forControlEvents: .TouchUpInside)
        chatButton.addTarget(self, action: #selector(openChat), forControlEvents: .TouchUpInside)
        twoPlayButton.addTarget(self, action: #selector(openAnotherUserStream), forControlEvents: .TouchUpInside)
    }
    
    private func addViews() {
        addButtons();
        
        configureLabel(blockLabel,      title: R.string.localizable.block());
        configureLabel(reportLabel,     title: R.string.localizable.report());
        configureLabel(inviteLabel,     title: R.string.localizable.invite());
        configureLabel(chatLabel,       title: R.string.localizable.chat());
        configureLabel(followLabel,     title: R.string.localizable.follow());
        configureLabel(twoPlayLabel,    title: R.string.localizable.follow())
    }
    
    private func attachSignals() {
        
        // MARK:- REST API signals
        userProfileViewModel.userEntity.producer.startWithNext { [unowned self](user: UserEntity?) in
            guard let user = user else {
                return;
            }
            
            if user.link == 1 {
                self.followLabel.text = R.string.localizable.unfollow()
                self.followButton.setImage(R.image.unfollow_user_icon(), forState: .Normal)
            } else {
                self.followLabel.text = R.string.localizable.follow()
                self.followButton.setImage(R.image.follow_user_icon(), forState: .Normal)
            }

            if user.block == 1 {
                self.blockLabel.text = R.string.localizable.unblock()
                self.blockButton.setImage(R.image.unblock_user_icon(), forState: .Normal)
            } else {
                self.blockLabel.text = R.string.localizable.block()
                self.blockButton.setImage(R.image.block_user_icon(), forState: .Normal)
            }
            
            if let userStatus = UserStatus(rawValue: user.status) {
                
                switch userStatus {
                case .Online:
                    self.twoPlayButton.setImage(R.image.status_online_white_icon(), forState: .Normal);
                    self.twoPlayLabel.hidden = true
                    break;
                case .Talking:
                    self.twoPlayButton.setImage(R.image.status_talk_white_icon(), forState: .Normal);
                    self.twoPlayLabel.text = R.string.localizable.two_talk_with_number()
                    break;
                case .Playing:
                    self.twoPlayButton.setImage(R.image.status_play_white_icon(), forState: .Normal);
                    self.twoPlayLabel.text = R.string.localizable.two_play_with_number()
                    break;
                default:
                    self.twoPlayButton.hidden = true
                    self.twoPlayLabel.hidden = true
                    break;
                }
            }
        }
        
        // MARK:- WS signals
        wsProfileViewModel.inviteToTalkHandler.signal
            .observeOn(UIScheduler())
            .observeResult  { [unowned self] observer in
                guard let message = observer.value,
                    let result = WSInviteToTalkResult(rawValue: message.result) else {
                        return
                }
                
                switch result {
                case .OK:
                    self.customAlertMessageController.showUserAlertMessage(self.userProfileViewModel.userEntity.value, message: message, resultStatus: .SendedInvite)
                    
                default:
                    self.customAlertMessageController.removeController()
                    self.showAlertMessage("", message: R.string.localizable.user_not_ready(), completitionHandler: nil)
                }
        }
        
        wsProfileViewModel.followUserHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                
                self.followLabel.text = R.string.localizable.unfollow()
                self.followButton.setImage(R.image.unfollow_user_icon(), forState: .Normal)
        }
        
        wsProfileViewModel.unfollowUserHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                self.followLabel.text = R.string.localizable.follow()
                self.followButton.setImage(R.image.follow_user_icon(), forState: .Normal)
        }
    }
    
    private func addButtons() {
        if let blockImage = R.image.block_user_icon() {
            configureButton(blockButton, image: blockImage);
        }
        if let reportImage = R.image.report_user_icon() {
            configureButton(reportButton, image: reportImage);
        }
        if let inviteImage = R.image.invite_user_icon() {
            configureButton(inviteButton, image: inviteImage);
        }
        if let chatImage = R.image.chat_user_icon() {
            configureButton(chatButton, image: chatImage);
        }
        if let followImage = R.image.follow_user_icon() {
            configureButton(followButton, image: followImage)
        }
        if let twoPlayImage = R.image.twoplay_user_icon() {
            configureButton(twoPlayButton, image: twoPlayImage);
        }
    }
    
    private func configureButton(button: UIButton, image: UIImage) {
        
        button.setTitle("", forState: .Normal);
        button.setImage(image, forState: .Normal);
        button.setImage(image, forState: .Selected);
        button.setImage(image, forState: .Highlighted);
        
        userHeaderView.addSubview(button);
    }
    
    private func configureLabel(label: UILabel, title: String) {
        
        label.textColor = UIColor.whiteColor();
        label.font = label.font.fontWithSize(14);
        label.text = title;
        userHeaderView.addSubview(label);
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        
        blockButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(27);
            make.right.equalTo(-10);
            make.bottom.equalTo(-23);
        }
        blockLabel.snp_remakeConstraints {[unowned self] (make) in
            make.height.equalTo(15);
            make.centerY.equalTo(self.blockButton);
            make.right.equalTo(self.blockButton.snp_left).offset(-7);
        }
        
        reportButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(27);
            make.right.equalTo(-10);
            make.bottom.equalTo(blockLabel.snp_top).offset(self.topOffset);
        }
        reportLabel.snp_remakeConstraints {[unowned self] (make) in
            make.width.equalTo(self.reportLabel.intrinsicContentSize().width);
            make.height.equalTo(15);
            make.centerY.equalTo(self.reportButton);
            make.right.equalTo(self.reportButton.snp_left).offset(-7);
        }
        
        inviteButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(27);
            make.right.equalTo(-10);
            make.bottom.equalTo(reportButton.snp_top).offset(self.topOffset);
        }
        inviteLabel.snp_remakeConstraints { [unowned self] (make) in
            make.width.equalTo(self.inviteLabel.intrinsicContentSize().width);
            make.height.equalTo(15);
            make.centerY.equalTo(self.inviteButton);
            make.right.equalTo(self.inviteButton.snp_left).offset(-7);
        }
        
        chatButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(27);
            make.right.equalTo(-10);
            make.bottom.equalTo(inviteButton.snp_top).offset(self.topOffset);
        }
        chatLabel.snp_remakeConstraints { [unowned self] (make) in
            make.width.equalTo(self.chatLabel.intrinsicContentSize().width);
            make.height.equalTo(15);
            make.centerY.equalTo(self.chatButton);
            make.right.equalTo(self.chatButton.snp_left).offset(-7);
        }
        
        followButton.snp_remakeConstraints { (make) in
            make.width.height.equalTo(27);
            make.right.equalTo(-10);
            make.bottom.equalTo(chatButton.snp_top).offset(self.topOffset);
        }
        followLabel.snp_remakeConstraints { make in
            make.height.equalTo(15);
            make.centerY.equalTo(self.followButton);
            make.right.equalTo(self.followButton.snp_left).offset(-7);
        }
        
        twoPlayButton.snp_remakeConstraints { make in
            make.width.height.equalTo(27);
            make.left.equalTo(10);
            make.top.equalTo(10);
        }
        twoPlayLabel.snp_remakeConstraints { make in
            make.height.equalTo(15);
            make.centerX.equalTo(self.twoPlayButton);
            make.top.equalTo(self.twoPlayButton.snp_bottom).offset(2);
        }
    }
    
    func inviteButtonTouch() {
        if let userProfileID = userProfileID {
            customAlertMessageController.showChooseCategoryTableView(userProfileID)
        }
    }
    
    func blockButtonTouch() {
        guard let userProfileID = userProfileID else {
            return
        }
        
        if self.blockLabel.text == R.string.localizable.block() {
            self.userProfileViewModel.addToBlackList(userProfileID).start { [unowned self] observer in
                
                switch(observer.event) {
                case .Completed:
                    self.showAlertMessage(R.string.localizable.added(), message: R.string.localizable.added_to_blacklist_alert(), completitionHandler: nil);
                    self.blockLabel.text = R.string.localizable.unblock()
                    self.blockButton.setImage(R.image.unblock_user_icon(), forState: .Normal)
                    
                case .Failed(let error):
                    self.showULCError(error)
                default:
                    Swift.debugPrint("another response")
                }
            }
            
        } else {
            
            self.userProfileViewModel.removeFromBlackList(userProfileID).start { [unowned self] observer in
                switch(observer.event) {
                case .Completed:
                    self.showAlertMessage(R.string.localizable.removed(), message: R.string.localizable.removed_from_blacklist_alert(), completitionHandler: nil);
                    self.blockLabel.text = R.string.localizable.block()
                    self.blockButton.setImage(R.image.block_user_icon(), forState: .Normal)
                    
                case .Failed(let error):
                    self.showULCError(error)
                default:
                    break
                }
            }
        }
    }
    
    func reportButtonTouch() {
        if let userInfo = userProfileViewModel.userEntity.value, let userProfileID = userProfileID {
            customAlertMessageController.showReportUserAlertView(userInfo, userId: userProfileID)
        }
    }
    
    func followButtonTouch() {
        guard let userId = userProfileID else {
            return
        }
        
        if followLabel.text == R.string.localizable.follow() {
            wsProfileViewModel.followUser(userId)
        } else {
            wsProfileViewModel.unfollowUser(userId)
        }
    }
    
    func openChat() {
        if let user = userProfileViewModel.userEntity.value {
            messagesViewModel.openMessagesViewController(Partner.partherFromUser(user));
        }
    }
    
    func openAnotherUserStream() {
        guard let user = userProfileViewModel.userEntity.value else {
            return
        }
        if user.status == UserStatus.Talking.rawValue, let talk = user.talk {
            userProfileViewModel.openSpectatorTalkSessionVC(talk, viewControllerType: .Normal);
        } else if user.status == UserStatus.Playing.rawValue, let game = user.game {
            //userProfileViewModel.openSpectatorGameSessionVC(game, viewTypeController: .Normal);
            userProfileViewModel.openSpectatorViewController(game, viewControllerType: .Normal)
        }
    }
    
    //MARK delegate methods
    func selectedCategory(categoryId: Int) {
        if let userId = userProfileID {
            wsProfileViewModel.inviteToTalkSession(userId, category: categoryId)
        }
    }
    
    override func openFollowers() {
        userProfileViewModel.openFollows(userProfileID);
    }
    
    override func openFollowing() {
        userProfileViewModel.openFollowing(userProfileID);
    }
    
    override func openGames() {
        userProfileViewModel.openGames(userProfileID);
    }
    
    override func openStreams() {
        userProfileViewModel.openStreams(userProfileID);
    }
}
