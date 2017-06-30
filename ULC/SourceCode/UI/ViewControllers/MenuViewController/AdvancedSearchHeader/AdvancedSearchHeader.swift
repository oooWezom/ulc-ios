//
//  AdvancedSearchHeader.swift
//  ULC
//
//  Created by Alex on 7/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class AdvancedSearchHeader: UIView, NibLoadableView {
    
    @IBOutlet weak var advancedButton: UIButton!
	@IBOutlet weak var advancedSearchLabel: UILabel!
	@IBOutlet weak var searchUsersLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib();
		configureViews()
    }

	func configureViews(){
		advancedSearchLabel.text = R.string.localizable.advanced_search()
		searchUsersLabel.text = R.string.localizable.search_users()
	}
}
