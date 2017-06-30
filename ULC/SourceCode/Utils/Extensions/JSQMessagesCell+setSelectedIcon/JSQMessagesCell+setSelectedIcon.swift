//
//  ISCustomMediaMessageCell.swift
//  ULC
//
//  Created by Vitya on 8/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import JSQMessagesViewController

extension JSQMessagesCollectionViewCell {

    func setSelectedIcon(image: UIImage?) {
        messageBubbleImageView.subviews.forEach({ $0.removeFromSuperview() })
        
        let selectedIconImageView = UIImageView(image: image)
        messageBubbleImageView.addSubview(selectedIconImageView)
        
        selectedIconImageView.snp_remakeConstraints(closure: { (make) in
            make.width.height.equalTo(15)
            make.bottom.equalTo(messageBubbleImageView.snp_bottom)
            make.right.equalTo(messageBubbleImageView.snp_right).offset(-10)
        })
    }
}
