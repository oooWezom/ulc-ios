//
//  SettingsViewController.swift
//  ULC
//
//  Created by Vitya on 7/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import MBProgressHUD
import ReactiveCocoa

enum SettingSegmentNumber: Int {
    case AboutInfo
    case Account
    case Region
    case Gender
    case BlackList
    case PushNotification
	case Agreement
    case LogOut
}

enum AccountInformation: Int {
    case Login
    case Password
    case PrivateAccount
}

struct SettingName {
    static var Login              = R.string.localizable.login()
    static var Password           = R.string.localizable.password()
    static var PrivateAccount     = R.string.localizable.private_account()
    static var Language           = R.string.localizable.language()
    static var BlackList          = R.string.localizable.black_list()
    static var PushNotification   = R.string.localizable.push_notifications()
	static var Agreement		  = R.string.localizable.agreement_settings_placeholder()
    static var LogOut             = R.string.localizable.log_out()
    
    static var About              = "\(R.string.localizable.about()):"
    static var Account            = R.string.localizable.account().uppercaseString
    static var Region             = R.string.localizable.region().uppercaseString
    static var Gender             = R.string.localizable.gender().uppercaseString
}

class SettingsViewController: CurrentUserProfileViewController, UITextViewDelegate, LanguageDelegate, SettingSwitchCellDelegate, SettingSegmentControlCellDelegate {
    
    // MARK private properties
    private let aboutUserTextField = UITextView()
    private let presenter = PresenterImpl()
    
    private let userData = UserInfo()
    private var languagesObjects = [LanguageEntity]()
    
    private var languageViewModel = LanguagesViewModel()
    private let loginViewModel: Logining = {
        let value = LoginViewModel()
        return value;
    }()
    
