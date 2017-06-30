//
//  2PlayTableViewCell.swift
//  ULC
//
//  Created by Alexey on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

class TwoPlayTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var firstUserAvatar: UIImageView!
	@IBOutlet weak var secondUserAvatar: UIImageView!
	@IBOutlet weak var gameTypeImageView: UIImageView!
	@IBOutlet weak var firstPlayerUsername: UILabel!
	@IBOutlet weak var secondPlayerUsername: UILabel!
	@IBOutlet weak var firstPlayerLevel: UILabel!
	@IBOutlet weak var secondPlayerLevel: UILabel!
	@IBOutlet weak var currentGameLabel: UILabel!
	@IBOutlet weak var likesCount: UILabel!
	@IBOutlet weak var followersCountLabel: UILabel!

	@IBOutlet weak var firstPlayerImagePlaceholder: UIImageView!
	@IBOutlet weak var secondPlayerImagePlaceholder: UIImageView!
    
    private let defaultAvatarImage = R.image.default_small_avatar();
    
    var gameEntity:GameSessionsEntity?

	override func awakeFromNib() {
		super.awakeFromNib()
        
        mainView.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: 10.0);
        
		firstPlayerImagePlaceholder.clipsToBounds = true
        secondPlayerImagePlaceholder.clipsToBounds = true;
        
        firstUserAvatar.roundedView(true, borderColor: UIColor.blackColor(), borderWidth: 2.0, cornerRadius: nil);
        secondUserAvatar.roundedView(true, borderColor: UIColor.blackColor(), borderWidth: 2.0, cornerRadius: nil);
        gameTypeImageView.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: nil);
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstUserAvatar.image               = nil
        secondUserAvatar.image              = nil
        gameTypeImageView.image             = nil
        firstPlayerUsername.text            = ""
        secondPlayerUsername.text           = ""
        firstPlayerLevel.text               = ""
        secondPlayerLevel.text              = ""
        currentGameLabel.text               = ""
        likesCount.text                     = ""
        followersCountLabel.text            = ""
        firstPlayerImagePlaceholder.image   = nil
        secondPlayerImagePlaceholder.image  = nil
    }

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func updateViewWithModel(model: AnyObject?) {
		guard let model = model as? GameSessionsEntity else {
			return;
		}
        
        gameEntity = model

		if let firstPlayer = model.players.first {
			var stringUrl: String = ""
			var fPlayerId = 0
            stringUrl = Constants.userContentUrl + firstPlayer.avatar
            fPlayerId = firstPlayer.id

			let url = NSURL(string: stringUrl)!

			let previewUrl = NSURL(string: Constants.BASE_URL + "preview/" + videoPreviewPattern(model.id, playerID: fPlayerId))!

			firstUserAvatar.kf_setImageWithURL(url,
			                                   placeholderImage: R.image.default_small_avatar(),
			                                   optionsInfo: [.BackgroundDecode],
			                                   progressBlock: nil,
			                                   completionHandler: nil);
            
            let tmpPlaceholderPreview =  secondPlayerImagePlaceholder.image
            
			firstPlayerImagePlaceholder.kf_setImageWithURL(previewUrl, placeholderImage: tmpPlaceholderPreview, optionsInfo: [.ForceRefresh]);

			firstPlayerUsername.text = firstPlayer.name
            firstPlayerLevel.text = String(firstPlayer.level) + " lvl"
		}

		if let secondPlayer = model.players.last {
			var stringUrl: String = ""
			var sPlayerId = 0
            stringUrl = Constants.userContentUrl + secondPlayer.avatar
			let url = NSURL(string: stringUrl)!
            sPlayerId = secondPlayer.id

			let previewUrl = NSURL(string: Constants.BASE_URL + "preview/" + videoPreviewPattern(model.id, playerID: sPlayerId))!

			secondUserAvatar.kf_setImageWithURL(url,
			                                    placeholderImage: defaultAvatarImage,
			                                    optionsInfo: [.BackgroundDecode],
			                                    progressBlock: nil,
			                                    completionHandler: nil);
            
            let tmpPlaceholderPreview =  secondPlayerImagePlaceholder.image
            
			secondPlayerImagePlaceholder.kf_setImageWithURL(previewUrl,
			                                                placeholderImage: tmpPlaceholderPreview,
			                                                optionsInfo: [.ForceRefresh]);
            
			secondPlayerUsername.text = secondPlayer.name

            secondPlayerLevel.text = String(secondPlayer.level) + " lvl"
		}
		var gameImage = UIImage()

			switch model.game {
			case GameID.RANDOM.rawValue:
				if let image = R.image.choise_random() {
					gameImage = image
				}
				break
			case GameID.X_COWS.rawValue:
				if let image = R.image.choise_x_cows() {
					gameImage = image
				}
				break

			case GameID.LAND_IT.rawValue:
				if let image = R.image.choise_land_it() {
					gameImage = image
				}
				break

			case GameID.ROCK_SPOCK.rawValue:
				if let image = R.image.choise_rock() {
					gameImage = image
				}
				break

			case GameID.MATH2.rawValue:
				if let image = R.image.choise_math() {
					gameImage = image
				}
				break

			case GameID.SPIN_THE_DISKS.rawValue:
				currentGameLabel.text = "Spin the discs"
				if let image = R.image.choise_spin_disk() {
					gameImage = image
				}
				break

			default:
				if let image = R.image.choise_random() {
					gameImage = image
				}
				break
			}

		gameTypeImageView.image = gameImage

		likesCount.text = "0"
        if let spectators = gameEntity?.spectators{
            followersCountLabel.text = "\(spectators)"
        }
	}

	func roundedImageView(imageView: UIImageView, withBorder: Bool) {
		if withBorder {
			imageView.layer.borderWidth = 2.0
			imageView.layer.borderColor = UIColor.whiteColor().CGColor
		} else {
			imageView.layer.borderWidth = 2.0
		}
		imageView.layer.masksToBounds = false
		imageView.layer.cornerRadius = imageView.frame.size.width / 2
		imageView.clipsToBounds = true
	}
}
