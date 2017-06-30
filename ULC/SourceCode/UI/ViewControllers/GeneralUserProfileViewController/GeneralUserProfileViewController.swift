//
//  UserViewController.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import Kingfisher
import MBProgressHUD
import SnapKit
import Foundation

class GeneralUserProfileViewController: BaseEventViewController {

	var userProfileViewModel: UserProfileViewModel!;

	let circleAvatarView    = CircleAvatarView.instanciateFromNib();
	let userHeaderView      = UserProfileHeader.instanciateFromNib();
	let userRatingFooter    = UserProfileFooter.instanciateFromNib();
    
    var shouldShowMenuButton = false;

	override func viewDidLoad() {

		userProfileViewModel = UserProfileViewModel();
		userProfileViewModel.userID = userProfileID;

		super.viewDidLoad();
		bindSignals();
	}
    
	override func configureViews() {
		super.configureViews()
        
        configureStatusBar()

		if userProfileID == 0 {
			addMenuButton();
		} else {
			addBackButton();
		}
        
        if shouldShowMenuButton {
            addMenuButton();
        }
        
        userRatingFooter.followersButton.addTarget(self, action: #selector(openFollowers), forControlEvents: .TouchUpInside)
        userRatingFooter.followingButton.addTarget(self, action: #selector(openFollowing), forControlEvents: .TouchUpInside)
        userRatingFooter.gamesButton.addTarget(self, action: #selector(openGames), forControlEvents: .TouchUpInside)
        userRatingFooter.streamsButton.addTarget(self, action: #selector(openStreams), forControlEvents: .TouchUpInside)
	}

	override func configureTableView() {
		super.configureTableView()

		tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = userHeaderView;
        tableView.register(EventCell.self);
        
        circleAvatarView.clipsToBounds = false;
        self.view.addSubview(circleAvatarView);
        circleAvatarView.layer.zPosition = 1;
	}
    
    func openFollowers() {}
    
    func openFollowing() {}
    
    func openGames() {}
    
    func openStreams() {}
    
    private func configureStatusBar() {
        let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView
        if let statusBar = statusBar {
            statusBar.backgroundColor = UIColor.whiteColor()
        }
    }

	func refresh(refreshControl: UIRefreshControl) {
		MBProgressHUD.showHUDAddedTo(self.view, animated: true);
		loadEvents(false);
	}

	func bindSignals() {
        
		userProfileViewModel.userEntity
            .producer
            .observeOn(UIScheduler())
            .startWithNext { [weak self](user: UserEntity?) in
                guard let user = user else {
                    return;
                }
                self?.circleAvatarView.updateViewWithModel(user);
                self?.userRatingFooter.updateViewWithModel(user);
            
                self?.title = user.name
                // Set background image
                if !user.backgroundAvatarUrl.isEmpty {
                    self?.updateBackgroundImage(user.backgroundAvatarUrl);
                }
                self?.tableView.reloadData()
		}
        
        wsProfileViewModel.inviteToTalkRequestHandler.signal.observeResult { observer in
            guard let sender = observer.value else {
                    return;
            }
            Swift.debugPrint(sender)
        }

        self.userProfileViewModel.loadUserDataProfile(userProfileID)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (signal, disposable) in
                signal.observeFailed({ (error: ULCError) in
                    guard let strongSelf = self else {
                        return;
                    }
                    let forbitenView = ForbitenView.instanciateFromNib();
                    strongSelf.title = "";
                    forbitenView.errorLabel.text = error.description;
                    strongSelf.view.addSubview(forbitenView);
                    forbitenView.frame = strongSelf.view.bounds;
                    forbitenView.layer.zPosition = 2;
                    strongSelf.tableView.scrollEnabled = false;
                })
        }
        
        loadEvents(false);
        
        // MARK:- WS signals
        wsProfileViewModel.inviteToTalkResponseHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value, let strongSelf = self else {
                    return
                }
                switch message.result {
                case WSInviteToTalkResponseResult.AccepInvite.rawValue:
                    strongSelf.customAlertMessageController
                        .showUserAlertMessage(strongSelf.userProfileViewModel.userEntity.value, message: message, resultStatus: .AccepInvite)
                    break
                case WSInviteToTalkResponseResult.DenyInvite.rawValue:
                    strongSelf.customAlertMessageController
                        .showUserAlertMessage(strongSelf.userProfileViewModel.userEntity.value, message: message, resultStatus: .DenyInvite)
                    break
                case WSInviteToTalkResponseResult.DoNotDisturb.rawValue:
                    strongSelf.customAlertMessageController
                        .showUserAlertMessage(strongSelf.userProfileViewModel.userEntity.value, message: message, resultStatus: .DoNotDisturb)
                    break
                default:
                    break
            }
        }
    }
    
    final func updateBackgroundImage(stringUrl: String) {
        
        let imageCache = ImageCache.defaultCache;

		if let savedImage = imageCache.retrieveImageInDiskCacheForKey(stringUrl) {
			self.userHeaderView.headerImageView.image = savedImage
		} else {
            var defaultAvatarImage = UIImage.fromColor(UIColor(named: .LoginButtonNormal));
            if let tmpImage = userHeaderView.headerImageView.image {
                defaultAvatarImage = tmpImage;
            }
			let url = Constants.userContentUrl + stringUrl;
			let URL = NSURL(string: url)!
			let resource = Resource(downloadURL: URL, cacheKey: stringUrl)
			self.userHeaderView.headerImageView.kf_setImageWithResource(resource,
			                                                            placeholderImage: defaultAvatarImage,
			                                                            optionsInfo: [.BackgroundDecode],
			                                                            progressBlock: nil,
			                                                            completionHandler: { (image, error, cacheType, imageURL) in
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    if let image = image {
                        imageCache.storeImage(image, originalData: nil, forKey: stringUrl, toDisk: true, completionHandler: nil);
                    }
                })
			})
		}
	}

