//
//  TwoTalkCollectionViewCell.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

class TwoTalkTwoStreamersCell: UICollectionViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet weak var firstUserPreviewImageView: UIImageView!
    @IBOutlet weak var firstUserAvatarImageVeiw: UIImageView!
    @IBOutlet weak var firstUsernameLabel: UILabel!
    @IBOutlet weak var firstUserLevelLabel: UILabel!
    
    @IBOutlet weak var secondUserPreviewImageView: UIImageView!
    @IBOutlet weak var secondUserAvatarImageView: UIImageView!
    @IBOutlet weak var secondUsernameLabel: UILabel!
    @IBOutlet weak var secondUserLevelLabel: UILabel!
    
    @IBOutlet weak var talkCategoryIconImageView: UIImageView!
    @IBOutlet weak var talkNameLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var spectatorsCountLabel: UILabel!
    
    //Mark - Private properties
    private var talkCategory = [TalkCategory]()
    
    private var categoryViewModel = CategoryViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    func configureView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        
        firstUserPreviewImageView.clipsToBounds = true
        secondUserPreviewImageView.clipsToBounds = true
        
        firstUserPreviewImageView.backgroundColor = UIColor.blackColor()
        secondUserPreviewImageView.backgroundColor = UIColor.blackColor()
        
        firstUserAvatarImageVeiw.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil);
        secondUserAvatarImageView.roundedView(true, borderColor: UIColor.whiteColor(), borderWidth: 2.0, cornerRadius: nil);
    }
    
    func updateViewWithModel(model: AnyObject) {
        guard let model = model as? TalkSessionsResponseEntity else {
            return;
        }
        
        guard let firstStreamer = model.streamer else {
            return
        }
        
        likesCountLabel.text = model.likes.roundValueAsString()
        spectatorsCountLabel.text = model.spectators.roundValueAsString()
        
        if let stringURL = categoryViewModel.fetchColorCategoryAvatarURL(model.category) {
            let talkCategoryIconURL = NSURL(string: stringURL)
            self.talkCategoryIconImageView.kf_setImageWithURL(talkCategoryIconURL,
                                                 placeholderImage: nil,
                                                 optionsInfo: [.BackgroundDecode],
                                                 progressBlock: nil,
                                                 completionHandler: nil);
            self.talkNameLabel.text = categoryViewModel.fetchCategoryName(model.category)
        }
        
        //MARK:- first streamer data
        firstUsernameLabel.text = firstStreamer.name
        firstUserLevelLabel.text = String(firstStreamer.level) + " \(R.string.localizable.lvl())"
        
        let firstStringAvatarUrl = firstStreamer.avatar;
        let firstAvatarImageCache = ImageCache.defaultCache;
        let firstAvatarURL = NSURL(string: Constants.userContentUrl + firstStringAvatarUrl)!;
        let firstAvatarResource = Resource(downloadURL: firstAvatarURL, cacheKey: firstStringAvatarUrl)
        
        firstUserAvatarImageVeiw.kf_setImageWithResource(firstAvatarResource,
                                                         placeholderImage: R.image.defaulf_camera_icon(),
                                                         optionsInfo: [.BackgroundDecode],
                                                         progressBlock: nil,
                                                         completionHandler: { (image, error, cacheType, imageURL) in
                                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                                                if let image = image {
                                                                    firstAvatarImageCache.storeImage(image, originalData: nil, forKey: firstStringAvatarUrl, toDisk: true, completionHandler: nil);
                                                                }
                                                        })
        })
        
        
        let firstUserstringUrl = String(model.id)
        let firstUserPreviewURL = NSURL(string: Constants.userTalkPreviewUrl + firstUserstringUrl + ".jpg")!;
        
        firstUserPreviewImageView.kf_setImageWithURL(firstUserPreviewURL,
                                                     placeholderImage: nil,
                                                     optionsInfo: [.ForceRefresh],
                                                     progressBlock: nil,
                                                     completionHandler: nil);
        
        //MARK:- second streamer data
        guard let secondStreamer = model.linked?.first?.streamer else {
            return
        }
        
        secondUsernameLabel.text = secondStreamer.name
        secondUserLevelLabel.text = String(secondStreamer.level) + " \(R.string.localizable.lvl())" //#MARK localize
        
        let secondStringAvatarUrl = secondStreamer.avatar;
        let secondAvatarImageCache = ImageCache.defaultCache;
        let secondAvatarURL = NSURL(string: Constants.userContentUrl + secondStringAvatarUrl)!;
        let secondAvatarResource = Resource(downloadURL: secondAvatarURL, cacheKey: secondStringAvatarUrl)
        
        secondUserAvatarImageView.kf_setImageWithResource(secondAvatarResource,
                                                          placeholderImage: R.image.defaulf_camera_icon(),
                                                          optionsInfo: [.BackgroundDecode],
                                                          progressBlock: nil,
                                                          completionHandler: { (image, error, cacheType, imageURL) in
                                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                                                if let image = image {
                                                                    secondAvatarImageCache.storeImage(image, originalData: nil, forKey: secondStringAvatarUrl, toDisk: true, completionHandler: nil);
                                                                }
                                                            })
        })
        
        if let secondUserStringUrl = model.linked?.first?.id {
            
            let secondUserPreviewURL = NSURL(string: Constants.userTalkPreviewUrl + String(secondUserStringUrl) + ".jpg")!;
            secondUserPreviewImageView.kf_setImageWithURL(secondUserPreviewURL,
                                                          placeholderImage: nil,
                                                          optionsInfo: [.ForceRefresh],
                                                          progressBlock: nil,
                                                          completionHandler: nil);
        }
    }
}
