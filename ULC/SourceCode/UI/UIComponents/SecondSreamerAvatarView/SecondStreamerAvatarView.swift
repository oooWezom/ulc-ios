//
//  SecondStreamerAvatarView.swift
//  ULC
//
//  Created by Vitya on 9/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class SecondStreamerAvatarView: UIView, NibLoadableView, ReusableView, PrefferUser {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var prefferLabel: UILabel!
	@IBOutlet weak var followLabel: UILabel!
	@IBOutlet weak var reportLabel: UILabel!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var prefferImageVeiw: UIImageView!
    
    @IBOutlet weak var dropListBlaceholderView: UIView!
    @IBOutlet weak var avatarPlaceholderView: UIView!
    @IBOutlet weak var prefferPlaceholderView: UIView!
    @IBOutlet weak var followPlaceholderView: UIView!
    @IBOutlet weak var reportPlaceholderView: UIView!
    
    private var hideElements = true
    private var prefferUserFlag = false
    private let defaultCameraImage = R.image.defaulf_camera_icon();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clearColor()
        
        dropListBlaceholderView.hidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showItems))
        avatarPlaceholderView.addGestureRecognizer(tapGesture)
        
        userAvatarImageView.roundedView(true,
                                        borderColor: .whiteColor(),
                                        borderWidth: 2,
                                        cornerRadius: nil)
		configureViews()
    }

	func configureViews(){
		reportLabel.text = R.string.localizable.report()
		prefferLabel.text = R.string.localizable.preffer()
		followLabel.text = R.string.localizable.follow()
	}
    
    func setViewType(streamType: StreameType) {
        if streamType == .Streamer {
            prefferImageVeiw.image = R.image.remove_icon()
            prefferLabel.text      = R.string.localizable.remove()
        }
    }
    
    func showItems(sender: UITapGestureRecognizer) {
        hideElements = hideElements ? false : true
        
        dropListBlaceholderView.hidden = hideElements
    }
    
    func updateViewWithModel(streamer: AnyObject, isExistSecondStreamer: Bool) {
        
        guard let model = streamer as? WSStreamerEntity else {
            return;
        }
        
        userNameLabel.text = model.name
        levelLabel.text = String(model.level) + " \(R.string.localizable.level())"
        
        let stringUrl = Constants.userContentUrl + model.avatar;
        let avatarUrl = NSURL(string: stringUrl)
        userAvatarImageView.kf_setImageWithURL(avatarUrl,
                                               placeholderImage: defaultCameraImage,
                                               optionsInfo: [.BackgroundDecode],
                                               progressBlock: nil,
                                               completionHandler: nil);
    }
    
    func prefferUser(preffer: Bool) {
        prefferUserFlag = preffer
        prefferPlaceholderView.hidden = preffer
        
        if preffer {
            userAvatarImageView.roundedView(true,
                                            borderColor: UIColor(named: .LoginButtonNormal),
                                            borderWidth: 2,
                                            cornerRadius: nil)
        } else {
            userAvatarImageView.roundedView(true,
                                            borderColor: .whiteColor(),
                                            borderWidth: 2,
                                            cornerRadius: nil)
        }
    }
    
    func isUserPrefered() -> Bool {
        return prefferUserFlag
    }
}

