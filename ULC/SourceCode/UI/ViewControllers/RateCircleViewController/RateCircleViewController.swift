//
//  RateCircleViewController.swift
//  ULC
//
//  Created by Vitya on 8/31/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Kingfisher

protocol RateCircleViewDelegate {
    func rateTimeIsOver(player:Players)
    func like(player:Players)
    func dislike(player:Players)
}

class RateCircleViewController: UIViewController {
    
    @IBOutlet weak var rateDescriptionLabel: UILabel!
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
	@IBOutlet weak var dislikeButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!


    var delegate: RateCircleViewDelegate?
    
    // MARK private properties
    private let outerCircle                 = CAShapeLayer()
    private let decreaseCircleProgress      = CAShapeLayer()
    private let timerStep: CGFloat          = 0.1
    
    private var timer                       = NSTimer()
    private var seconds                     = CGFloat()
    private var maxSecondInterval: CGFloat  = 10
    
    var player:Players = .LEFT_PLAYER
    
    @IBAction func dislikeButton(sender: AnyObject) {
        delegate?.dislike(player)
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        delegate?.like(player)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //start()
    }
    
    deinit{
        Swift.debugPrint("DEINIT RATE VIEW")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        
        userAvatarImageView.roundedView(true, borderColor: nil, borderWidth: 2.0, cornerRadius: nil);
        backgroundImageView.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: nil);
        
        setTimerProgressToAvatar()

		configureViews()
    }

	func configureViews(){

		dislikeButton.setTitle(R.string.localizable.dislike(), forState: .Normal)

		likeButton.setTitle(R.string.localizable.like(), forState: .Normal)

	}
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isTimerRunning() {
             stop()
        }
    }
    
    func updateWithModel(model:AnyObject, player:Players){
        self.player = player
        guard let model = model as? WSPlayerEntity else{return}
        
        let url = NSURL(string: Constants.userContentUrl + model.avatar)
        
        if let url = url {
            KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil, completionHandler: {
             [unowned self] (image, error, cacheType, imageURL) -> () in
                if let image = image{
                    self.userAvatarImageView.image = image
                }
            })
        }

        rateDescriptionLabel.text = "\(R.string.localizable.rate()) \(player.rawValue) \(R.string.localizable.player()) \(model.name)"
    }
    
//    func showCircleView() {
//        if let topVC = UIApplication.topViewController() {
//            view.frame = topVC.view.bounds
//            view.center = self.view.center
//            start()
//            topVC.addChildViewController(self)
//            topVC.view!.addSubview(self.view)
//            self.didMoveToParentViewController(topVC)
//        }
//    }
    
    func setTimerProgressToAvatar() {
        let frameSize = backgroundImageView.frame.size
        
        decreaseCircleProgress.path = UIBezierPath(ovalInRect: CGRect(x: 8, y: 8, width: frameSize.width - 16, height: frameSize.height - 16)).CGPath
        decreaseCircleProgress.lineWidth = 8
        decreaseCircleProgress.strokeEnd = 1
        decreaseCircleProgress.lineCap = kCALineCapRound
        decreaseCircleProgress.fillColor = UIColor.clearColor().CGColor
        decreaseCircleProgress.strokeColor = UIColor(named: .OkButtonSelected).CGColor
        backgroundImageView.layer.addSublayer(decreaseCircleProgress)
        
        outerCircle.path = UIBezierPath(ovalInRect: CGRect(x: 8, y: 8, width: frameSize.width-16, height: frameSize.height-16)).CGPath
        outerCircle.lineWidth = 8
        outerCircle.lineCap = kCALineCapRound
        outerCircle.fillColor = UIColor.clearColor().CGColor
        outerCircle.strokeColor = UIColor.orangeColor().CGColor
        backgroundImageView.layer.addSublayer(outerCircle)
    }
    
    func closeCircleView() {
        stop()
        
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        if let presentingVC = self.presentingViewController {
            presentingVC.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    func start() {
        seconds = maxSecondInterval
        timer = NSTimer.scheduledTimerWithTimeInterval(timerStep.doubleValue, target: self, selector:  #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer.invalidate()
        seconds = maxSecondInterval
        outerCircle.strokeEnd = seconds * 0.1
    }
    
    func update() {
        if(seconds < 0)
        {
            stop()
           // closeCircleView()
            delegate?.rateTimeIsOver(player)
        } else {
            seconds = seconds - timerStep
            outerCircle.strokeEnd = seconds * 0.1
        }
    }
    
    func isTimerRunning() -> Bool {
        return timer.valid
    }
    
    func setMaxTimerInterval(maxInterval: CGFloat) {
        maxSecondInterval = maxInterval
    }
}
