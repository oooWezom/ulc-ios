//
//  SessionInfoCell.swift
//  ULC
//
//  Created by Alex on 9/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

protocol SessionProtocolInfoable: class {
    func openChatWithUser(cell: SessionInfoCell);
    func followUser(cell: SessionInfoCell);
}

class SessionInfoCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
	@IBOutlet weak var followLabel: UILabel!
	@IBOutlet weak var chatLabel: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    weak var delegate:SessionProtocolInfoable?
    
    private let viewModel = GeneralViewModel();
    
    override func prepareForReuse() {
        super.prepareForReuse();
        avatarImageView.image = nil;
        
        let selectedView = UIView();
        selectedView.backgroundColor = UIColor.clearColor();
        selectedBackgroundView = selectedView;
    }
    
    @IBAction func followUser(sender: AnyObject) {
        delegate?.followUser(self);
    }
    
    @IBAction func startChating(sender: AnyObject) {
        delegate?.openChatWithUser(self);
    }
    
    func updateViewWithModel(model: AnyObject?) {

		// MARK hide follow by default
		followButton.hidden = true;
		followLabel.hidden = true
        
        guard let owner = model as? Owner else {
            return;
        }
        
        userNameLabel.text = owner.name;
        levelLabel.text = String(owner.level) +  " \(R.string.localizable.level().lowercaseString)"; //#MARK localized
        
        if !owner.avatar.isEmpty {
            avatarImageView.kf_setImageWithURL(NSURL(string: Constants.userContentUrl + owner.avatar),
                                               placeholderImage: R.image.circle_mask_icon(),
                                               optionsInfo: [.BackgroundDecode],
                                               progressBlock: nil,
                                               completionHandler: nil);
        }
        
        switch owner.status {
            
        case UserStatus.Online.rawValue:
            statusImageView.image = R.image.online_status_icon();
            break;
            
        case UserStatus.Talking.rawValue:
            statusImageView.image = R.image.talk_status_icon();
            break;
            
        case UserStatus.Playing.rawValue:
            statusImageView.image = R.image.play_status_icon();
            break;
            
        default:
            statusImageView.image = nil;
            break;
        }
        
        if owner.id == 0 || owner.id == viewModel.currentId {
			// followButton.hidden = true;
			// followLabel.hidden = true

			chatLabel.hidden = true
            chatButton.hidden = true;
        } else {
            //followButton.hidden = false;
			//followLabel.hidden = false

			chatLabel.hidden = false
            chatButton.hidden = false;

			/*
            if owner.link == 1 {
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.followButton.imageView?.image = R.image.unfollow_session_icon()
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.followButton.imageView?.image = R.image.follow_session_icon()
                })
            }
			*/
        }
    }
}
