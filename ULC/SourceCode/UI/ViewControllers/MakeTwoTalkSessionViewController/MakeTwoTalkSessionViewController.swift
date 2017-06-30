//
//  MakeTwoTalkSessionViewController.swift
//  ULC
//
//  Created by Vitya on 8/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MBProgressHUD

class MakeTwoTalkSessionViewController: WSBaseViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var sessionNameTextField: UITextField!
    
    @IBOutlet weak var talkCategotyCollectionView: UICollectionView!
    @IBOutlet weak var chooseCategoryLabel: UILabel!
    
    //Mark - Private properties
    private var talkCategory = [TalkCategory]()
    private var selectedTalkCategoryId: Int?
    private var rightButton = UIBarButtonItem()
    private var progressIndicator = MBProgressHUD()
    
    lazy var presenter: Presenter = PresenterImpl();
    
    private let categoryViewModel:Categoring = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureCollectionView()
        configureDataBase()
        configureSignals()
    }
    
    private func configureView() {
        
        rightButton = UIBarButtonItem(title: R.string.localizable.start(), style: .Plain, target: self, action: #selector(startTwoTalk));
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(named: .DoneButtonDisable)], forState: .Disabled)
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(named: .DoneButtonEnable)], forState: .Normal)
        rightButton.enabled = false
        
        navigationItem.rightBarButtonItem = rightButton;
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        title = R.string.localizable.make_two_talk_session()
        
        sessionNameTextField.tintColor = UIColor(named: .NavigationBarColor)
        sessionNameTextField.delegate = self

        sessionNameTextField.placeholder = R.string.localizable.session_name_placeholder()
        chooseCategoryLabel.text = R.string.localizable.choose_category().uppercaseString
    }
    
    func configureCollectionView() {
        talkCategotyCollectionView.register(TwoTalkTableViewCell.self)
        talkCategotyCollectionView.delegate = self
        talkCategotyCollectionView.dataSource = self
        talkCategotyCollectionView.allowsSelection = true
    }
    
    func configureDataBase() {
        if let category = categoryViewModel.fetchTalkCategoryFromDB() {
            talkCategory = category
        }
    }
    
    private func configureSignals() {
        weak var weakSelf = self;
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                weakSelf?.observeUserProfile();
                weakSelf?.userProfileViewModel.loadUserDataProfile(0).start();
        }
        
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { [weak self] (_) in
                guard let strongSelf = self else {
                    return
                }
                
                if strongSelf.view.window != nil  {
                    strongSelf.observeUserProfile();
                    strongSelf.userProfileViewModel.loadUserDataProfile(0).start();
                }
        }
        
        // MARK:- WS signals
        wsProfileViewModel.createTalkResultHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if let _ = self?.selectedTalkCategoryId {
                    self?.rightButton.enabled = true
                }
                self?.progressIndicator.hide(true)
        }
        observeUserProfile();
        userProfileViewModel.loadUserDataProfile(0).start();
    }
    
    func startTwoTalk() {
        rightButton.enabled = false
        
        progressIndicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        progressIndicator.hide(true, afterDelay: 5)
        
        if let categoryId = selectedTalkCategoryId, let sessionName = sessionNameTextField.text {
            wsProfileViewModel.createTwoTalk(categoryId, name: sessionName)
        }
    }
    
    private func observeUserProfile() {
        userProfileViewModel.userEntity
            .producer
            .takeUntilViewControllerDisappears(self)
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (user: UserEntity?) in
                guard let user = user, let status = UserStatus(rawValue: user.status) else {
                    return;
                }
                if status != .Talking {
                    return;
                }
                if let talk = user.talk where status == .Talking {
                    self?.showAlertMessage("", message: R.string.localizable.current_talk(), completitionHandler: { _ in
                        if let strongSelf = self {
                            if strongSelf.view.window != nil && strongSelf.isViewLoaded() {
                                strongSelf.wsProfileViewModel.createTwoTalk(talk.category, name: talk.name);
                            }
                        }
                    })
                }
        }
    }

    //MARK - UICollectionViewDataSource, UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return talkCategory.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: TwoTalkTableViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.updateViewWithModel(talkCategory[indexPath.row]);
        cell.circleMaskImageView.hidden = !cell.selected
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let collectionViewWidth = talkCategotyCollectionView.width
        return CGSize(width: collectionViewWidth / 4, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TwoTalkTableViewCell
        cell.circleMaskImageView.hidden = false
        selectedTalkCategoryId = talkCategory[indexPath.row].id
        
        rightButton.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TwoTalkTableViewCell
        cell?.circleMaskImageView.hidden = true
    }
    
    //MARK: - UITextField delegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    deinit {
        debugPrint("MakeTwoTalkSessionViewController deinit")
    }
}
