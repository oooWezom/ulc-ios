//
//  BlackListCell.swift
//  ULC
//
//  Created by Vitya on 7/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class BlackListCell: UITableViewCell, ReusableView, NibLoadableView, ReactiveBindViewProtocol {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var unblockButton: UIButton!

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
        
        unblockButton.imageView?.image = nil;
        userNameLabel.text = "";
    }
    
    func updateViewWithModel(model: AnyObject?) {

        guard let model = model as? EventBaseEntity else {
            return;
        }
        
        userNameLabel.text = model.name;
        
        let stringUrl = Constants.userContentUrl + model.avatar;
        let url = NSURL(string: stringUrl)!
        userAvatarImageView.kf_setImageWithURL(url, placeholderImage: R.image.default_small_avatar(), optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
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
