//
//  HeartLikeView.swift
//  ULC
//
//  Created by Alex on 10/13/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class HeartLikeView: UIView, ReactiveBindViewProtocol {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeBorderImageView: UIImageView!
    
    var randomImageTimer: NSTimer?;
    
    //private let normalAlpha:CGFloat = 0.25;
    //private let activeAlpha:CGFloat = 0.95;
    
    override func awakeFromNib() {
        super.awakeFromNib();
        alpha = 1.0;
        backgroundColor = UIColor.clearColor();
        likesLabel.text = "";
        likesLabel.adjustsFontSizeToFitWidth = true;
        setupRandomTimer();
    }
    
    func launchPulseAnimation(let count:Float) {
        
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.alpha = 0.3;
        }) { success in
            self.alpha = 1.0;
        }
        let newCount = max(2, count);
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.15 * Double(newCount / 4);
        pulseAnimation.repeatCount = newCount / 2;
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        pulseAnimation.autoreverses = true
        
        launchBorderPulseAnimation(count)
        likeButton.layer.addAnimation(pulseAnimation, forKey: "animateOpacity")
        likesLabel.layer.addAnimation(pulseAnimation, forKey: "animateOpacity")
    }
    
    func launchBorderPulseAnimation(let count:Float) {
        let borderAnimation = CABasicAnimation(keyPath: "transform.scale");
        borderAnimation.duration = 0.15 * Double(count / 4);
        borderAnimation.repeatCount = max(1, min(5, count));
        borderAnimation.fromValue = 1.0
        borderAnimation.toValue = 1.5
        borderAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        likeBorderImageView.layer.addAnimation(borderAnimation, forKey: "animateOpacity")
    }
    
    func updateViewWithModel(model: AnyObject?) { }
    
    func setNewRandomImage() {
        guard let originImage = likeButton.imageView?.image,
              let newImage = originImage.imageWithColor(UIColor.init(hue: CGFloat(arc4random_uniform(UInt32(360)) + 1)/360, saturation: 0.1, brightness: 1.0, alpha: 1.0)) else {
            return;
        }
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { [unowned self] in
            self.likeButton.alpha = 0.5;
            }, completion: {success in
                self.likeButton.imageView?.animationImages = [newImage];
                self.likeButton.imageView?.startAnimating();
                UIView.animateWithDuration(0.5, animations: { [unowned self] in
                    self.likeButton.alpha = 1.0;
                })
        });
    }
    
    private func setupRandomTimer() {
        setNewRandomImage();
        randomImageTimer = NSTimer.scheduledTimerWithTimeInterval(4.0,
                                                                  target: self,
                                                                  selector: #selector(setNewRandomImage),
                                                                  userInfo: nil,
                                                                  repeats: true);
    }
    
    deinit {
        randomImageTimer?.invalidate();
        randomImageTimer = nil;
    }
}