    override var title: String? {
        get {
            return R.string.localizable.settings()
        }
        set { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachSignals();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        ulcButton.hidden = true;
        self.navigationController?.navigationBar.translucent = true;
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    private func attachSignals() {
        
        userProfileViewModel.userEntity.producer.startWithNext { [weak self] (user: UserEntity?) in
            guard let user = user else {
                return;
            }
            
            self?.aboutUserTextField.text = user.aboutInfo
            self?.userHeaderView.userNameTextField.text = user.name
            
            self?.userData.updateDataWithModel(user)
            self?.getUserLanguagesFromDataBase()
            
            self?.tableView.reloadData()
        }
    }
    
    override func configureViews() {
        super.configureViews();
        
        let rightButton = UIBarButtonItem(title: R.string.localizable.done(), style: .Plain, target: self, action: #selector(saveSettings));
        rightButton.tintColor = UIColor(named: .DoneButtonEnable)
        
        self.navigationItem.rightBarButtonItem = rightButton;
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.navigationController?.hidesBarsOnSwipe = false
        
        aboutUserTextField.backgroundColor = UIColor.whiteColor()
        aboutUserTextField.font = UIFont.systemFontOfSize(20)
        aboutUserTextField.delegate = self
        
        userHeaderView.userNameTextField.hidden = false
        
        addMenuButton()
        self.ulcButton.hidden = true
    }
    
    override func configureTableView() {
        
        self.tableView.showsVerticalScrollIndicator = false
        
        tableView.register(SettingCell.self)
        tableView.register(SettingSegmentControlCell.self)
        tableView.register(SettingSwitchCell.self);
        
        tableView.tableHeaderView = userHeaderView;
        circleAvatarView.clipsToBounds = false;
        self.view.addSubview(circleAvatarView);
        circleAvatarView.layer.zPosition = 1;
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 3 : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = SettingSegmentNumber(rawValue: indexPath.section), let row = AccountInformation(rawValue: indexPath.row)
            else { return tableView.dequeueReusableCell(forIndexPath: indexPath) as SettingCell}
        
        switch section {
            
        case .AboutInfo:
            return settingCellForRowAtIndexPath(tableView,
                                                indexPath: indexPath,
                                                settingName: "",
                                                settingParameter: nil)
            
        case .Account:
            switch row {
            case .Login:
                return settingCellForRowAtIndexPath(tableView,
                                                    indexPath: indexPath,
                                                    settingName: SettingName.Login,
                                                    settingParameter: self.userData.login)
                
            case .Password:
                return settingCellForRowAtIndexPath(tableView,
                                                    indexPath: indexPath,
                                                    settingName: SettingName.Password,
                                                    settingParameter: R.string.localizable.change())
                
            case .PrivateAccount:
                return settingSwitchCellForRowAtIndexPath(tableView,
                                                          indexPath: indexPath,
                                                          settingName: SettingName.PrivateAccount,
                                                          id: SettingSwitchCellId.PrivateAccount,
                                                          switchStatus: self.userData.accountStatusID)
            }
            
        case .Region:
            return settingCellForRowAtIndexPath(tableView,
                                                indexPath: indexPath,
                                                settingName: SettingName.Language,
                                                settingParameter: self.userData.allLanguagesName)
            
        case .Gender:
            return settingSegmentCellForRowAtIndexPath(tableView,
                                                       indexPath: indexPath,
                                                       sex: userData.sex)
            
        case .BlackList:
            return settingCellForRowAtIndexPath(tableView,
                                                indexPath: indexPath,
                                                settingName: SettingName.BlackList,
                                                settingParameter: nil)
            
        case .PushNotification:
            return settingSwitchCellForRowAtIndexPath(tableView,
                                                      indexPath: indexPath,
                                                      settingName: SettingName.PushNotification,
                                                      id: SettingSwitchCellId.PushNotificztion,
                                                      switchStatus: nil)
            
        case .LogOut:
            return settingCellForRowAtIndexPath(tableView,
                                                indexPath: indexPath,
                                                settingName: SettingName.LogOut,
                                                settingParameter: nil)

		case .Agreement:
			return settingCellForRowAtIndexPath(tableView,
			                                    indexPath: indexPath,
			                                    settingName: SettingName.Agreement,
			                                    settingParameter: nil)

        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingSegmentNumber(rawValue: section) else { return nil}
        let sectionHeader = SettingHeaderView.instanciateFromNib()
        
        switch section{
        case .AboutInfo:
            sectionHeader.backgroundColor = UIColor.whiteColor()
            sectionHeader.headerNameLabel.textColor = UIColor.lightGrayColor()
            sectionHeader.headerNameLabel.text = SettingName.About
            
        case .Account:
            sectionHeader.headerNameLabel.text = SettingName.Account
            
        case .Region:
            sectionHeader.descriptionLabel.text = R.string.localizable.setting_message()
            sectionHeader.headerNameLabel.text = SettingName.Region
            
        case .Gender:
            sectionHeader.headerNameLabel.text = SettingName.Gender
            
        default:
            sectionHeader.headerNameLabel.text = ""
        }
        
        return sectionHeader
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 0 ? 0 : 50;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = SettingSegmentNumber(rawValue: section) else { return 25}
        
        switch section {
        case .Region:
            return 100
        case .Account, .Gender:
            return 40
        default:
            return 25
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = SettingSegmentNumber(rawValue: section) else { return nil}
        return section == .AboutInfo ? aboutUserTextField : nil
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 100 : 0
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard let section = SettingSegmentNumber(rawValue: indexPath.section), let row = AccountInformation(rawValue: indexPath.row)
            else { return }
        
        switch section {
        case .Account:
            
            switch row {
            case .Login:
                // userProfileViewModel.openChangeLoginVC()
                break
            case .Password:
                userProfileViewModel.openChangePasswordVC()
            case .PrivateAccount:
                break
            }
            
        case .Region:
            if let languageViewController = presenter.getLanguageController() {
                languageViewController.delegate = self
                languageViewController.selectedLanguages = self.languagesObjects
                presenter.pushWithViewController(languageViewController)
            }
            
        case .BlackList:
            userProfileViewModel.openBlackListVC()
            
        case .LogOut:
            logOut()

		case .Agreement:
			userProfileViewModel.openAgreementVC()
			break

        default:
            return
        }
    }
    
    // MARK: - Scroll view delegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
    
    func saveSettings() {
        guard let userName = self.userHeaderView.userNameTextField.text,
            let aboutUser = self.aboutUserTextField.text else {
            return
        }
        
        userProfileViewModel.updateProfileData(userName,
            sex: self.userData.sex,
            about: aboutUser,
            languages: self.userData.languagesId,
            blockMessages: false,
            blockAccount: false,
            privateData: self.userData.privateAccount)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .start { [weak self] observer in
                
                switch(observer.event) {
                case .Completed:
                    self?.showAlertMessage(R.string.localizable.success(), message: R.string.localizable.changes_have_been_successfully_saved(), completitionHandler: nil);
                    self?.aboutUserTextField.endEditing(true);
                case .Failed(let error):
                    self?.showULCError(error);
                    break
                default:
                    break;
                }
        }
    }
    
    private func logOut() {

        let alert = UIAlertController(title: R.string.localizable.are_you_sure(), message: R.string.localizable.logout_alert_description(), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Default, handler: { [weak self] action in
            
            let tmpView = self?.tableView.superview;
            MBProgressHUD.showHUDAddedTo(tmpView, animated: true);
            
            self?.loginViewModel.logOut().start { observer in
                
                switch(observer.event) {
                    
                case .Completed:
                    self?.userProfileViewModel.presentLoginVC()
                    MBProgressHUD.hideAllHUDsForView(tmpView, animated: true);
                    
                case .Failed(let error):
                    MBProgressHUD.hideAllHUDsForView(tmpView, animated: true);
                    self?.showULCError(error)
                    
                default:
                    break;
                }}
            }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(named: .OkButtonNormal)
    }
    
    private func settingCellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath, settingName: String, settingParameter: String?) -> UITableViewCell {
        let cell: SettingCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.updateVeiwWithData(settingName, settingParameter: settingParameter)
        
        return cell
    }
    
    private func settingSwitchCellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath, settingName: String, id: SettingSwitchCellId, switchStatus: Int?) -> UITableViewCell {
        let cell: SettingSwitchCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.updateVeiwWithData(settingName, id: id, switchStatus: switchStatus)
        cell.cellDelegate = self
        
        return cell
    }
    
    private func settingSegmentCellForRowAtIndexPath(tableView: UITableView, indexPath: NSIndexPath, sex: Int) -> UITableViewCell {
        let cell: SettingSegmentControlCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = .None
        cell.setUserSex(sex)
        cell.cellDelegate = self
        
        return cell
    }
    
    private func getUserLanguagesFromDataBase() {
        self.languagesObjects.removeAll()
        
        if let languages = languageViewModel.fetchLanguagesByIds(self.userData.languagesId) {
            languagesObjects = languages
            
            let namesArray = languages.map( { $0.displayName })
            self.userData.allLanguagesName =  namesArray.joinWithSeparator(", ")
        }
    }
    
    // MARK delegate methods
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func setLanguages(languages: [LanguageEntity]) {
        self.userData.allLanguagesName = languages.map{ $0.displayName }.joinWithSeparator(", ");
        self.userData.languagesId = languages.map { $0.id };
        getUserLanguagesFromDataBase()
        
        tableView.reloadData();
    }
    
    func didChangeSwitchState(sender: SettingSwitchCell, isOn: Bool) {
        switch sender.id {
            
        case .PrivateAccount:
            self.userData.privateAccount = isOn
            break
            
        case .PushNotificztion:
            if isOn {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.localNotificationKey)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.localNotificationKey)
            }
            break
        }
    }
    
    func didChangeSegmentControlState(sender: SettingSegmentControlCell, sex: Int) {
        self.userData.sex = sex
    }
}
