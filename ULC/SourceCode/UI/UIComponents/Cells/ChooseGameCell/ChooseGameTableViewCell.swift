//
//  ChooseGameTableViewCell.swift
//  ULC
//
//  Created by Alexey on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Foundation

protocol ChooseGameCheckDelegate {
	func check(gameID: Int)
}

class ChooseGameTableViewCell: UITableViewCell, ReusableView, NibLoadableView {

	@IBOutlet weak var selectionImageView: UIImageView!
	@IBOutlet weak var gameImageView: UIImageView!
	@IBOutlet weak var gameNameLabel: UILabel!

	@IBAction func infoButtonAction(sender: AnyObject) {

	}

	var delegate: ChooseGameCheckDelegate?
	var gameEntity = GameEntity()

	func updateWithModel(model: AnyObject) {
		if let model = model as? GameEntity {
			gameEntity = model
			gameNameLabel.text = model.title
			var gameImage = UIImage()

			switch model.gameId {
			case GameID.RANDOM.rawValue:
				if let image = R.image.choise_random() {
					gameImage = image
				}
				break
			case GameID.X_COWS.rawValue:
				if let image = R.image.choise_x_cows() {
					gameImage = image
				}
				break

			case GameID.LAND_IT.rawValue:
				if let image = R.image.choise_land_it() {
					gameImage = image
				}
				break

			case GameID.ROCK_SPOCK.rawValue:
				if let image = R.image.choise_rock() {
					gameImage = image
				}
				break

			case GameID.MATH2.rawValue:
				if let image = R.image.choise_math() {
					gameImage = image
				}
				break

			case GameID.SPIN_THE_DISKS.rawValue:
				if let image = R.image.choise_spin_disk() {
					gameImage = image
				}
				break

			default:
				if let image = R.image.choise_random() {
					gameImage = image
				}
				break

			}

			gameImageView.image = gameImage
			if (model.isChecked == true) {
				if let checkedImage = R.image.check_done_icon() {
					selectionImageView.image = checkedImage
				}
			} else {
				selectionImageView.image = nil
			}

			let gesture = UITapGestureRecognizer(target: self, action: #selector(ChooseGameTableViewCell.checkField(_:)))
			contentView.addGestureRecognizer(gesture)
		}
	}

	func checkField(sender: UITapGestureRecognizer) {

		self.delegate?.check(gameEntity.gameId)

		if gameEntity.gameId == GameID.RANDOM.rawValue {

		} else {
			if gameEntity.isChecked == true {
				gameEntity.isChecked = false
			} else {
				gameEntity.isChecked = true
			}
		}
		self.updateWithModel(gameEntity)
	}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionImageView.image    = nil
        gameImageView.image         = nil
        gameNameLabel.text          = ""
    }
}
