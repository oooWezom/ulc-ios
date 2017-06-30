//
//  ViewController+Orientation.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func getInterfaceOrientation() -> UIInterfaceOrientation {
        return UIApplication.sharedApplication().statusBarOrientation
    }
    
    func forceSwitchOrientationToPortrait() {
        if self.getInterfaceOrientation().isLandscape {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }
    
    func forceSwitchOrientationToLandscape() {
        if self.getInterfaceOrientation().isPortrait {
            let value = UIInterfaceOrientation.LandscapeLeft.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }
}
