//
//  GeneralGameView.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class GameView: UIView, GameViewDelegate {
    
    init() {
        super.init(frame: CGRectZero)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK handle common game behavior
    
    private func addCustomView() {
    
    }

    override func updateConstraints() {
        super.updateConstraints()
        
    // MARK snapkit
    }
    
    func bind(view:UIView) {
    // MARK handle binding view
    }
    
    func unbind(view:UIView) {
    // MARK handle unbinding view    
    }
    
    

    
}