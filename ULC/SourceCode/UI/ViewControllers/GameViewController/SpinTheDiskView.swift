//
//  SpinTheDiskView.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

class SpinTheDiskView: UIView {
    
    var unityView = UnityGetGLView()
    
    init() {
        super.init(frame: CGRectZero)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func addCustomView() {
        
    }
    
    func initUnityGLView() {
        // MARK handle initial unity glview
    }
    
    // MARK handle specified game behavior
    
}