//
//  SearchOpponentView.swift
//  ULC
//
//  Created by Alexey on 7/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

class SearchOpponentView: UIView, NibLoadableView {

	@IBOutlet weak var searchingOpponentLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	

	override func awakeFromNib() {
		super.awakeFromNib()
        activityIndicator.startAnimating()
		layer.masksToBounds = true
		layer.cornerRadius = 10
		configureViews()
	}

	func configureViews(){
		searchingOpponentLabel.text = R.string.localizable.searching_for_opponent() //#MARK localized
		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
	}

	func updateView(width: CGFloat, height: CGFloat, center: CGPoint) {
		self.frame = CGRectMake(0, 0, width, height)
		self.center = center
        activityIndicator.center = center
	}
}
