//
//  MakeTwoPlayView.swift
//  ULC
//
//  Created by Alexey on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol FilterTwoPlayDelegate {
	func allSessionsClick()
	func followSessionsClick()
}

class FilterTwoPlayView: UIView, NibLoadableView {

	var delegate: FilterTwoPlayDelegate?

	@IBOutlet weak var allSessionButton: UIButton!

	@IBOutlet weak var followingSessionButton: UIButton!

	@IBAction func allSessionsAction(sender: AnyObject) {
		delegate?.allSessionsClick()
	}

	@IBAction func followSessionsAction(sender: AnyObject) {
		delegate?.followSessionsClick()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		configureViews()
	}

	func configureViews(){
		allSessionButton.setTitle(R.string.localizable.all_sessions(), forState: .Normal)
		followingSessionButton.setTitle(R.string.localizable.following_sessions(), forState: .Normal)
	}
}
