//
//  UserMenuCell.swift
//  ULC
//
//  Created by Alex on 6/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import RealmSwift
import ReactiveCocoa
import Kingfisher

protocol AvatarMenuChangeable: class {
    func openAvatarMenuDialog();
}

class UserMenuCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: AvatarMenuChangeable?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        avatarImageView.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil)
    }
    
    func updateViewWithModel(model: AnyObject?) {
        guard let userEntity = model as? UserEntity else {
            return;
        }
        
        self.nameLabel.text = userEntity.name
        if !userEntity.avatar.isEmpty {
            let url = NSURL(string: Constants.userContentUrl + userEntity.avatar);
            if let url = url {
                self.avatarImageView.kf_setImageWithURL(url, placeholderImage: R.image.mini_avatar_icon(), optionsInfo: nil, progressBlock: nil, completionHandler: nil);
            }
        }
    }
    
    @IBAction func changePhotoAction(sender: AnyObject) {
        delegate?.openAvatarMenuDialog();
    }
}
