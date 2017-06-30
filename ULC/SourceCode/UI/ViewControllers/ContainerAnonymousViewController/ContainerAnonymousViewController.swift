//
//  BaseAnonymousViewContoller.swift
//  ULC
//
//  Created by Alex on 2/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit

class ContainerAnonymousViewController: UIViewController {
    
    private let segmentContoller = UISegmentedControl(items: [R.string.localizable.playTitle(), R.string.localizable.talkTitle()]);
    
    private lazy var playAnonymousVC:PlayAnonymousViewController = {
        if let viewController = R.storyboard.anonymous.playAnonymousViewController() {
            viewController.viewTypeController = .Anonymous;
            self.add(asChildViewController: viewController)
            return viewController;
        }
        return PlayAnonymousViewController();
    }();
    
    private lazy var talkAnonymousVC: TalkAnonymousViewController = {
        if let viewController = R.storyboard.anonymous.talkAnonymousViewController() {
            viewController.talkTypeController = .Anonymous;
            self.add(asChildViewController: viewController)
            return viewController;
        }
        return TalkAnonymousViewController();
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        configureSegmentedBar();
        self.addBackButton();
        add(asChildViewController: playAnonymousVC);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
		let value = UIInterfaceOrientation.Portrait.rawValue
		UIDevice.currentDevice().setValue(value, forKey: "orientation")
        if let nc = self.navigationController {
            nc.navigationBar.setBackgroundImage(UIImage(color: UIColor.whiteColor()), forBarMetrics:UIBarMetrics.Default)
            nc.navigationBar.translucent = false
            nc.navigationBar.shadowImage = UIImage()
            nc.setNavigationBarHidden(false, animated:true)
        }
    }
    
    private func configureSegmentedBar() {
        segmentContoller.tintColor = UIColor(named: .LoginButtonNormal);
        segmentContoller.selectedSegmentIndex = 0;
        segmentContoller.enabled = true;
        segmentContoller.sizeToFit();
        segmentContoller.addTarget(self, action: #selector(didChangeValue(_:)), forControlEvents: .ValueChanged);
        self.navigationItem.titleView = segmentContoller;
        segmentContoller.width = view.width * 0.65;
    }
    
    func didChangeValue(sender: AnyObject) {
        if segmentContoller.selectedSegmentIndex == 0 {
            remove(asChildViewController: talkAnonymousVC);
            add(asChildViewController: playAnonymousVC);
        } else {
            remove(asChildViewController: playAnonymousVC);
            add(asChildViewController: talkAnonymousVC);
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController);
        view.addSubview(viewController.view);
        viewController.view.frame = view.bounds;
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight];
        viewController.didMoveToParentViewController(self);
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMoveToParentViewController(nil);
        viewController.view.removeFromSuperview();
        viewController.removeFromParentViewController();
    }
}
