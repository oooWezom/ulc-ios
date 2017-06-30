//
//  TwoPlayActiveGameView.swift
//  ULC
//
//  Created by Alexey on 11/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class TwoPlayActiveGameView:UIView, ReusableView, NibLoadableView{

    @IBOutlet weak var leftPlayerPreviewImageView: UIImageView!
    @IBOutlet weak var rightPlayerPreviewImageView: UIImageView!
    @IBOutlet weak var leftPlayerAvatarImageView: UIImageView!
    @IBOutlet weak var rightPlayerAvatarImageView: UIImageView!
    @IBOutlet weak var leftPlayerUsernameLabel: UILabel!
    @IBOutlet weak var rightPlayerUsernameLabel: UILabel!
    @IBOutlet weak var leftPlayerLevelLabel: UILabel!
    @IBOutlet weak var rightPlayerLevelLabel: UILabel!
    @IBOutlet weak var gameTypeImageView: UIImageView!
    @IBOutlet weak var likesCountImageView: UIImageView!
    @IBOutlet weak var spectatorsCountImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var spectatorsCountLabel: UILabel!
    @IBOutlet weak var gameTypeTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
 
}
