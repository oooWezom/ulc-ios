//
//  MenuCell.swift
//  ULC
//
//  Created by Alex on 6/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import QuartzCore

class MenuCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .None
        
        countLabel.textColor = UIColor.whiteColor();
        countLabel.backgroundColor = UIColor.redColor();
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        countLabel.text = "";
        countLabel.hidden = true;
    }
    
    func ubdateLabelCount(count: Int) {

        if count == 0 {
            countLabel.hidden = true
        } else {
            
            var userCounters = String(count)
            
            if count > 999_999_999 {
                let roundCounts = count.roundDivision(1000_000_000)
                userCounters = String(roundCounts) + "b"
            } else if count > 999_999 {
                let roundCounts = count.roundDivision(1000_000)
                userCounters = String(roundCounts) + "m"
            } else if count > 999 {
                let roundCounts = count.roundDivision(1000)
                userCounters = String(roundCounts) + "k"
            }
            
            countLabel.text = String(userCounters)
            countLabel.hidden = false
        }
        
        setNeedsUpdateConstraints();
    }
    
    override func updateConstraints() {
        super.updateConstraints();
        
        if !countLabel.hidden {
            
            if let labelWidth = countLabel?.intrinsicContentSize().width where labelWidth > 25 {
                
                countLabel.snp_updateConstraints(closure: { (make) in
                    make.width.equalTo(labelWidth)
                })
                
            } else {
                
                countLabel.snp_updateConstraints(closure: { (make) in
                    make.width.equalTo(25)
                })
            }
            countLabel.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: 12.5);
        }
    }
}
