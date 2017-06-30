//
//  ULCSlider.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ULCSlider: UISlider {

	@IBInspectable var progressHeight:CGFloat = CGFloat(10.0) {
		didSet{
			setupView()
		}
	}

	@IBInspectable var thumbImageSize:CGSize = CGSize(width: 20, height: 20) {
		didSet{
			setupView()
		}
	}

	@IBInspectable var thumbNormalImage: UIImage? {
		didSet { setupView() }
	}

	@IBInspectable var thumbHighlightedImage: UIImage = UIImage() {
		didSet{
			setupView()
		}
	}


	@IBInspectable var thumbDisabledImage: UIImage = UIImage() {
		didSet{
			setupView()
		}
	}

	@IBInspectable var thumbSelectedImage: UIImage = UIImage() {
		didSet{
			setupView()
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init(coder: NSCoder) {
		super.init(coder: coder)!
	}

	private func setupView() {
		if let thumbNormalImage = thumbNormalImage {
			setThumbImage(imageWithImage(thumbNormalImage,scaledToSize: thumbImageSize), forState: .Normal)
		}

		setThumbImage(imageWithImage(thumbHighlightedImage,scaledToSize: thumbImageSize), forState: .Highlighted)

		setThumbImage(imageWithImage(thumbSelectedImage,scaledToSize: thumbImageSize), forState: .Selected)
	}

	func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
		image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
		let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
	}

	override func trackRectForBounds(bounds: CGRect) -> CGRect {
		let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: progressHeight))
		super.trackRectForBounds(customBounds)
		return customBounds
	}
}