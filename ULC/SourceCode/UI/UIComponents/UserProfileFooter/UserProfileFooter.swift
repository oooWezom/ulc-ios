//
//  UserProfileFooter.swift
//  ULC
//
//  Created by Alex on 6/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class UserProfileFooter: UIView, NibLoadableView, ReusableView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var gamesLabel: UILabel!
    @IBOutlet weak var streamsLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

	@IBOutlet weak var followersLabelPlaceholder: UILabel!
	@IBOutlet weak var followingLabelPlaceholder: UILabel!
	@IBOutlet weak var gamesLabelPlaceholder: UILabel!
	@IBOutlet weak var streamsLabelPlaceholder: UILabel!

    
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var gamesButton: UIButton!
    @IBOutlet weak var streamsButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var viewStartHeight = CGFloat()
    
    override func awakeFromNib() {
        super.awakeFromNib();
       
        viewStartHeight = self.height
		configureViews()
    }

	func configureViews() {
		followersLabelPlaceholder.text = R.string.localizable.followers()
		followingLabelPlaceholder.text = R.string.localizable.following()
		gamesLabelPlaceholder.text = R.string.localizable.games()
		streamsLabelPlaceholder.text = R.string.localizable.streams()
		aboutLabel.text = "\(R.string.localizable.about()):"
	}
 
    func updateViewWithModel(model: AnyObject?) {
        
        guard let user = model as? UserEntity else {
            return;
        }
        
        followersLabel.text     = user.followers.roundValueAsString()
        followingLabel.text     = user.following.roundValueAsString()
        descriptionLabel.text   = user.aboutInfo;
        gamesLabel.text         = user.totalGames.roundValueAsString()
        streamsLabel.text       = user.talks.roundValueAsString()
    }
    
    func getHeight() -> CGFloat {
        let descriptionLabelHeight = descriptionLabel.text?.heightWithConstrainedWidth(descriptionLabel.width, font: descriptionLabel.font)
        let aboutLabelHeight = aboutLabel.height
        
        return descriptionLabelHeight! - aboutLabelHeight + viewStartHeight
    }
}
