//
//  UIViewController+AlertMessage.swift
//  ULC
//
//  Created by Vitya on 9/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showULCError(error: ULCError) {

        let alertController = UIAlertController(title: R.string.localizable.error(), message: error.description, preferredStyle: .Alert)
        let ok = UIAlertAction(title: R.string.localizable.ok(), style: .Default, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(ok)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showUpdateAlert() {

        let alertController = UIAlertController(title: R.string.localizable.oops(), message:R.string.localizable.new_version_message(), preferredStyle: .Alert);
        let action = UIAlertAction(title: R.string.localizable.ok(), style: .Default) { _ in
            if let url = NSURL(string:"itms://itunes.apple.com/us/app/apple-store/id1138881402?mt=8") {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url);
                }
            }
        }
        alertController.addAction(action);
        self.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func showAlertMessage(title: String, message: String, completitionHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        if let completition = completitionHandler {
            alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Cancel, handler: completition));
        } else {
            alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Cancel, handler: nil))
        }
        self.presentViewController(alert, animated: true) { [weak self] in
            self?.view.endEditing(true);
        }
        alert.view.tintColor = UIColor(named: .OkButtonNormal)
        return alert
    }
}