	override func updateViewConstraints() {
		super.updateViewConstraints();

		if circleAvatarView.superview != nil {
			circleAvatarView.snp_remakeConstraints { (make) in
				make.width.height.equalTo(150);
                make.top.equalTo(60);
				make.left.equalTo(25);
			}
		}
	}

	func loadEvents(newEvents: Bool = true) {

		tableView.tableFooterView = pagingSpinner
		pagingSpinner.startAnimating()

		userProfileViewModel
            .loadSelfEvents(newEvents)
            .takeUntil(self.rac_willDeallocSignalProducer())
			.producer
			.observeOn(UIScheduler())
			.startWithSignal({ [weak self](observer, disposable) -> () in

				observer.observeCompleted({
					self?.tableView.reloadData();

					self?.pagingSpinner.stopAnimating();
					self?.refreshControl?.endRefreshing()
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
				})
				observer.observeFailed({ [weak self] (error: ULCError) in
					self?.pagingSpinner.stopAnimating();
					self?.refreshControl?.endRefreshing()
				})
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self?.tableView.tableFooterView = nil;
                }
		})
	}

	// MARK: - Table view data source
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2;
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 0 : userProfileViewModel.selfEvents.value != nil ? userProfileViewModel.selfEvents.value!.count : 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: EventCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
		cell.updateViewWithModel(userProfileViewModel.selfEvents.value![indexPath.row])
		return cell
	}

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? userRatingFooter.getHeight() : 0
    }

	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return section == 0 ? userRatingFooter : nil;
	}

	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return indexPath.section == 0 ? 0 : 78;
	}
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let items = userProfileViewModel.selfEvents.value else {
            return
        }
        
        let event = items[indexPath.row];
        if event.typeId != EventType.StartFollow.rawValue {
            userProfileViewModel.openSessionInfoViewController(event);
        }
    }

	// MARK: - Scroll view delegate
	override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		if (scrollView.contentOffset.y + scrollView.bounds.size.height) >= scrollView.contentSize.height {
			self.loadEvents();
		}
	}

	// MARK: - UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
		return .None
	}
    
    deinit {
        Swift.debugPrint("DEINIT \(self)");
    }
}

