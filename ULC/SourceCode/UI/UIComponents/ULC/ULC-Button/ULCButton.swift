//
//  TalkPlayButton.swift
//  ULC
//
//  Created by Alex on 6/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

enum ULCState:Int {
    case Open
    case Close
}

class ULCButton: UIView, NibLoadableView {
    
    var state = ULCState.Close;
    
    @IBOutlet weak var playULCButton: UIButton!
    @IBOutlet weak var talkULCButton: UIButton!
    
    @IBOutlet weak var mainULCButton: UIButton!
    
    @IBAction func changeULCState(sender: AnyObject) {
        
        if state == ULCState.Open {
            openULCButton();
        } else {
            closeULCButton(nil);
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if state == ULCState.Close {
            return super.hitTest(point, withEvent: event);
        } else {
            if CGRectContainsPoint(playULCButton.frame, point) {
                return playULCButton;
            }else if CGRectContainsPoint(talkULCButton.frame, point) {
                return talkULCButton;
            }
            return super.hitTest(point, withEvent: event);
        }
    }
    
    func setStartPosition() {
        
        self.playULCButton.width = 92;
        self.playULCButton.height = 92;
        self.playULCButton.centerWith(mainULCButton);
        
        self.talkULCButton.width = 92;
        self.talkULCButton.height = 92;
        self.talkULCButton.centerWith(mainULCButton);
        
        self.mainULCButton.setImage(R.image.ulc_open_icon(), forState: .Normal);
        self.mainULCButton.setImage(R.image.ulc_open_icon(), forState: .Selected)
        self.mainULCButton.setImage(R.image.ulc_open_icon(), forState: .Highlighted)
        
        self.state = ULCState.Close;
    }
    
    private func openULCButton() {
        UIView.animateWithDuration(0.55, animations: { [unowned self] in
            
            self.playULCButton.width = 92;
            self.playULCButton.height = 92;
            self.playULCButton.centerWith(self.mainULCButton);
            
            self.talkULCButton.width = 92;
            self.talkULCButton.height = 92;
            self.talkULCButton.centerWith(self.mainULCButton);
            
            
            }, completion: { [unowned self] (value: Bool) in
                
                self.mainULCButton.setImage(R.image.ulc_open_icon(), forState: .Normal);
                self.mainULCButton.setImage(R.image.ulc_open_icon_pressed(), forState: .Selected)
                self.mainULCButton.setImage(R.image.ulc_open_icon_pressed(), forState: .Highlighted)
                
                self.state = ULCState.Close;
            })
    }
    
    func closeULCButton(completitionHandler: (() -> Void)?) {
        UIView.animateWithDuration(0.55, animations: { [unowned self] in
            
            self.playULCButton.width    = 92;
            self.playULCButton.height   = 92;
            self.playULCButton.x        = -25;
            self.playULCButton.y        = self.playULCButton.height * -1;
            
            self.talkULCButton.width    = 92;
            self.talkULCButton.height   = 92;
            self.talkULCButton.x        = self.playULCButton.height * -1;
            self.talkULCButton.y        = -25;
            
            
            }, completion: { [weak self] (value: Bool) in
                
                self?.mainULCButton.setImage(R.image.ulc_close_icon(), forState: .Normal);
                self?.mainULCButton.setImage(R.image.ulc_close_icon_pressed(), forState: .Selected)
                self?.mainULCButton.setImage(R.image.ulc_close_icon_pressed(), forState: .Highlighted)
                
                self?.state = ULCState.Open;
                
                if let completition = completitionHandler {
                    completition();
                }
        })
    }
}
