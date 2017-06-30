//
//  FilterTwoPlayView.swift
//  ULC
//
//  Created by Alexey on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class MakeTwoPlayView: UIView, NibLoadableView {
    
    @IBOutlet weak var makeTwoPlaySessionView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var placeholderLabel: UILabel!
    
	override func awakeFromNib() {
		super.awakeFromNib()
		configureViews()
	}

	func configureViews(){
		placeholderLabel.text = R.string.localizable.make_own().uppercaseString
		titleLabel.text = R.string.localizable.two_play_session_with_number()
		subtitleLabel.text = R.string.localizable.choose_game()
	}
}
