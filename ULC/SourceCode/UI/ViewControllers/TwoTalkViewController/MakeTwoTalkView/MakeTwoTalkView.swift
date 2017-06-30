//
//  MakeTwoTalkView.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class MakeTwoTalkView: UIView, NibLoadableView {
    
    @IBOutlet weak var makeTwoTalkSessionView: UIView!
	@IBOutlet weak var placeholderLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
		configureViews()
    }

	func configureViews(){
		placeholderLabel.text = R.string.localizable.make_own().uppercaseString
		titleLabel.text = R.string.localizable.two_talk_with_number()
		subtitleLabel.text = R.string.localizable.choose_category()
	}
}
