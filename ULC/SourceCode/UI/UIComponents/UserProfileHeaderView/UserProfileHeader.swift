//
//  UserProfileHeader.swift
//  ULC
//
//  Created by Alex on 6/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class UserProfileHeader: UIView, NibLoadableView, UITextFieldDelegate {
    
    let photoButton = UIButton(type: .Custom);
    let userNameTextField = UITextField()
    
    private let cameraImage = R.image.camera_profile_icon();
    private let defaultAvatarImage = UIImage.fromColor(UIColor(named: .LoginButtonNormal));
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        headerImageView.image = defaultAvatarImage;
        addGradientView();
    }
    
    private func addGradientView() {
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, self.width, 37.0)
        
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4);
        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0);
        
        gradient.colors = [startColor.CGColor, endColor.CGColor]
        headerImageView.layer.insertSublayer(gradient, atIndex: 0)
        
        photoButton.setImage(cameraImage, forState: .Normal)
        photoButton.setImage(cameraImage, forState: .Highlighted)
        photoButton.setTitle("", forState: .Normal)
        photoButton.setTitle("", forState: .Highlighted)
        
        userNameTextField.delegate = self
        userNameTextField.tintColor = UIColor(named: .NavigationBarColor)
        userNameTextField.textColor = UIColor.whiteColor()
        userNameTextField.hidden = true
        
        self.addSubview(photoButton);
        self.addSubview(userNameTextField);
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if let _ = photoButton.superview, let cameraImage = cameraImage {
            photoButton.snp_remakeConstraints(closure: { (make) in
                make.width.equalTo(cameraImage.size.width);
                make.height.equalTo(cameraImage.size.height);
                make.right.equalTo(-10);
                make.top.equalTo(5);
            })
        }
        
        userNameTextField.snp_remakeConstraints(closure: { (make) in
            make.width.equalTo(200);
            make.left.equalTo(20)
            make.top.equalTo(5);
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.endEditing(true)
        return false
    }
    
    func addRightGradient() {
        let rightGradient: CAGradientLayer = CAGradientLayer()
        let screenWidth = UIScreen.mainScreen().bounds.width
        rightGradient.frame = CGRectMake(screenWidth, 0, -100, self.height)
        
        let startRightGradientColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6);
        let endRightGradientColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0);
        
        rightGradient.startPoint = CGPointMake(0, 0.5)
        rightGradient.endPoint = CGPointMake(1, 0.5)
        
        rightGradient.colors = [endRightGradientColor.CGColor, startRightGradientColor.CGColor]
        headerImageView.layer.insertSublayer(rightGradient, atIndex: 0)
    }
}
