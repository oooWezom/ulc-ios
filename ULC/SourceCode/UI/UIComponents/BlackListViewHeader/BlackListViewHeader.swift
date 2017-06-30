//
//  BlackListViewHeader.swift
//  ULC
//
//  Created by Vitya on 7/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class BlackListViewHeader: UIView, NibLoadableView, ReusableView {
    
    @IBOutlet weak var blackListCountLabel: UILabel!
    
    func setUsersCount(count: Int = 0) {
        
        if count == 1 {

            blackListCountLabel.text = String(count) + " \(R.string.localizable.user().lowercaseString)"
        } else {
            blackListCountLabel.text = String(count) + " \(R.string.localizable.users().lowercaseString)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(named: .EventSeparatorLine)
    }
}
