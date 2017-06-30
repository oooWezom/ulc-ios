//
//  SettingHeaderView.swift
//  ULC
//
//  Created by Vitya on 7/21/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class SettingHeaderView: UIView, NibLoadableView, ReusableView {

    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        backgroundColor = UIColor(named: .EventSeparatorLine)
        headerNameLabel.text = ""
        descriptionLabel.text = ""
    }
}
