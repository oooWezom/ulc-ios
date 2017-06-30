//
//  MenuViewController.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import RealmSwift
import REFrostedViewController
import ReactiveCocoa
import MBProgressHUD
import RSKImageCropper

class MenuViewController: UITableViewController, AvatarMenuChangeable {
    
    private let viewModel               = UserProfileViewModel();
    private let advancedSearchViewModel = AdvancedSearchViewModel();
    private var sourceType              = DataSourceType.MenuItems;
    private let imagePicker             = UIImagePickerController();
    
    //MARK Private properties
    private let searchController        = UISearchController(searchResultsController: nil)
    private let backgroundImageView     = UIImageView(image: R.image.menu_background_image());
    private var menuEntity: UserEntity! = nil;
    private var currentMenuIndex        = 0;
    
    private let globalSearchView        = UIView(frame: CGRectZero);
    private let advancedSearchView      = AdvancedSearchHeader.instanciateFromNib();
    private var token: NotificationToken! = nil;
    
    var maskRect = CGRectZero;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        addNotificationToken();
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        imagePicker.delegate = self
        configureTableView();
        configureSearchBar();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCounters()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.dismissKeyboard()
    }

    private func reloadUserCell() {
        if self.sourceType == .MenuItems {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.beginUpdates();
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
            self.tableView.endUpdates();
        }
    }
    
    private func addNotificationToken() {
        do {
            let realm = try Realm()
            realm.autorefresh = true;
            token = realm.objects(UserEntity.self)
                .filter(NSPredicate(format: "id == %d", viewModel.currentId))
                .addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in

                switch changes {
                    
                case .Update(let users, _, _, _):
                    if let user = users.first {
                        self?.menuEntity = user;
                        self?.reloadUserCell();
                    }
                    break;
                default:
                    break
                }})
        } catch{}
    }
    
    private func loadCounters() {
        
        viewModel.getCounters()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) -> () in
                
                observer.observeCompleted({
                    if let badgeCount = self?.viewModel.getFollowersAndMessagesCounters() {
                        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
                    }
                    self?.tableView.reloadData();
                })
                
                observer.observeFailed({ (let error) in
                })
        }
    }
    
    private func configureTableView() {
        
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        tableView.backgroundView = backgroundImageView;
        tableView.register(MenuCell.self)
        tableView.register(UserMenuCell.self);
        tableView.register(UserProfileCell.self);
        tableView.separatorStyle = .None;
        tableView.showsVerticalScrollIndicator = false;
        tableView.rowHeight = 50;
        
        configureTableHeaders();
    }
    
    private func configureTableHeaders() {
        let globalSearchLabel = UILabel();
        globalSearchLabel.textColor = UIColor.whiteColor();
        globalSearchLabel.text = R.string.localizable.global_search()
        globalSearchLabel.font = globalSearchLabel.font.fontWithSize(18);
        globalSearchLabel.sizeToFit();
        globalSearchLabel.backgroundColor = UIColor(named: .LoginButtonNormal);
        
        globalSearchView.frame = CGRectMake(0, 0, self.view.width, 32);
        globalSearchView.backgroundColor = UIColor(named: .LoginButtonNormal);
        
        globalSearchView.addSubview(globalSearchLabel);
        globalSearchLabel.x = 15;
        globalSearchLabel.yCenter = globalSearchView.yCenter;
        
        advancedSearchView.advancedButton.addTarget(self, action: #selector(openAdvancedSettingsVC), forControlEvents: .TouchUpInside);
    }
    
    func openAdvancedSettingsVC() {
        
        if let vc = R.storyboard.main.advancedSearchViewController() {
            if let topVC = UIApplication.topViewController() {
                vc.modalPresentationStyle = .OverCurrentContext
                vc.modalTransitionStyle = .CoverVertical
                vc.advancedSearchViewModel = advancedSearchViewModel;
                vc.searchableDelegate = self;
                let nav = UINavigationController(rootViewController: vc);
                topVC.presentViewController(nav, animated: true, completion: nil);
            }
        }
    }
    
    private func configureSearchBar() {
        
        searchController.searchBar.delegate = self;
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.backgroundImage = UIImage();
        searchController.searchBar.backgroundColor = UIColor(named: .NavigationBarColor)
        searchController.searchBar.tintColor = UIColor.whiteColor();
        searchController.searchBar.translucent = true;
    }
    
    //MARK TableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sourceType == .MenuItems ? 1 : 3;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 32;
        case 2:
            return 56;
        default:
            return 0;
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sourceType == .MenuItems {
            return 5;
        } else {
            if section == 1 {
                return advancedSearchViewModel.usersProfile.value?.count ?? 0;
            } else {
                return 0;
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 1:
            return globalSearchView;
        case 2:
            return advancedSearchView;
        default:
            return UIView(frame: CGRectZero);
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.sourceType == .MenuItems {
            
            if indexPath.row == 0 {
                let cell: UserMenuCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                if menuEntity != nil {
                    cell.delegate = self;
                    cell.updateViewWithModel(menuEntity);
                }
                return cell;
                
            } else {
                
                let cell: MenuCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                
                switch indexPath.row {
                case 1:
                    cell.nameLabel.text = R.string.localizable.follows()
                    cell.iconImageView.image = R.image.menu_follows_icon();
                    if let follows = viewModel.countersEntity.value?.followers {
                        cell.ubdateLabelCount(follows)
                    }
                case 2:
                    cell.nameLabel.text = R.string.localizable.messages()
                    cell.iconImageView.image = R.image.menu_messages_icon()
                    if let messages = viewModel.countersEntity.value?.messages {
                        cell.ubdateLabelCount(messages)
                    }
                case 3:
                    cell.nameLabel.text = R.string.localizable.newsfeed()
                    cell.iconImageView.image = R.image.menu_newsfeed_icon()
                case 4:
                    cell.nameLabel.text = R.string.localizable.settings()
                    cell.iconImageView.image = R.image.menu_setting_icon()
                default:
                    break
                }
                return cell;
            }
        } else {
            
            let cell:UserProfileCell = tableView.dequeueReusableCell(forIndexPath: indexPath);
            
            if let model = advancedSearchViewModel.usersProfile.value?[indexPath.row] {
                cell.updateViewWithModel(model);
            }
            return cell;
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if sourceType == .MenuItems {
            
            currentMenuIndex = indexPath.row;
            
            switch indexPath.row {
                
            case 0:
                viewModel.openUserProfileVC(0);
                break;
                
            case 1:
                viewModel.openFollows(0);
                break;
                
            case 2:
                viewModel.openMessagesVC();
                break;
                
            case 3:
                viewModel.openNewsFeed(0);
                break;
                
            case 4:
                viewModel.openSettingsVC();
                break;
                
            default:
                closeMenu();
                break;
            }
        } else {
            //Open user profile
            if let profiels = advancedSearchViewModel.usersProfile.value {
                let userProfile = profiels[indexPath.row];
                if userProfile.id == viewModel.currentId {
                    viewModel.openCurrentUserProfileVCFromMenu(userProfile.id)
                } else {
                    viewModel.openUserProfileVCFromMenu(userProfile.id);
                }
            }
        }
    }
    
    func openAvatarMenuDialog() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
        alertController.view.tintColor = UIColor(named: .LoginButtonNormal);
        
        let cameraAction = UIAlertAction(title: R.string.localizable.camera(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.imagePicker.sourceType = .Camera;
            self.openImageSource();
        });
        
        let galleryAction = UIAlertAction(title: R.string.localizable.gallery(), style: .Default, handler: {(action: UIAlertAction!) in
            self.imagePicker.sourceType = .PhotoLibrary;
            self.openImageSource();
        });
        
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .Destructive, handler: nil);
        
        alertController.addAction(cameraAction);
        alertController.addAction(galleryAction);
        alertController.addAction(cancelAction);
        
        viewModel.showAlertController(alertController);
    }
    
    private func openImageSource() {
        imagePicker.allowsEditing = false;
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    deinit {
        searchController.view.removeFromSuperview();
        if let token = token {
            token.stop();
        }
    }
}

//Mark UISearchBarDelegate Delegate
extension MenuViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        sourceType = .MenuItems;
        self.tableView.reloadData();
        advancedSearchViewModel.resetUsersProfiles();
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
}

