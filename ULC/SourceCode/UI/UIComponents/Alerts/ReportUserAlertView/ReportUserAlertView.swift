//
//  ReportUserAlertView.swift
//  ULC
//
//  Created by Vitya on 7/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ReportUserAlertView: UIView, NibLoadableView, UITextViewDelegate {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
	@IBOutlet weak var reportLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
        configureView()
    }
    
    func configureView() {
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.borderWidth = 2
        userAvatarImageView.layer.borderColor = UIColor(named: .NavigationBarColor).CGColor
        
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        messageTextView.delegate = self
        
        hideKeyboardWhenTappedAround()

		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)//#MARK localized
		sendButton.setTitle(R.string.localizable.send(), forState: .Normal)
		reportLabel.text = R.string.localizable.report()
    }
    
    func setFocusOnTextView() {
        messageTextView.text = ""
        messageTextView.becomeFirstResponder()
    }

    func updateViewWithModel(model: AnyObject?) {
        guard let userEntity = model as? UserEntity else {
            return;
        }
            
            let stringUrl = userEntity.avatar;
            let imageCache = ImageCache.defaultCache;
            let avatarURL = NSURL(string: Constants.userContentUrl + stringUrl)!;
            let resource = Resource(downloadURL: avatarURL, cacheKey: stringUrl)
            
            userAvatarImageView.kf_setImageWithResource(resource,
                                                    placeholderImage: R.image.default_small_avatar(),
                                                    optionsInfo: [.BackgroundDecode],
                                                    progressBlock: nil,
                                                    completionHandler: { (image, error, cacheType, imageURL) in
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                                            if let image = image {
                                                                imageCache.storeImage(image, originalData: nil, forKey: stringUrl, toDisk: true, completionHandler: nil);
                                                            }
                                                    })
            })
        
    }
    
    // MARK delegate methods
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
