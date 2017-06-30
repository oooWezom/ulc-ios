//
//  LanguageTableViewCell.swift
//  ULC
//
//  Created by Vitya on 6/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class LanguageTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var selectionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None;
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        selectionImage.image = nil;
    }
}

