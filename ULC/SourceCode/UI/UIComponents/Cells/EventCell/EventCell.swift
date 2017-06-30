//
//  EventCell.swift
//  ULC
//
//  Created by Alex on 6/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftDate
import SnapKit
import RealmSwift
import ReactiveCocoa
import Result

class EventCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var opponentNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    @IBOutlet weak var actionTypeImageView: UIImageView!
    @IBOutlet weak var ownerLikeIconImageView: UIImageView!
    @IBOutlet weak var opponentLikeIconImageView: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var ownerExperienceLabel: UILabel!
    @IBOutlet weak var opponentExperienceLabel: UILabel!
    @IBOutlet weak var opponentLikeCountLabel: UILabel!
    @IBOutlet weak var typeDescriptionLabel: UILabel!
    @IBOutlet weak var ownLevelDescriptionLabel: UILabel!
    
    private let opponentImageView = UIImageView();
    private let followingImageView = UIImageView();
    private let partnerImageView = UIImageView();
    
    private let miniAvatarImage = R.image.mini_avatar_icon();
    private let defaultAvatarImage = R.image.default_small_avatar();
    private let categoryViewModel = CategoryViewModel();
    
    private let followEventImage = R.image.follow_event_icon();
    private let playEventImage = R.image.play_event_icon();
    
    @IBOutlet weak var topViewOffset: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        opponentImageView.hidden = true;
        followingImageView.hidden = true;
        partnerImageView.hidden = true;
        
        topView.backgroundColor = UIColor(named: .EventCellBackgound)
        topSeparatorView.backgroundColor = UIColor(named: .EventSeparatorLine);
        bottomSeparatorView.backgroundColor = UIColor(named: .EventSeparatorLine);
        
        contentView.addSubview(opponentImageView);
        opponentImageView.roundedView(true, borderColor: UIColor.blackColor(), borderWidth: 1.0, cornerRadius: 11);
        
        contentView.addSubview(followingImageView);
        followingImageView.roundedView(true, borderColor: UIColor.blackColor(), borderWidth: 1.0, cornerRadius: 11);
        
        contentView.addSubview(partnerImageView);
        partnerImageView.roundedView(true, borderColor: UIColor.blackColor(), borderWidth: 1.0, cornerRadius: 11);
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        avatarView.kf_cancelDownloadTask();
        avatarView.image = nil;
        
        actionTypeImageView.image = nil;
        opponentImageView.image = nil;
        followingImageView.image = nil;
        partnerImageView.image = nil;
        
        opponentImageView.hidden = true;
        followingImageView.hidden = true;
        partnerImageView.hidden = true;
    }
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let model = model as? SelfEvent else {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            let interval = NSTimeInterval(Double(model.created_timestamp));
            let date =  NSDate(timeIntervalSince1970: interval);
            if let dateString = date.toString(DateFormat.Custom("d.MM")) {
                dispatch_async(dispatch_get_main_queue(), {
                    self?.dateLabel.text = dateString;
                })
            }
        }
        
        dispatch_async(GCD.serialQueue()) {
            let roundedValue = model.spectators.roundValueAsString()
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.followerCountLabel.text = roundedValue;
                })
        }
        
        if let owner = model.owner {
            let stringUrl = Constants.userContentUrl + owner.avatar
            let url = NSURL(string: stringUrl)
            avatarView.kf_setImageWithURL(url, placeholderImage: defaultAvatarImage, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
            
            nameLabel.text = owner.name;
            likeCountLabel.text = model.likes.roundValueAsString()
            
            if owner.level_up == 0 {
                ownLevelDescriptionLabel.text = ""
            } else {
                ownLevelDescriptionLabel.text = R.string.localizable.get_lvl_up()
            }
            
            var exp = owner.exp
            if model.typeId == EventType.TalkSession.rawValue {
                exp = model.exp
            }
            
            if exp > 0 {
                ownerExperienceLabel.text = "+" + exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            } else {
                ownLevelDescriptionLabel.text = R.string.localizable.leave_session_event().lowercaseString
                ownerExperienceLabel.text = exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            }
        }
        
        if let opponent = model.opponent {
            opponentImageView.hidden = false;
            let url = NSURL(string: Constants.userContentUrl + opponent.avatar)!;
            opponentImageView.kf_setImageWithURL(url, placeholderImage: miniAvatarImage, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
            
            opponentNameLabel.text = opponent.name
            opponentLikeCountLabel.text = opponent.likes.roundValueAsString()
            
            if opponent.level_up == 0 {
                typeDescriptionLabel.text = ""
            } else {
                typeDescriptionLabel.text = R.string.localizable.get_lvl_up()
            }
            
            if opponent.exp > 0 {
                opponentExperienceLabel.text =  "+" + opponent.exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            } else {
                typeDescriptionLabel.text = R.string.localizable.leave_session_event().lowercaseString
                opponentExperienceLabel.text = opponent.exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            }
        }
        
        if let following = model.following {
            followingImageView.hidden = false;
            let url = NSURL(string: Constants.userContentUrl + following.avatar)!;
            followingImageView.kf_setImageWithURL(url, placeholderImage: miniAvatarImage, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
            
            opponentNameLabel.text = following.name
            typeDescriptionLabel.text = model.type_desc
        }
        
        if let partners = model.partners.first where !partners.name.isEmpty {
            partnerImageView.hidden = false;
            let url = NSURL(string: Constants.userContentUrl + partners.avatar);
            partnerImageView.kf_setImageWithURL(url, placeholderImage: miniAvatarImage, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
            
            opponentNameLabel.text = partners.name;
            opponentLikeCountLabel.text = partners.likes.roundValueAsString()
            
            if partners.exp > 0 {
                opponentExperienceLabel.text =  "+" + partners.exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            } else {
                typeDescriptionLabel.text = R.string.localizable.leave_session_event().lowercaseString
                opponentExperienceLabel.text = partners.exp.roundValueAsString() + " \(R.string.localizable.xp()),"
            }
        }
        
        switch model.typeId {
            
        case EventType.StartFollow.rawValue:
            actionTypeImageView.image = followEventImage;
            self.hideOwnerComponents(true)
            self.hideOpponentComponents(true)
            opponentNameLabel.hidden = false
            
        case EventType.GameSession.rawValue:
            actionTypeImageView.image = playEventImage;
            self.hideOwnerComponents(false)
            self.hideOpponentComponents(false)
            
        case EventType.TalkSession.rawValue:
            self.hideOwnerComponents(false)
            self.hideOpponentComponents(true)
            
            getCategory(model.category)
            
            if !model.name.isEmpty {
                typeDescriptionLabel.text = model.name
            }
            
        default:
            break;
        }
        
        self.setNeedsUpdateConstraints();
    }
    
    func getCategory(byId: Int) {
        categoryViewModel.fetchCategory(byId)
            .producer
            .takeUntil(self.prepareForReuseSignal())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) in
                
                observer.observeResult { observer in
                    guard let category = observer.value else {
                        return
                    }
                    
                    var url = String()
                    
                    if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
                        url = Constants.smallTalkCategoryIconUrl + category.icon
                    } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
                        url = Constants.threeXsmallTalkCategoryIconUrl + category.icon
                    }
                    self?.actionTypeImageView.kf_setImageWithURL(NSURL(string: url), placeholderImage: nil, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
                    self?.typeDescriptionLabel.text = category.name;
                }
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        if !opponentImageView.hidden {
            opponentImageView.snp_remakeConstraints(closure: { (make) in
                make.width.height.equalTo(23);
                make.bottom.equalTo(avatarView);
                make.centerX.equalTo(avatarView.snp_right);
            })
        }
        
        if !followingImageView.hidden {
            var parentView: UIView?
            if !opponentImageView.hidden {
                parentView = opponentImageView;
            } else {
                parentView = avatarView;
            }
            if let parentView = parentView {
                followingImageView.snp_remakeConstraints(closure: { (make) in
                    make.width.height.equalTo(23);
                    make.bottom.equalTo(parentView);
                    make.centerX.equalTo(parentView.snp_right);
                })
            }
        }
        
        if !partnerImageView.hidden {
            partnerImageView.snp_remakeConstraints(closure: { (make) in
                make.width.height.equalTo(23);
                make.bottom.equalTo(avatarView);
                make.centerX.equalTo(avatarView.snp_right);
            })
        }
    }
    
    private func hideOwnerComponents(hide: Bool) {
        likeCountLabel.hidden = hide
        ownerExperienceLabel.hidden = hide
        ownerLikeIconImageView.hidden = hide
    }
    
    private func hideOpponentComponents(hide: Bool) {
        opponentLikeCountLabel.hidden = hide
        opponentExperienceLabel.hidden = hide
        opponentLikeIconImageView.hidden = hide
        opponentNameLabel.hidden = hide
        ownLevelDescriptionLabel.hidden = hide
    }
}

extension UIImageView {
    func circleImageView(radius: CGFloat, borderColor: UIColor, borderWith: CGFloat) {
        self.layer.cornerRadius = radius;
        self.layer.masksToBounds = true;
        self.layer.borderWidth = borderWith
        self.layer.borderColor = borderColor.CGColor;
    }
}

