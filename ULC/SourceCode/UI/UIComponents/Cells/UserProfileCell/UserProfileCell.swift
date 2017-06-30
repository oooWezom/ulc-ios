//
//  UserProfileCell.swift
//  ULC
//
//  Created by Alex on 7/27/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class UserProfileCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var currentStatusImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        selectionStyle = .None;
        userAvatarImageView.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil);
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        userAvatarImageView.image = nil;
        currentStatusImageView.image = nil;
        userNameLabel.text = "";
        userLevelLabel.text = "";
    }
    
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let userEntity = model as? UserEntity else {
            return;
        }
        
        userNameLabel.text = userEntity.name
        userLevelLabel.text = String(userEntity.level) +  " \(R.string.localizable.level().lowercaseString)"; //#MARK localized
        
        let url = NSURL(string: Constants.userContentUrl + userEntity.avatar);
        if let url = url {
            userAvatarImageView.kf_setImageWithURL(url)
        }
        
        guard let userStatus = UserStatus(rawValue: userEntity.status) else {
            currentStatusImageView.image = nil;
            return;
        }
        
        switch userStatus {
            
        case .Online:
            currentStatusImageView.image = R.image.status_online_white_icon();
            break;
            
        case .Talking:
            currentStatusImageView.image = R.image.status_talk_white_icon();
            break;
            
        case .Playing:
            currentStatusImageView.image = R.image.status_play_white_icon();
            break;
            
        default:
            currentStatusImageView.image = nil;
            break;
        }
    }
}
