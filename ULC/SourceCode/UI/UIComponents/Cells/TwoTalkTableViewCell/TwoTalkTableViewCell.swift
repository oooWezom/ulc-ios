//
//  TwoTalkTableViewCell.swift
//  ULC
//
//  Created by Vitya on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class TwoTalkTableViewCell: UICollectionViewCell, ReusableView, NibLoadableView  {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var circleMaskImageView: UIImageView!
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    func updateViewWithModel(model: AnyObject?) {
        guard let talkCategoryEntity = model as? TalkCategory else {
            return
        }
        
        circleMaskImageView.hidden = true
        categoryNameLabel.text = talkCategoryEntity.name
        
        var url: NSURL?
        
        if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
            url = NSURL(string: Constants.smallTalkCategoryIconUrl + talkCategoryEntity.icon)
        } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
            url = NSURL(string: Constants.threeXsmallTalkCategoryIconUrl + talkCategoryEntity.icon)
        }
        if let url = url {
            categoryImageView.kf_setImageWithURL(url,
                                                 placeholderImage: nil,
                                                 optionsInfo: [.BackgroundDecode],
                                                 progressBlock: nil,
                                                 completionHandler: nil);
        }
    }
}
