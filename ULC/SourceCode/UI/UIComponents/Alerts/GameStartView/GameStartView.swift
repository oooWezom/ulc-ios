//
//  GameStartView.swift
//  ULC
//
//  Created by Alexey on 7/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

protocol GameStartDelegate {
	func gameTimeIsOver()
}

class GameStartView: UIView, NibLoadableView {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!

	var timer = NSTimer()
	var seconds = CGFloat()

	let maxSecondInterval: CGFloat = 4
	let timerStep: CGFloat = 1

	var delegate: GameStartDelegate?

	override func awakeFromNib() {
		super.awakeFromNib()
        roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: 10);
		seconds = maxSecondInterval
		configureViews()
	}

	func configureViews(){
		titleLabel.text = R.string.localizable.game_will_start_in() //#MARK localized
		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
	}

	func updateView(width: CGFloat, height: CGFloat, center: CGPoint) {
		self.frame = CGRectMake(0, 0, width, height)
		self.center = center
	}

	func start() {
		timer = NSTimer.scheduledTimerWithTimeInterval(timerStep.doubleValue, target: self, selector: #selector(update), userInfo: nil, repeats: true)
	}

	func stop() {
		timer.invalidate()
		seconds = maxSecondInterval
	}

	func update() {
		if (seconds <= 0.0) {
			stop()
			delegate?.gameTimeIsOver()
		} else {
			timerLabel.text = ""
			seconds = seconds - timerStep
			if seconds >= 0.0 {
				timerLabel.text = String(Int(seconds))
			}
		}
	}
}
