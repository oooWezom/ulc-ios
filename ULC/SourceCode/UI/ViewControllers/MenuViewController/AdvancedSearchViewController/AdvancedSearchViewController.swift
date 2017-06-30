//
//  AdvancedSearchViewController.swift
//  ULC
//
//  Created by Alex on 7/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import TTRangeSlider

protocol AdvancedProfilesSearchable: class {
    func updateSearchWithParams()
}

class AdvancedSearchViewController: UIViewController, LanguageDelegate, TTRangeSliderDelegate {
    
    let presenter = PresenterImpl();
    
    weak var advancedSearchViewModel: AdvancedSearchViewModel?;
    weak var searchableDelegate: AdvancedProfilesSearchable?;
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var levelSlider: TTRangeSlider!
    @IBOutlet weak var sexSegmentedControl: UISegmentedControl!

    @IBOutlet weak var languagesLabel: UILabel!
	@IBOutlet weak var regionLabel: UILabel!
	@IBOutlet weak var genderLabel: UILabel!
	@IBOutlet weak var levelLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!

    
    private var languages = [LanguageEntity]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        sexSegmentedControl.tintColor = UIColor(named: .NavigationBarColor);
        
        statusButton.setTitleColor(UIColor(named: .LoginButtonNormal), forState: .Normal);
        statusButton.setTitleColor(UIColor(named: .LoginButtonNormal), forState: .Selected);
        statusButton.setTitleColor(UIColor(named: .LoginButtonNormal), forState: .Highlighted);
        title = R.string.localizable.parameters()
        
        addControlsButton();
        configureSlider();
		configureView();
        
        advancedSearchViewModel?.gender.value = 0;
    }

	func configureView() {
		regionLabel.text	= R.string.localizable.region().uppercaseString
		languageLabel.text	= R.string.localizable.language()
		languagesLabel.text = R.string.localizable.not_selected()
		genderLabel.text	= R.string.localizable.gender()
		levelLabel.text		= R.string.localizable.level().uppercaseString
		statusLabel.text	= R.string.localizable.status().uppercaseString

		sexSegmentedControl.setTitle(R.string.localizable.all(), forSegmentAtIndex: 0)
		sexSegmentedControl.setTitle(R.string.localizable.female(), forSegmentAtIndex: 1)
		sexSegmentedControl.setTitle(R.string.localizable.male(), forSegmentAtIndex: 2)
		statusButton.setTitle(R.string.localizable.all(), forState: .Normal)

	}
    
    func doneSearchFilters() {
        self.dismissViewControllerAnimated(true) { [unowned self] in
            self.searchableDelegate?.updateSearchWithParams();
        }
    }
    
    func configureSlider() {
        levelSlider.delegate = self;
        levelSlider.tintColor = UIColor(named: .EventSeparatorLine);
        levelSlider.tintColorBetweenHandles = UIColor(named: .LoginButtonNormal);
        levelSlider.step = 1;
        levelSlider.maxValue = 100;
        levelSlider.minValue = 1;
        levelSlider.selectedMinimum = 1;
        levelSlider.selectedMaximum = 100;
    }
    
    func cancel() {
        dismissViewControllerAnimated(true) {};
    }
    
    private func addControlsButton() {
        
        let leftBarButtomItem = UIBarButtonItem(title: R.string.localizable.cancel(), style: .Plain, target: self, action: #selector(cancel));
        leftBarButtomItem.tintColor = UIColor(named: .DoneButtonEnable)
        self.navigationItem.leftBarButtonItem = leftBarButtomItem;
        
        let rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.done(), style: .Plain, target: self, action: #selector(doneSearchFilters));
        rightBarButtonItem.tintColor = UIColor(named: .DoneButtonEnable)
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    @IBAction func segmentControlAction(sender: AnyObject) {
        
        guard let segmentedControl = sender as? UISegmentedControl else {
            return;
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            advancedSearchViewModel?.gender.value = 0;
            break;
        case 1:
            advancedSearchViewModel?.gender.value = 1;
            break;
        default:
            advancedSearchViewModel?.gender.value = 2;
            break;
        }
    }
    
    @IBAction func changeSearchStatus(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        alertController.view.tintColor = UIColor(named: .LoginButtonNormal);
        
        let allAction = UIAlertAction(title: R.string.localizable.all(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.All.rawValue;
            self.setStatusTitle(R.string.localizable.all())
        });
        let offlineAction = UIAlertAction(title: R.string.localizable.offline(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Offline.rawValue;
            self.setStatusTitle(R.string.localizable.offline())
        });
        let onlineAction = UIAlertAction(title: R.string.localizable.offline(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Online.rawValue;
            self.setStatusTitle(R.string.localizable.offline())
        });
        let searchingAction = UIAlertAction(title: R.string.localizable.searching(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Searching.rawValue;
            self.setStatusTitle(R.string.localizable.searching())
        });
        let watchingAction = UIAlertAction(title: R.string.localizable.watching(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Watching.rawValue;
            self.setStatusTitle(R.string.localizable.watching())
        });
        let playingAction = UIAlertAction(title: R.string.localizable.playing(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Playing.rawValue;
            self.setStatusTitle(R.string.localizable.playing())
            
        });
        let talkingAction = UIAlertAction(title: R.string.localizable.talking(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.advancedSearchViewModel?.status.value = UserStatus.Talking.rawValue;
            self.setStatusTitle(R.string.localizable.talking())
            
        });
        
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .Destructive, handler: nil);
        
        alertController.addAction(allAction);
        alertController.addAction(offlineAction);
        alertController.addAction(onlineAction);
        alertController.addAction(searchingAction);
        alertController.addAction(watchingAction);
        alertController.addAction(playingAction);
        alertController.addAction(talkingAction);
        alertController.addAction(cancelAction);
        
        self.presentViewController(alertController, animated: true) {
            
        }
    }
    
    @IBAction func openLanguageViewController(sender: AnyObject) {
        if let languageViewController = presenter.getLanguageController() {
            self.navigationController?.pushViewController(languageViewController, animated: true);
            languageViewController.delegate = self;
        }
    }
    
    func setLanguages(languages: [LanguageEntity]) {
        self.advancedSearchViewModel?.languages.value.removeAll();
        for (_, language) in languages.enumerate() {
            self.advancedSearchViewModel?.languages.value.append(language.id);
        }
        
        languagesLabel.text = languages.map{ $0.displayName }.joinWithSeparator(", ");
        self.languages = languages;
    }
    
    //MARK TTRangeSliderDelegate
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        advancedSearchViewModel?.level.value = (Int(selectedMinimum), Int(selectedMaximum));
    }
    
    private func setStatusTitle(text:String) {
        statusButton.setTitle(text, forState: .Normal);
        statusButton.setTitle(text, forState: .Selected);
        statusButton.setTitle(text, forState: .Highlighted);
    }
}
