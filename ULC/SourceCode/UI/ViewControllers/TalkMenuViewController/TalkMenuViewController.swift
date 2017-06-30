//
//  TalkMenuViewController.swift
//  ULC
//
//  Created by Vitya on 9/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import REFrostedViewController
import MBProgressHUD
import ReactiveCocoa

class TalkMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var randomImageView: UIImageView!
    @IBOutlet weak var randomLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var randomView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var wsTalkViewModel: WSTalkViewModel!
    var wsTalkSessionInfo: TalkSessionsResponseEntity?
    var messageAlertController: UIAlertController?
    
    private let advancedSearchViewModel = AdvancedSearchViewModel()
    private var isUserSearching = false
    private var progressView: STLoadingGroup?
    
    @IBAction func closeButtonAction(sender: AnyObject) {
        closeMenu()
    }
    
    //MARK:- private properties
    private var isSearchIcomHide = false
    private var selectedUserInformation = UserEntity()
    private let customAlertMessageController = CustomMessageAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configureTableView()
        configureViews()
        configureGradientRingLayer()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSignals()
        wsTalkViewModel.resume()
        updateViewConstraints()
        
        if isUserSearching {
            progressView?.resumeLoading()
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FollowCell.self)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(named: .SessionLightGreyColor)
    }
    
    private func configureViews() {
        //MARK:- search only online users
        advancedSearchViewModel.status = MutableProperty(UserStatus.Online.rawValue)
        
        let randomTalkRecognizer = UITapGestureRecognizer(target: self, action: #selector(randomTalkAction))
        randomView.addGestureRecognizer(randomTalkRecognizer)
        randomView.backgroundColor = UIColor(named: .SessionLightGreyColor)
        
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.layer.cornerRadius = 5
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
		closeButton.setTitle(R.string.localizable.close(), forState: .Normal)
        
        hideTableView(true)
        
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 5
        searchTextField.backgroundColor = UIColor(named: .SessionSendViewColor)
		searchTextField.placeholder = R.string.localizable.username()
        view.backgroundColor = UIColor(named: .SessionLightGreyColor)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(orientationChanged),
                                                         name: UIDeviceOrientationDidChangeNotification,
                                                         object: nil)


		informationLabel.text = R.string.localizable.enter_user_name_or_invite_random_user()

		randomLabel.text = R.string.localizable.random()
    }
    
    private func configureGradientRingLayer() {
        progressView = STLoadingGroup(side: randomImageView.height - 10, style: .zhihu)
        progressView?.show(randomImageView)
    }
    
    func configureSignals() {
        searchTextField.rac_text.signal.observeNext { [unowned self] text in
            self.startProducer(text)
            self.hideTableView(text.isEmpty)
        }
        
        //MARK:- ws signals
        wsTalkViewModel.findTalkPartnerHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                if let message = observer.value {
                    self.progressView?.startLoading()
                    self.messageAlertController = self.showAlertMessage("", message: message.message, completitionHandler: nil);
                    self.isUserSearching = true
                    self.randomLabel.text = R.string.localizable.cancel()
                }
        }
        
        wsTalkViewModel.cancelFindTalkPartnerHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                if let message = observer.value {
                    self.progressView?.stopLoading()
                    self.messageAlertController = self.showAlertMessage("", message: message.message, completitionHandler: nil);
                    self.isUserSearching = false
                    self.randomLabel.text = R.string.localizable.random()
                }
        }
        
        wsTalkViewModel.inviteToTalkHandler.signal
            .observeOn(UIScheduler())
            .observeResult  { [unowned self] observer in
                guard let message = observer.value else {
                    return
                }
                
                self.view.endEditing(true)
                
                if message.result == WSInviteToTalkResult.OK.rawValue {
                    self.customAlertMessageController.showUserAlertMessage(self.selectedUserInformation,
                        message: message,
                        resultStatus: .SendedInvite)
                } else {
                    self.messageAlertController = self.showAlertMessage("", message: message.message, completitionHandler: nil);
                }
        }
        
        wsTalkViewModel.talkAddedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                self.customAlertMessageController.removeController()
                self.messageAlertController?.dismissViewControllerAnimated(true, completion: nil)
                self.closeMenu()
                self.isUserSearching = false
                self.progressView?.stopLoading()
                self.randomLabel.text = R.string.localizable.random()
        }
    }
    
    func randomTalkAction(gesure: UITapGestureRecognizer) {
        if isUserSearching {
            wsTalkViewModel.cancelFindTalkPartner()
        } else {
            wsTalkViewModel.findTalkPartner()
        }
    }
    
    func orientationChanged(notification: NSNotification) {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == .Portrait && (searchTextField.text?.isEmpty)! {
            searchIconImageView.hidden = false
            
        } else if orientation == .LandscapeLeft || orientation == .LandscapeRight {
            searchIconImageView.hidden = true
        }
    }
    
    private func startProducer(text:String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        advancedSearchViewModel.fetchUsersProfiles(text)
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [unowned self] (observer, disposable) in
                observer.observeCompleted {
                    self.tableView.reloadData();
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
                }
                
                observer.observeFailed { [unowned self] (_) in
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
                }
        }
    }
    
    private func hideTableView(hide: Bool) {
        tableView.hidden = hide
        informationLabel.hidden = !hide
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if orientation == .LandscapeLeft || orientation == .LandscapeRight{
            searchIconImageView.hidden = true
        } else {
            searchIconImageView.hidden = !hide
        }
    }
    
    //MARK UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK TableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return advancedSearchViewModel.usersProfile.value?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FollowCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.userNameLabel.backgroundColor = UIColor.clearColor()
        cell.userLevelLabel.backgroundColor = UIColor.clearColor()
        
        if let model = advancedSearchViewModel.usersProfile.value?[indexPath.row] {
            cell.updateViewWithModel(model);
            cell.setCellBackgroundColor(UIColor(named: .SessionLightGreyColor))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  let model = advancedSearchViewModel.usersProfile.value?[indexPath.row],
            let categoryId = wsTalkSessionInfo?.category {
            
            wsTalkViewModel.inviteToTalkSession(model.id, category: categoryId)
            selectedUserInformation = model
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        randomView.snp_updateConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(view).offset(35)
        }
    }
}
