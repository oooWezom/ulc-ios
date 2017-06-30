//
//  SessionBottomView.swift
//  ULC
//
//  Created by Vitya on 9/23/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class SessionBottomView: UIView, NibLoadableView, ReusableView {
    
    @IBOutlet weak var sessioCategoryIconImageView: UIImageView!
    @IBOutlet weak var gradientImageView:           UIImageView!
    @IBOutlet weak var editImageView:               UIImageView!
    
    @IBOutlet weak var leaveView: UIView!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var askView: UIView!
    
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var quaseonLabel: UILabel!
    
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var leftLikeViewPlaceHolder: UIView!
    @IBOutlet weak var rightLikeViewPlaceHolder: UIView!
    
    private let talkCategoriesViewModel = CategoryViewModel()
    
    //MARK:- talk likes
    let leftHeartView  = HeartLikeView.instanciateFromNib();
    let rightHeartView = HeartLikeView.instanciateFromNib();
    
    var leftLikes      = Int()
    var rightLikes     = Int()
    
    private lazy var nextActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView();
        indicator.hidesWhenStopped = true;
        indicator.activityIndicatorViewStyle = .White;
        return indicator
    }();
    
    var isStreamerType = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        addBottomGradient()
        addSubview(nextActivityIndicator)
        configureLikes()
    }
    
    private func configureLikes() {
        leftLikeViewPlaceHolder.addSubview(leftHeartView);
        leftHeartView.hidden = true;
        rightLikeViewPlaceHolder.addSubview(rightHeartView);
        rightHeartView.hidden = true;
    }
    
    func addBottomGradient() {
        let gradient = CAGradientLayer()
        let size = CGSize(width: UIScreen.mainScreen().bounds.height, height: gradientImageView.height)
        gradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        
        let startColor = UIColor.blackColor().colorWithAlphaComponent(0)
        let endColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        gradient.colors = [startColor.CGColor, endColor.CGColor]
        gradientImageView.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func allowRenamingSession(allowElements: Bool, allowEditImage: Bool) {
        editImageView.hidden = !allowEditImage
        sessionNameLabel.userInteractionEnabled = allowElements
        isStreamerType = allowElements
        askView.hidden = allowElements
        
        nextView.hidden = allowElements
    }
    
    func updateViewWithModel(model: AnyObject) {
        guard let model = model as? TalkSessionsResponseEntity else {
            return
        }
        if let categoryURL = talkCategoriesViewModel.fetchWhiteCategoryAvatarURL(model.category) {
            sessioCategoryIconImageView.kf_setImageWithURL(NSURL(string: categoryURL),
                                                           placeholderImage: nil,
                                                           optionsInfo: [.BackgroundDecode],
                                                           progressBlock: nil,
                                                           completionHandler: nil);
        }
        
        if model.name.isEmpty {
            sessionNameLabel.text = talkCategoriesViewModel.fetchCategoryName(model.category)
        } else {
            sessionNameLabel.text = model.name
        }
    }
    
    func updateName(newName: String) {
        sessionNameLabel.text = newName.isEmpty ? R.string.localizable.session_name_placeholder() : newName
    }
    
    func hideElements(show: Bool) {
        gradientImageView.hidden = show
        leaveView.hidden = show
        sessionNameLabel.hidden = show
        sessioCategoryIconImageView.hidden = show
        askView.hidden = show
        
        if !nextActivityIndicator.isAnimating() || isStreamerType{
            nextView.hidden = show
        }
        
        if isStreamerType {
            editImageView.hidden = show
        }
    }
    
    func startNextButtonProgress() {
        nextView.hidden = true
        nextActivityIndicator.startAnimating()
    }
    
    func stopNextButtonProgress() {
        nextView.hidden = gradientImageView.hidden
        nextActivityIndicator.stopAnimating()
    }
    
    func hideRightHeartView(hide: Bool) {
        rightHeartView.hidden = hide
    }
    
    func hideLeftHeartView(hide: Bool) {
        leftHeartView.hidden = hide
    }
    
    func setRightLikes(count: Int?) {
        if let count = count {
            rightLikes = count
            rightHeartView.likesLabel.text = count.roundValueAsString()
        }
    }
    
    func setLeftLikes(count: Int?) {
        if let count = count {
            leftLikes = count
            leftHeartView.likesLabel.text = count.roundValueAsString()
        }
    }
    
    func addRightLikes(count: Int) {
        let times = min(count, 25);
        rightLikes += count;
        rightHeartView.likesLabel.text = rightLikes.roundValueAsString()
        updateColor(rightHeartView, count: Float(times));
        startDispersionHearts(times, heart: rightHeartView);
    }
    
    func addLeftLikes(count: Int) {
        leftLikes += count;
        let times = min(count, 25);
        leftHeartView.likesLabel.text = leftLikes.roundValueAsString()
        updateColor(leftHeartView, count: Float(times));
        startDispersionHearts(min(count, 25), heart: leftHeartView);
    }
    
    func reverLikes() {
        setLeftLikes(rightLikes)
        setRightLikes(0)
    }
    
    func showLeftHeartAnimation() {
        updateColor(leftHeartView, count: 1);
    }
    
    func showRightHeartAnimation() {
        updateColor(rightHeartView, count: 1);
    }
    
    func updateColor(heartView: HeartLikeView, let count: Float) {
    }
    
    func startDispersionHearts(count:Int, heart:HeartLikeView) {
        for _ in 0..<count {
            let h = UIView();
            h.frame = CGRectMake(0, 0, 11, 11);
            let bezire = UIBezierPath();
            bezire.getHearts(h.bounds, scale: 1);
            let l = CAShapeLayer();
            l.path = bezire.CGPath;
            h.layer.mask = l;
            h.backgroundColor = UIColor.random();
            insertSubview(h, belowSubview: heart);
            h.centerWith(heart.likeButton);
            h.alpha = 0.33;
            
            UIView.animateWithDuration(1.5, animations: { [unowned self] in
                if heart == self.leftHeartView {
                    h.x = CGFloat(arc4random_uniform(UInt32(self.width * 0.15)) + 1);
                    h.y = CGFloat(arc4random_uniform(UInt32(self.width * 0.15)) + 1);
                    if arc4random_uniform(2) == 0 {
                        h.x *= -1;
                        h.y *= -1;
                    }
                } else {
                    let newX = CGFloat(arc4random_uniform(UInt32(self.width * 0.2)) + 1);
                    let newY = CGFloat(arc4random_uniform(UInt32(self.width * 0.25)) + 1);
                    let tmpX = (self.width * 0.7) + newX;
                    h.x = max(self.width * 0.75, tmpX);
                    h.y = min(newY, 20);
                    if arc4random_uniform(2) == 0 {
                        h.y *= -1;
                    }
                }
                let transformSize = CGFloat.random()
                h.transform = CGAffineTransformMakeScale(CGFloat(transformSize), CGFloat(transformSize));
                
                }, completion: { success in
                    h.removeFromSuperview();
            })
            UIView.animateWithDuration(1.5, animations: {
                h.alpha = 0;
            })
        }
        heart.launchPulseAnimation(Float(count));
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        leftHeartView.snp_remakeConstraints { (make) in
            make.width.equalTo(28);
            make.height.equalTo(25);
            make.bottom.right.equalTo(0);
        }
        rightHeartView.snp_remakeConstraints { (make) in
            make.width.equalTo(28);
            make.height.equalTo(25);
            make.bottom.left.equalTo(0);
        }
        nextActivityIndicator.snp_remakeConstraints { make in
            make.centerX.centerY.equalTo(nextView)
        }
    }
    
    func randomSequence(let from: Float, let to: Float) -> Float {
        return (from + Float(arc4random()) % (to - from));
    }
}
