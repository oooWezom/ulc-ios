//
//  ReportUserBehaviorAlertView.swift
//  ULC
//
//  Created by Vitya on 10/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class ReportUserBehaviorAlertView: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var alertBackgroundView: UIView!
    
    @IBOutlet weak var nudityLabel: UILabel!
    @IBOutlet weak var violenceOrHarmLabel: UILabel!
    @IBOutlet weak var harassmentLabel: UILabel!
    
    @IBOutlet weak var nudityImageView: UIImageView!
    @IBOutlet weak var violenceOrHarmImageView: UIImageView!
    @IBOutlet weak var harassmentImageView: UIImageView!
	@IBOutlet weak var reportLabel: UILabel!
    
    @IBAction func closeAlertView(sender: AnyObject) {
        close()
    }
    
    @IBAction func sendReportAction(sender: AnyObject) {
        wsTalkViewModel?.reportUserBehavior(userId,
                                            userId: nil,
                                            categoryId: reportUserBehavior.rawValue,
                                            comment: nil)
        close()
    }
    
    private var wsTalkViewModel: WSTalkViewModel?
    
    private var userId = 0
    private var reportUserBehavior = WSReportUserBehavior.None
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureGestureRecognisers()
    }

    func configureView() {
        
        showCheckIcons(true)
        
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        cancelButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Normal)
        sendButton.setTitleColor(UIColor(named: .OkButtonNormal), forState: .Selected)
        sendButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        sendButton.enabled = false
        
        alertBackgroundView.layer.masksToBounds = true
        alertBackgroundView.layer.cornerRadius = 10
        
        hideKeyboardWhenTappedAround()

		cancelButton.setTitle(R.string.localizable.cancel(), forState: .Normal)
		sendButton.setTitle(R.string.localizable.send(), forState: .Normal)
		nudityLabel.text = R.string.localizable.nudity()
		violenceOrHarmLabel.text = R.string.localizable.violence_or_harm()
		harassmentLabel.text = R.string.localizable.harassment()
		reportLabel.text = R.string.localizable.report()
    }
    
    func configureGestureRecognisers() {
        
        let nudityTapGesture = UITapGestureRecognizer(target: self, action: #selector(showNudityCheckIcon))
        let violenceTapGesture = UITapGestureRecognizer(target: self, action: #selector(showViolenceCheckIcon))
        let harassmentTapGesture = UITapGestureRecognizer(target: self, action: #selector(showHarassmentCheckIcon))
        
        nudityLabel.userInteractionEnabled = true
        violenceOrHarmLabel.userInteractionEnabled = true
        harassmentLabel.userInteractionEnabled = true
        
        nudityLabel.addGestureRecognizer(nudityTapGesture)
        violenceOrHarmLabel.addGestureRecognizer(violenceTapGesture)
        harassmentLabel.addGestureRecognizer(harassmentTapGesture)
    }
    
    func showNudityCheckIcon(gesture: UITapGestureRecognizer) {
        showCheckIcons(true)
        nudityImageView.hidden = false
        reportUserBehavior = .Nudity
    }
    
    func showViolenceCheckIcon(gesture: UITapGestureRecognizer) {
        showCheckIcons(true)
        violenceOrHarmImageView.hidden = false
        reportUserBehavior = .ViolenceOrHarm
    }
    
    func showHarassmentCheckIcon(gesture: UITapGestureRecognizer) {
        showCheckIcons(true)
        harassmentImageView.hidden = false
        reportUserBehavior = .Harassment
    }
    
    private func showCheckIcons(chesk: Bool) {
        sendButton.enabled             = chesk
        nudityImageView.hidden         = chesk
        violenceOrHarmImageView.hidden = chesk
        harassmentImageView.hidden     = chesk
    }
    
    func showAlertMessage(wsTalkViewModel: WSTalkViewModel, userId: Int) {
        self.wsTalkViewModel = wsTalkViewModel
        self.userId = userId
        
        if let topVC = UIApplication.topViewController() {
            view.frame = topVC.view.bounds
            alertBackgroundView.center = self.view.center
            
            view.addSubview(alertBackgroundView)
            topVC.addChildViewController(self)
            topVC.view!.addSubview(self.view)
            didMoveToParentViewController(topVC)
        }
    }
    
    func close() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

}
