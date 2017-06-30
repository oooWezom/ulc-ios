//
//  File.swift
//  ULC
//
//  Created by Alex on 6/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import MBProgressHUD

enum FeedType: Int {
    case None
    case All
    case Games
    case Talk
}

class NewsFeedFilterViewController: UIViewController, ViewsConfigurable {
    
    @IBOutlet weak var playSwith: UISwitch!
    @IBOutlet weak var talkSwitch: UISwitch!
    @IBOutlet weak var followsSwitch: UISwitch!

	@IBOutlet weak var twoPlayLabel: UILabel!
	@IBOutlet weak var twoTalkLabel: UILabel!
	@IBOutlet weak var followsLabel: UILabel!


    weak var viewModel: NewsFeedFilterViewModel?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        configureViews();
        
        bindSignals();
    }
    
    func configureViews() {
        
        self.title = R.string.localizable.filter()
        
        view.backgroundColor = UIColor(named: .NewsFeedBackgroundColor);
        
        playSwith.onTintColor = UIColor(named: .LoginButtonNormal);
        talkSwitch.onTintColor = UIColor(named: .LoginButtonNormal);
        followsSwitch.onTintColor = UIColor(named: .LoginButtonNormal);
        
        let leftBarButtonItem = UIBarButtonItem(image: R.image.back_button_icon(), style: .Plain, target: self, action: #selector(popViewController));
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        
        let rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.done(), style: .Plain, target: self, action: #selector(doneFilters));
        rightBarButtonItem.tintColor = UIColor(named: .DoneButtonEnable)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;

		twoPlayLabel.text = R.string.localizable.two_play_with_number().uppercaseString
		twoTalkLabel.text = R.string.localizable.two_talk_with_number().uppercaseString
		followsLabel.text = R.string.localizable.follows().uppercaseString
    }
    
    func doneFilters() {
        
        guard let viewModel = viewModel else {
            self.navigationController?.popViewControllerAnimated(true)
            return;
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        viewModel.reloadFollowingEvents()
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [unowned self] (event, error) in
            
            event.observeCompleted { [unowned self] in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.viewModel?.popViewControllerAnimated();
            }
            
            event.observeFailed { [unowned self] error in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.showULCError(error)
            }
        }
    }
    
    func configureTableView() {
    }
    
    private func bindSignals() {
        
        let playProducer        = addRACSignalToUISwitch(playSwith);
        let talkProducer        = addRACSignalToUISwitch(talkSwitch);
        let followingProducer   = addRACSignalToUISwitch(followsSwitch);
        
        guard let viewModel = viewModel else {
            fatalError("Can't cast viewModel to NewsFeedFilterViewModel");
        }
        
        var tmpPlayValue = false;
        var tmpTalkValue = false;
        var tmpFollowingValue = false;
        
        if !NSUserDefaults.standardUserDefaults().boolForKey(Constants.firstStart) {
            
            tmpPlayValue = true;
            tmpTalkValue = true;
            tmpFollowingValue = true
            
            playSwith.setOn(tmpPlayValue, animated: true)
            talkSwitch.setOn(tmpTalkValue, animated: true)
            followsSwitch.setOn(tmpFollowingValue, animated: true)
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.firstStart);
            NSUserDefaults.standardUserDefaults().synchronize();
            
        } else {
            
            tmpPlayValue = NSUserDefaults.standardUserDefaults().boolForKey(Constants.playFilter);
            tmpTalkValue = NSUserDefaults.standardUserDefaults().boolForKey(Constants.talkFilter);
            tmpFollowingValue = NSUserDefaults.standardUserDefaults().boolForKey(Constants.followingFilter);
            
            playSwith.setOn(tmpPlayValue, animated: true);
            talkSwitch.setOn(tmpTalkValue, animated: true);
            followsSwitch.setOn(tmpFollowingValue, animated:true);
        }
        
        viewModel.is2PlayProperty <~ playProducer;
        viewModel.is2TalkProperty <~ talkProducer;
        viewModel.isFollowingProperty <~ followingProducer;
        
        viewModel.is2PlayProperty.value = tmpPlayValue;
        viewModel.is2TalkProperty.value = tmpTalkValue;
        viewModel.isFollowingProperty.value = tmpFollowingValue;
    }
    
    private func addRACSignalToUISwitch(uiswith: UISwitch) -> SignalProducer<Bool, NoError> {
        return uiswith.rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .flatMapError({ error in return SignalProducer<AnyObject?, NoError>.empty})
            .map { (value: AnyObject?) -> Bool in
                guard let value = value as? UISwitch else {
                    return false
                }
                return value.on;
        }
    }
    
    private func saveFilters() {
        NSUserDefaults.standardUserDefaults().setBool(playSwith.on, forKey: Constants.playFilter);
        NSUserDefaults.standardUserDefaults().setBool(talkSwitch.on, forKey: Constants.talkFilter);
        NSUserDefaults.standardUserDefaults().setBool(followsSwitch.on, forKey: Constants.followingFilter);
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    deinit {
        saveFilters();
    }
}
