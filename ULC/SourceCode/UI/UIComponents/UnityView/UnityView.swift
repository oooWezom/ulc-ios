//
//  UnityView.swift
//  ULC
//
//  Created by Alexey on 11/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class UnityView: UIView {

	let leftPlayerView              = UIView()
	let rightPlayerView             = UIView()
	let leftPlayerSeparatorView     = UIView()
	let rightPlayerSeparatorView    = UIView()
	let leftPlayerButton            = UIButton()
	let rightPlayerButton           = UIButton()
	let leftPlayerPlaceholderLabel  = UILabel()
	let mainPlaceholderLabel        = UILabel()

    init() {
        super.init(frame: CGRectZero)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func addCustomView() {
        self.backgroundColor = UIColor.whiteColor()
        addSubview(leftPlayerView)
        addSubview(rightPlayerView)
        leftPlayerView.addSubview(leftPlayerButton)
        leftPlayerView.addSubview(leftPlayerSeparatorView)
        rightPlayerView.addSubview(rightPlayerButton)
        rightPlayerView.addSubview(rightPlayerSeparatorView)
        rightPlayerView.addSubview(leftPlayerPlaceholderLabel)
        addSubview(mainPlaceholderLabel)
        
        configureViews()
    }

	func configureViews(){
		leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Normal, cornerRadius: 2)
		leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
		leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Highlighted, cornerRadius: 2)

		rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Highlighted, cornerRadius: 2)
		rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
		rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Selected, cornerRadius: 2)

		leftPlayerButton.setTitle(R.string.localizable.ready(), forState: .Normal)
		rightPlayerButton.setTitle(R.string.localizable.ready(), forState: .Normal)
		leftPlayerButton.titleLabel?.font = UIFont(name: leftPlayerPlaceholderLabel.font.fontName, size: 12)
		rightPlayerButton.titleLabel?.font = UIFont(name: leftPlayerPlaceholderLabel.font.fontName, size: 12)
		rightPlayerButton.backgroundColor = UIColor(named: .UnityButtonNormalColor)
		leftPlayerPlaceholderLabel.text = R.string.localizable.when_you_will_be_ready() + "\r\n" + R.string.localizable.push_the_button()
		mainPlaceholderLabel.text = "\(R.string.localizable.waiting()) " + "\r\n" + R.string.localizable.for_players()
		leftPlayerPlaceholderLabel.textAlignment = .Center
		leftPlayerPlaceholderLabel.textColor = .blackColor()
		leftPlayerPlaceholderLabel.font = UIFont(name: leftPlayerPlaceholderLabel.font.fontName, size: 12)
		mainPlaceholderLabel.font = UIFont(name: leftPlayerPlaceholderLabel.font.fontName, size: 12)
		mainPlaceholderLabel.textColor = .blackColor()
		mainPlaceholderLabel.textAlignment = .Center
		mainPlaceholderLabel.numberOfLines = 0;
		leftPlayerPlaceholderLabel.numberOfLines = 0;
	}

	func spectatorMode(){
		leftPlayerButton.enabled = false
		rightPlayerButton.enabled = false
		leftPlayerPlaceholderLabel.hidden = true
		mainPlaceholderLabel.hidden = false
	}

	func streamerMode(){
		leftPlayerButton.enabled = true
		rightPlayerButton.enabled = false
		leftPlayerPlaceholderLabel.hidden = false
		mainPlaceholderLabel.hidden = true
	}

	func wishMode(){
		commonMode()
		mainPlaceholderLabel.text = R.string.localizable.let_the_execution_begin()
	}

	func doneMode(){
		commonMode()
		mainPlaceholderLabel.text = R.string.localizable.rate_them()
	}

	func finishMode(){
		commonMode()
		mainPlaceholderLabel.text = R.string.localizable.you_may_leave_now()
	}

	func gameNotSupportedMode() {
		commonMode()
		mainPlaceholderLabel.text = R.string.localizable.game_is_not_supported()
	}

	func commonMode(){
		leftPlayerPlaceholderLabel.hidden = true
		mainPlaceholderLabel.hidden = false
		leftPlayerButton.hidden     = true
		leftPlayerButton.enabled    = false
		rightPlayerButton.hidden    = true
		rightPlayerButton.enabled   = false

		mainPlaceholderLabel.snp_remakeConstraints{
			(make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
		}
	}

	override func updateConstraints() {
		super.updateConstraints()

		let orientation                 = UIApplication.sharedApplication().statusBarOrientation

		let buttonHeight = orientation.isLandscape ? 35 : 25
		let buttonWidth = orientation.isLandscape ? 80 : 60

		mainPlaceholderLabel.snp_remakeConstraints{
			(make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(-20)
		}

		leftPlayerView.snp_remakeConstraints{
			(make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(self).multipliedBy(0.5)
		}

		rightPlayerView.snp_remakeConstraints{
			(make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalToSuperview()
			make.width.equalTo(self).multipliedBy(0.5)
		}

		leftPlayerSeparatorView.snp_remakeConstraints{
			(make) in
			make.height.equalTo(1.0)
			make.left.equalTo(leftPlayerView)
			make.right.equalTo(leftPlayerView)
			make.centerY.equalTo(leftPlayerView)
		}

		leftPlayerButton.snp_remakeConstraints{
			(make) in
			make.bottom.equalTo(leftPlayerSeparatorView.snp_top).offset(-10)
			make.centerX.equalTo(leftPlayerSeparatorView)
			make.height.equalTo(buttonHeight)
			make.width.equalTo(buttonWidth)
		}

		leftPlayerPlaceholderLabel.snp_remakeConstraints{
			(make) in
			make.top.equalTo(leftPlayerSeparatorView.snp_bottom)
			make.left.equalTo(leftPlayerView)
			make.right.equalTo(leftPlayerView)
		}

		rightPlayerSeparatorView.snp_remakeConstraints{
			(make) in
			make.height.equalTo(1.0)
			make.width.equalTo(rightPlayerView)
			make.centerX.equalTo(rightPlayerView)
			make.centerY.equalTo(rightPlayerView)
		}

		rightPlayerButton.snp_remakeConstraints{
			(make) in
			make.bottom.equalTo(rightPlayerSeparatorView).offset(-10)
			make.centerX.equalTo(rightPlayerSeparatorView)
			make.height.equalTo(buttonHeight)
			make.width.equalTo(buttonWidth)
		}
	}

	func resetConstraints(){
		mainPlaceholderLabel.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		leftPlayerView.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		rightPlayerView.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		leftPlayerSeparatorView.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		leftPlayerButton.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		leftPlayerPlaceholderLabel.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		rightPlayerSeparatorView.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}

		rightPlayerButton.snp_remakeConstraints{
			(make) in
			make.top.left.width.height.equalTo(0)
		}
	}
}
