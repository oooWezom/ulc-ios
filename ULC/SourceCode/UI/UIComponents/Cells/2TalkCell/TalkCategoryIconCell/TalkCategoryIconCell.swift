//
//  TalkCategoryIconCell.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class TalkCategoryIconCell: UICollectionViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var talkCategoryIconImageView: UIImageView!
    @IBOutlet weak var roundIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundIconImageView.hidden = true
    }
    
    func updateViewWithModel(model: AnyObject?) {
        guard let talkCategoryEntity = model as? TalkCategory else {
            return;
        }

        var url: NSURL?
        
        if UIScreen.mainScreen().scale == ScreanScale.TwoX.rawValue {
            url = NSURL(string: Constants.smallTalkCategoryIconUrl + talkCategoryEntity.icon)
        } else if UIScreen.mainScreen().scale == ScreanScale.TreeX.rawValue {
            url = NSURL(string: Constants.threeXsmallTalkCategoryIconUrl + talkCategoryEntity.icon)
        }
        
        if let url = url {
            talkCategoryIconImageView.kf_setImageWithURL(url,
                                                         placeholderImage: nil,
                                                         optionsInfo: [.BackgroundDecode],
                                                         progressBlock: nil,
                                                         completionHandler: nil);
        }
    }

}
