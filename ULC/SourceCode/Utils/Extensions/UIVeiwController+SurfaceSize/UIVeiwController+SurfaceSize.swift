//
//  UIVeiwController+SurfaceSize.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func getSurfaceHeight() -> CGFloat {
        return (self.view.frame.size.width * 0.5) * 0.75
    }
    
    func getWishHeight() -> CGFloat {
        return (self.view.frame.size.width * 0.66) * 0.75
    }
}