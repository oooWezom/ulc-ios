//
//  TwoPlayGamingBottomView.swift
//  ULC
//
//  Created by Alexey on 9/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

class TwoPlayGamingBottomView:UIView{
    
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var leaveImageView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextImageView: UIImageView!

    @IBOutlet weak var nextActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var gradientView: GradientView!

    var mode:TwoPlayMode?
    
    override func awakeFromNib() {
        super.awakeFromNib()

		configureViews()
    }

	func configureViews(){
		nextActivityIndicator.hidden = true
        
		if let leaveImage = R.image.close_black() {
			leaveImageView.image = leaveImage
		}

		if let nextImage = R.image.next_black() {
			nextImageView.image = nextImage
		}
	}
    
    func initWithMode(gameMode:GameMode) {
        switch gameMode {
        case .GAME:
            nextButton.enabled = false
            nextButton.hidden = true
            nextImageView.hidden = true
            break
        case .SPECTATOR:
            nextButton.enabled = true
            nextButton.hidden = false
            nextImageView.hidden = false
            break
        default:
            break
        }
    }
    
}
