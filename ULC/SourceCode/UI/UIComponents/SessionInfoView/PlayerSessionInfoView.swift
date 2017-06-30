//
//  PlayerSessionInfoView.swift
//  ULC
//
//  Created by Alex on 9/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class PlayerSessionInfoView: UIView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var ownerVideoPreviewImageView: UIImageView!
    @IBOutlet weak var ownerAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        ownerAvatarImageView.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil);
    }
    
    func updateViewWithModel(model: AnyObject?) {
        guard let owner = model as? Owner else {
            return;
        }
        
        userNameLabel.text = owner.name;
        userLevelLabel.text = String("\(owner.level) \(R.string.localizable.level())");
        
        ownerAvatarImageView.kf_setImageWithURL(NSURL(string: Constants.userContentUrl + owner.avatar),
                                                placeholderImage: R.image.mini_avatar_icon(),
                                                optionsInfo: [.BackgroundDecode],
                                                progressBlock: nil,
                                                completionHandler: nil);
        ownerVideoPreviewImageView.image = UIImage.fromColor(UIColor.blackColor());
    }
}
