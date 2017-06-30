//
//  SettingSegmentControlCell.swift
//  ULC
//
//  Created by Vitya on 7/26/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol SettingSegmentControlCellDelegate : class {
    func didChangeSegmentControlState(sender: SettingSegmentControlCell, sex: Int)
}

class SettingSegmentControlCell: UITableViewCell, ReusableView, NibLoadableView  {
    
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!
    
    @IBAction func sexSegmentControlAction(sender: AnyObject) {
        let sexId = sender.selectedSegmentIndex == 0 ? 2 : 1
        self.cellDelegate?.didChangeSegmentControlState(self, sex: sexId)
    }
    
    weak var cellDelegate: SettingSegmentControlCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sexSegmentedControl.tintColor = UIColor(named: .NavigationBarColor)
		configureViews()
    }

	func configureViews(){
		sexSegmentedControl.setTitle(R.string.localizable.male(), forSegmentAtIndex: 0)
		sexSegmentedControl.setTitle(R.string.localizable.female(), forSegmentAtIndex: 1)
	}
    
    func setUserSex(sex: Int) {
        sexSegmentedControl.selectedSegmentIndex = sex == 1 ? 1 : 0
    }
}
