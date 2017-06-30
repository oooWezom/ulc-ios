//
//  FilterTwoTalkView.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol FilterTwoTalkDelegate: class {
    func allSessionsClick()
    func followSessionsClick()
}

class FilterTwoTalkView: UIView, NibLoadableView {
    
    weak var delegate: FilterTwoTalkDelegate?
    
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
        configureView()
    }

	func configureView(){
		allSessionButton.setTitle(R.string.localizable.all_sessions(), forState: .Normal)
		followingSessionButton.setTitle(R.string.localizable.following_sessions(), forState: .Normal)
	}
}
