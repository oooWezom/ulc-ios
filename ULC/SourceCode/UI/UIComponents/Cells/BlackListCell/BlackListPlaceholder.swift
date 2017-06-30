//
//  BlackListPlaceholder.swift
//  ULC
//
//  Created by Vitya on 7/28/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class BlackListPlaceholder {
    
    func emptyMessage(message:String, viewController:UITableViewController) {
        
        let messageLabel        = UILabel(frame: CGRectMake(0,0,viewController.view.bounds.size.width, viewController.view.bounds.size.height))
        messageLabel.text       = message
        messageLabel.textColor  = UIColor.blackColor()
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .Center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        viewController.tableView.separatorStyle = .None;
    }
}