//Mark UISearchResultsUpdating Delegate
extension MenuViewController: UISearchResultsUpdating {
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if !searchController.active {
            return;
        }
        
        guard let text = searchController.searchBar.text else {
            return;
        }
        
        startProducer(text);
    }
    
    private func startProducer(text:String) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        advancedSearchViewModel.fetchUsersProfiles(text)
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) in
                guard let strongSelf = self else {
                    return;
                }
                observer.observeCompleted({
                    strongSelf.sourceType = .UsersProfile;
                    strongSelf.tableView.reloadData();
                    MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true);
                })
                
                observer.observeFailed({ _ in
                    MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true);
                })
        }
    }
}

extension MenuViewController: AdvancedProfilesSearchable {
    func updateSearchWithParams() {
        if let text = searchController.searchBar.text {
            startProducer(text);
        }
    }
}

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        dismissViewControllerAnimated(true) { [unowned self] in
            
            let cropVC = RSKImageCropViewController(image: pickedImage, cropMode: .Custom)
            
            cropVC.delegate = self;
            cropVC.dataSource = self;
            
            guard   let containerVC = UIApplication.topViewController() as? ContainerViewController,
                    let contentVC = containerVC.contentViewController as? UINavigationController else {
                return;
            }
            self.closeMenu();
            contentVC.pushViewController(cropVC, animated: true);
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController) -> CGRect {
        
        let viewWidth = CGRectGetWidth(self.view.bounds);
        let viewHeight = CGRectGetHeight(self.view.bounds);
        
        let maskSize = CGSizeMake(300, 300)
        
        
        maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5, (viewHeight - maskSize.height) * 0.5, maskSize.width, maskSize.height);
        return maskRect;
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController) -> UIBezierPath {
        return UIBezierPath(ovalInRect: maskRect);
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        guard   let containerVC = UIApplication.topViewController() as? ContainerViewController,
                let contentVC = containerVC.contentViewController as? UINavigationController else {
                return;
        }
        contentVC.popToRootViewControllerAnimated(true);
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        MBProgressHUD.allHUDsForView(self.view);
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        guard let resultData = UIImagePNGRepresentation(croppedImage) else {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            return
        }
        let base64ImageData = resultData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0));
        self.viewModel
            .updateAvatarOrBackground(base64ImageData, backgorunUrlData: "")
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .startWithSignal { [weak self] (observer, disposable) in
            
            guard   let containerVC = UIApplication.topViewController() as? ContainerViewController,
                let contentVC = containerVC.contentViewController as? UINavigationController,
                let strongSelf = self else {
                    return;
            }
            
            observer.observeCompleted({
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                contentVC.popToRootViewControllerAnimated(true);
            })
            
            observer.observeFailed({ (_) in
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                contentVC.popToRootViewControllerAnimated(true);
            })
        }
    }
}
