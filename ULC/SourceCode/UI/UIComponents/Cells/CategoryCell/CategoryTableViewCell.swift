//
//  CategoryTableViewCell.swift
//  ULC
//
//  Created by Vitya on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var cateGoryNameImageView: UILabel!
    
    func updateViewWithModel(model: AnyObject?) {
        
        guard let talkCategoryEntity = model as? TalkCategory else {
            return;
        }
        
        cateGoryNameImageView.text = talkCategoryEntity.name
        
        var url: NSURL?
        
        if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
            url = NSURL(string: Constants.smallTalkCategoryIconUrl + talkCategoryEntity.icon)
        } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
            url = NSURL(string: Constants.threeXsmallTalkCategoryIconUrl + talkCategoryEntity.icon)
        }
        
        if let url = url {
            categoryImageView.kf_setImageWithURL(url, placeholderImage: nil, optionsInfo: [.BackgroundDecode], progressBlock: nil, completionHandler: nil);
        }
    }
}
