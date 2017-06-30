//
//  TwoPlayViewCell.swift
//  ULC
//
//  Created by Alexey on 11/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class TwoPlayViewCell: UITableViewCell,ReusableView, NibLoadableView {
    
    var gameEntity:GameSessionsEntity?
    
     var mainView = TwoPlayActiveGameView.instanciateFromNib()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(mainView)
        
        mainView.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: 10.0);
        
        mainView.leftPlayerPreviewImageView.clipsToBounds = true
        mainView.rightPlayerPreviewImageView.clipsToBounds = true
        
        mainView.snp_makeConstraints{
            (make) -> Void in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(-5)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mainView.gameTypeImageView.image            = nil
        mainView.gameTypeTitleLabel.text            = ""
        mainView.leftPlayerAvatarImageView.image    = nil
        mainView.leftPlayerLevelLabel.text          = ""
        mainView.leftPlayerPreviewImageView.image   = nil
        mainView.leftPlayerUsernameLabel.text       = nil
        mainView.likesCountLabel.text               = "0"
        mainView.rightPlayerAvatarImageView.image   = nil
        mainView.rightPlayerLevelLabel.text         = ""
        mainView.rightPlayerPreviewImageView.image  = nil
        mainView.rightPlayerUsernameLabel.text      = ""
        mainView.spectatorsCountLabel.text          = ""
    }
    
    func updateViewWithModel(model: AnyObject?) {
        guard let model = model as? GameSessionsEntity else {
            return;
        }
        
        gameEntity = model
        
        updateLeftPlayer(model.players[0]);
        updateRightPlayer(model.players[1]);
        
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
            mainView.gameTypeTitleLabel.text = "Spin the discs"
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

		mainView.likesCountLabel.text = "0"
        
        mainView.gameTypeImageView.image = gameImage.circle(0, borderColor: .whiteColor())
        
        if let spectators = gameEntity?.spectators{
            mainView.spectatorsCountLabel.text = "\(spectators)"
        }
    }
    
    func updateLeftPlayer(entity:WSPlayerEntity?){
        if let entity = entity{
            let avatarURL = NSURL(string: Constants.userContentUrl + entity.avatar)
            let surfacePreviewURL = NSURL(string: "\(Constants.BASE_URL + "preview/" + videoPreviewPattern(gameEntity!.id, playerID: entity.id))")

            KingfisherManager.sharedManager.retrieveImageWithURL(avatarURL!, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageURL) -> () in
                if let image = image{
                    self.mainView.leftPlayerAvatarImageView.image = image.resize(200).circle(10, borderColor: UIColor.whiteColor())
                }
            })
            
            mainView.leftPlayerPreviewImageView.kf_setImageWithURL(surfacePreviewURL,
                                                                   placeholderImage: mainView.leftPlayerPreviewImageView.image,
                                                                   optionsInfo: [.ForceRefresh]);
            
            mainView.leftPlayerUsernameLabel.text = "\(entity.name)"
            mainView.leftPlayerLevelLabel.text = "\(entity.level) \(R.string.localizable.lvl())"
        }
    }
    
    func updateRightPlayer(entity:WSPlayerEntity?){
        if let entity = entity{
            let avatarURL = NSURL(string:Constants.userContentUrl + entity.avatar)
            let surfacePreviewURL = NSURL(string: "\(Constants.BASE_URL + "preview/" + videoPreviewPattern(gameEntity!.id, playerID: entity.id))")
            
            KingfisherManager.sharedManager.retrieveImageWithURL(avatarURL!, optionsInfo: nil, progressBlock: nil, completionHandler: {
                (image, error, cacheType, imageURL) -> () in
                if let image = image{
                    self.mainView.rightPlayerAvatarImageView.image = image.resize(200).circle(10, borderColor: UIColor.whiteColor())
                }
            })
            
            mainView.rightPlayerPreviewImageView.kf_setImageWithURL(surfacePreviewURL,
                                                                    placeholderImage: mainView.rightPlayerPreviewImageView.image,
                                                                    optionsInfo: [.ForceRefresh]);
            
            mainView.rightPlayerUsernameLabel.text = "\(entity.name)"
            mainView.rightPlayerLevelLabel.text = "\(entity.level) \(R.string.localizable.lvl())"
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        mainView.snp_remakeConstraints{
            (make) -> Void in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(-5)
        }
    }
    
}
