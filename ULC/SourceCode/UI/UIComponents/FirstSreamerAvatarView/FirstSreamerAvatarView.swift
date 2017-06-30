//
//  FirstSreamerAvatarView.swift
//  ULC
//
//  Created by Vitya on 9/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol PrefferUser {
    func isUserPrefered() -> Bool
}

enum PreferredStreamer: Int {
    case LeftStreamer
    case RightStreamer
}

enum StreameType: Int {
    case Streamer
    case Spectator
}

class FirstSreamerAvatarView: UIView, NibLoadableView, ReusableView, PrefferUser  {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var prefferLabel: UILabel!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var prefferImageVeiw: UIImageView!

    @IBOutlet weak var dropListBlaceholderView: UIView!
    @IBOutlet weak var avatarPlaceholderView: UIView!
    @IBOutlet weak var prefferPlaceholderView: UIView!
    @IBOutlet weak var followPlaceholderView: UIView!
    @IBOutlet weak var reportPlaceholderView: UIView!
    
	@IBOutlet weak var reportLabel: UILabel!
	@IBOutlet weak var followLabel: UILabel!
    private var hideElements = true
    private var prefferUserFlag = false
    private var streamType = StreameType.Spectator
    private let defaultCameraImage = R.image.defaulf_camera_icon();
    
    @IBOutlet weak var switchCameraButton: UIButton!
    
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

	func configureViews() {
		prefferLabel.text = R.string.localizable.preffer()
		reportLabel.text = R.string.localizable.report()
		followLabel.text = R.string.localizable.follow()

	}
    
    func setViewType(streamType: StreameType) {
        if streamType == .Streamer {
            prefferImageVeiw.image = R.image.remove_icon()
            prefferLabel.text      = R.string.localizable.remove() //#MARK localized
            dropListBlaceholderView.hidden = true
        }
        
        self.streamType = streamType
    }
    
    func showItems(sender: UITapGestureRecognizer) {
        if streamType == .Spectator {
            dropListBlaceholderView.hidden = hideElements
            hideElements = hideElements ? false : true
        } else {
            switchCameraButton.hidden = !switchCameraButton.hidden
        }
    }
    
    func updateViewWithModel(model: AnyObject) {
        
        guard let streamer = model as? WSStreamerEntity else {
            return
        }
        
        userNameLabel.text = streamer.name
        levelLabel.text = String(streamer.level) + " \(R.string.localizable.level())"
        
        let stringUrl = Constants.userContentUrl + streamer.avatar;
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
