//
//  UserOptionTableViewCell.swift
//  ULC
//
//  Created by Alexey on 10/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class UserOptionTableViewCell: UITableViewCell, ReusableView, NibLoadableView  {
    
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    
    var position:Position               = .Left

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        self.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: titleLabel.font.fontName, size: 11)
    }
    
    func updateWithData(data:AnyObject){
        guard let data = data as? Dictionary<UIImage, String> else{return}
        Swift.debugPrint(data)
        iconImageView.image = data.first?.0
        titleLabel.text = data.first?.1
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if position == .Right{
            titleLabel.textAlignment = .Right
            
            iconImageView.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(self)
                make.width.height.equalTo(self.snp_height).multipliedBy(0.7)
                make.centerY.equalTo(self)
            }
            
            titleLabel.snp_remakeConstraints {
                (make) -> Void in
                make.right.equalTo(iconImageView.snp_left)
                make.centerY.equalTo(iconImageView)
                make.left.equalTo(self)
            }

        } else {
            titleLabel.textAlignment = .Left
            iconImageView.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(self)
                make.width.height.equalTo(self.snp_height).multipliedBy(0.7)
                make.centerY.equalTo(self)
            }
            
            
            titleLabel.snp_remakeConstraints {
                (make) -> Void in
                make.left.equalTo(iconImageView.snp_right)
                make.centerY.equalTo(iconImageView)
                make.right.equalTo(self)
            }
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
