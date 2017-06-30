//
//  ConfirmRegistrationViewController.swift
//  ULC
//
//  Created by Vitya on 6/15/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import Result
import MBProgressHUD

class ConfirmRegistrationViewController: BaseViewController {
    
    // MARK private properties
    private let presenter = PresenterImpl()
    
    // MARK IB Outlets
    @IBOutlet weak var okButton: UIButton!
    
	@IBOutlet weak var confirmEmailLabel: UILabel!
    @IBOutlet weak var bottomCoverImageView: UIImageView!
    @IBOutlet weak var topCoverImageView: UIImageView!
    
    @IBAction func okButton(sender: AnyObject) {
        self.presenter.openLoginVC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        configureViews();
        cameraWithBlurEffect(topCoverImageView, bottomCoverImageView: bottomCoverImageView)
    }
    
    private func configureViews() {
        
        okButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .LoginButtonNormal)), forState: .Normal)
        okButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .LoginButtonSelected)), forState: .Selected)
        okButton.setBackgroundImage(UIImage.fromColor(UIColor(named: .LoginButtonSelected)), forState: .Highlighted)

		confirmEmailLabel.text = R.string.localizable.confirm_email()
		okButton.setTitle(R.string.localizable.ok(), forState: .Normal)
    }
}
