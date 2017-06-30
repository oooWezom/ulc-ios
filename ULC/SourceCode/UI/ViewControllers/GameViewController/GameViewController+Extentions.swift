//
//  GameViewController+Extentions.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/14/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import VideoCore

extension GameViewController: VCSessionDelegate {
    // MARK - VCSessionDelegate
    func connectionStatusChanged(sessionState: VCSessionState) {
        switch sessionState {
        case .None:
            break;
        case .PreviewStarted:
            break;
        case .Starting:
            break;
        case .Started:
            break;
        case .Ended:
            break;
        case .Error:
            streamSession?.endRtmpSession();
            break;
        }
    }
}

extension GameViewController: Playable {
    func playing() {
        self.rightActivityIndicator.stopAnimating()
    }
    
    func stopped() {
        self.rightActivityIndicator.startAnimating()
    }
}