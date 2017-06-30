//
//  SettingSwitchCell.swift
//  ULC
//
//  Created by Vitya on 7/21/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol SettingSwitchCellDelegate : class {
    func didChangeSwitchState(sender: SettingSwitchCell, isOn: Bool)
}

enum SettingSwitchCellId {
    case PrivateAccount
    case PushNotificztion
}

class SettingSwitchCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    @IBAction func handledSwitchChange(sender: AnyObject) {
        self.cellDelegate?.didChangeSwitchState(self, isOn: settingSwitch.on)
    }
    
    weak var cellDelegate: SettingSwitchCellDelegate?
    
    var id: SettingSwitchCellId = .PrivateAccount
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingSwitch.onTintColor = UIColor(named: .NavigationBarColor)
    }
    
    func setAccountStatus(statusId: Int) {
        settingSwitch.on = statusId == AccountStatus.Private.rawValue ? true : false
    }
    
    func setNotificationStatus(set: Bool) {
        settingSwitch.on = set
    }
    
    func updateVeiwWithData(settingName: String, id: SettingSwitchCellId, switchStatus: Int?) {
        selectionStyle = .None
        settingNameLabel.text = settingName
        self.id = id
        
        if id == .PrivateAccount, let switchStatus = switchStatus {
            setAccountStatus(switchStatus)
        }
        
        if id == .PushNotificztion {
            setNotificationStatus(NSUserDefaults.standardUserDefaults().boolForKey(Constants.localNotificationKey));
        }
        
    }
    
}
