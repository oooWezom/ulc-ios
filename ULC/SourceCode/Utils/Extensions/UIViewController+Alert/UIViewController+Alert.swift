//
//  UIViewController+Alert.swift
//  ULC
//
//  Created by Alexey on 8/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func showAlertMessage(description: String, handler: ((Void) -> Void)?) {

		let alertController = UIAlertController(title: R.string.localizable.error(), message: description, preferredStyle: .Alert)
		let ok = UIAlertAction(title: R.string.localizable.ok(), style: .Default, handler: { (action) -> Void in
			alertController.dismissViewControllerAnimated(true, completion: handler)
		})
        
		alertController.addAction(ok)
        self.presentViewController(alertController, animated: true, completion: nil);
	}
}
