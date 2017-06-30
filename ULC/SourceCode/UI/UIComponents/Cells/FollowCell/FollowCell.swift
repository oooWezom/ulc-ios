//
//  FollowCell.swift
//  ULC
//
//  Created by Alex on 7/4/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class FollowCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    @IBOutlet weak var userCategoryImageView: UIImageView!
    @IBOutlet weak var centerHolderView: UIView!
    @IBOutlet weak var followersMaskImageView: UIImageView!
    
    private let separatorView = UIView();
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        selectionStyle = .None;
        separatorView.backgroundColor = UIColor(named: .EventSeparatorLine);
        addSubview(separatorView);
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        userAvatarImageView.kf_cancelDownloadTask();
        userAvatarImageView.image = nil;
        
        userCategoryImageView.image = nil;
        userNameLabel.text = "";
        userLevelLabel.text = "";
    }
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let model = model as? EventBaseEntity else {
            return;
        }

        userNameLabel.text = model.name;
        userLevelLabel.text = String(model.level) + " \(R.string.localizable.level().lowercaseString)";
        
        let stringUrl = Constants.userContentUrl + model.avatar;
        let url = NSURL(string: stringUrl)!
        userAvatarImageView.kf_setImageWithURL(url,
                                               placeholderImage: R.image.default_small_avatar(),
                                               optionsInfo: [.BackgroundDecode],
                                               progressBlock: nil,
                                               completionHandler: nil);
        
        guard let userStatus = UserStatus(rawValue: model.status) else {
            userCategoryImageView.image = nil;
            return;
        }
        
        switch userStatus {
            
        case .Online:
            userCategoryImageView.image = R.image.online_status_icon();
            break;
            
        case .Talking:
            userCategoryImageView.image = R.image.talk_status_icon();
            break;
            
        case .Playing:
            userCategoryImageView.image = R.image.play_status_icon();
            break;
            
        default:
            userCategoryImageView.image = nil;
            break;
        }
    }
    
    func setCellBackgroundColor(color: UIColor) {
        self.backgroundColor = color
        centerHolderView.backgroundColor = color
        followersMaskImageView.image = R.image.mask_followers_grey()
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        separatorView.snp_remakeConstraints { (make) in
            make.height.equalTo(1);
            make.right.equalTo(0);
            make.bottom.equalTo(0);
            make.left.equalTo(userAvatarImageView.snp_right).offset(3);
        }
    }
}
