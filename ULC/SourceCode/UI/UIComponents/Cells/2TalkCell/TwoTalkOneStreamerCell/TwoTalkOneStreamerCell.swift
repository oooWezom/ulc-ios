//
//  TwoTalkTwoStreamersCell.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

class TwoTalkOneStreamerCell: UICollectionViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var userPreviewImageView: UIImageView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var talkCategoryIconImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userLevelLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var spectatorsCountLabel: UILabel!
    
    //Mark - Private properties
    private var categoryViewModel = CategoryViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    func configureView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        userPreviewImageView.clipsToBounds = true
        
        userPreviewImageView.backgroundColor = UIColor.blackColor()
        
        userAvatarImageView.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil);
    }
    
    func updateViewWithModel(model: AnyObject) {
        guard let model = model as? TalkSessionsResponseEntity else {
            return;
        }
        
        guard let streamer = model.streamer else {
            return
        }
        
        usernameLabel.text = streamer.name
        userLevelLabel.text = String(streamer.level) + " \(R.string.localizable.lvl())" //#MARK localize
        likesCountLabel.text = model.likes.roundValueAsString()
        spectatorsCountLabel.text = model.spectators.roundValueAsString()
        
        if let stringURL = categoryViewModel.fetchColorCategoryAvatarURL(model.category) {
            let talkCategoryIconURL = NSURL(string: stringURL)
            self.talkCategoryIconImageView.kf_setImageWithURL(talkCategoryIconURL,
                                                              placeholderImage: nil,
                                                              optionsInfo: [.BackgroundDecode],
                                                              progressBlock: nil,
                                                              completionHandler: nil);
            self.sessionNameLabel.text = categoryViewModel.fetchCategoryName(model.category)
        }
        
        let stringAvatarUrl = streamer.avatar;
        let imageCache = ImageCache.defaultCache;
        let avatarURL = NSURL(string: Constants.userContentUrl + stringAvatarUrl)!;
        let resourceAvatar = Resource(downloadURL: avatarURL, cacheKey: stringAvatarUrl)
        
        userAvatarImageView.kf_setImageWithResource(resourceAvatar,
                                                    placeholderImage: R.image.defaulf_camera_icon(),
                                                    optionsInfo: [.BackgroundDecode],
                                                    progressBlock: nil,
                                                    completionHandler: { (image, error, cacheType, imageURL) in
                                                        if let image = image {
                                                            dispatch_async(GCD.serialQueue(), {
                                                                imageCache.storeImage(image, originalData: nil, forKey: stringAvatarUrl, toDisk: true, completionHandler: nil);
                                                            })
                                                        }
        })
        let stringUrl = String(model.id)
        let secondUserPreviewURL = NSURL(string: Constants.userTalkPreviewUrl + String(stringUrl) + ".jpg")!;
        userPreviewImageView.kf_setImageWithURL(secondUserPreviewURL, placeholderImage: nil, optionsInfo: [.ForceRefresh], progressBlock: nil, completionHandler: nil);
    }
}
    

