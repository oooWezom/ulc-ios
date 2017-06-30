//
//  SessionInfoViewController.swift
//  ULC
//
//  Created by Alex on 8/30/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import KSYMediaPlayer
import Rswift
import REFrostedViewController

enum SessionViewType: Int {
    case OnePlayerSession
    case TwoPlayerSession
}

class SessionInfoViewController: UIViewController, SessionProtocolInfoable, FullScreenModeProtocol {
    
    let heightEventDescription:CGFloat = 66;
    private var screenType:ScreenSizeEvent = .WindowScreen;
    
    @IBOutlet weak var tableView: UITableView!
    
    let userProfileViewModel    = UserProfileViewModel();
    let messagesViewModel       = MessagesViewModel();
    let categoryViewModel       = CategoryViewModel();
    let wsProfileViewModel = WSProfileViewModel();
    
    var sessionType = SessionViewType.OnePlayerSession;
    let headerContentView = UIView();
    let fullscreenView = UIView();
    
    
    lazy var eventPlayer:EventPlayer = {
        let value = EventPlayer.instanciateFromNib();
        return value;
    }();
    
    lazy var eventHolderView:EventHolderView = {
        let value = EventHolderView.instanciateFromNib();
        return value;
    }();
    
    var event:SelfEvent! {
        didSet {
            self.loadUsersProfiles();
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if screenType == .FullScreen {
            return true
        }
        return false;
    }
    
    lazy var playEventBtn:UIButton = { [unowned self] in
        let button = UIButton();
        let playImage = R.image.preview_play_icon();
        button.setTitle("", forState: .Normal);
        button.setTitle("", forState: .Selected);
        button.setImage(playImage, forState: .Normal);
        button.setImage(playImage, forState: .Selected);
        button.setImage(playImage, forState: .Highlighted);
        button.addTarget(self, action: #selector(playEvent), forControlEvents: .TouchUpInside);
        if let image = playImage {
            button.width = image.size.width;
            button.height = image.size.height;
        }
        button.hidden = true;
        return button;
        }();
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        navigationItem.setHidesBackButton(true, animated: false);
        if let vc = UIApplication.containerViewController() as? REFrostedViewController {
            vc.panGestureEnabled = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let newFrame = CGRectMake(0, 0, view.width, (view.width * 0.75) + heightEventDescription);
        headerContentView.frame = newFrame;
        headerContentView.backgroundColor = UIColor.blackColor();
        addNotifications();
        addMenuButton();
        configureViews();
        addBackButton();
        addShareMenuButton();
        
        loadUsersProfiles();
        eventPlayer.configureSliders()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
    }
    
    func configureViews() {
        if event.typeId == EventType.TalkSession.rawValue {
            if !event.name.isEmpty {
                title = event.name
            } else {
                getCategory(event.category)
            }
        } else {
            title = R.string.localizable.session_info()
        }
        
        let backgroundView = UIView();
        backgroundView.backgroundColor = UIColor(named: .SessionInfoBackgroundColor);
        tableView.backgroundView = backgroundView;
        tableView.showsVerticalScrollIndicator = false;
        tableView.showsHorizontalScrollIndicator = false;
        tableView.tableFooterView = UIView(frame: CGRectZero);
        tableView.register(SessionInfoCell);
        tableView.separatorStyle = .None;
        
        self.navigationController?.hidesBarsOnTap = false;
        self.navigationController?.hidesBarsOnSwipe = false;
        self.navigationController?.navigationBarHidden = false;
        self.setNeedsStatusBarAppearanceUpdate();
        
        eventHolderView.frame = CGRectMake(0, view.width * 0.75, view.width, heightEventDescription);
        headerContentView.addSubview(eventHolderView);
        
        headerContentView.addSubview(playEventBtn);
        playEventBtn.centerWith(headerContentView);
        //playEventBtn.y = playEventBtn.y - (heightEventDescription * 0.5);
        playEventBtn.hidden = true;
    }
    
    func getCategory(byId: Int) {
        categoryViewModel.fetchCategory(byId)
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) in
                
                observer.observeResult { observer in
                    if let category = observer.value {
                        self?.title = category.name;
                    }
                }
        }
    }
    
    private func loadUsersProfiles() {
        userProfileViewModel.selfEvent
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithResult { [weak self] result in
                guard let event = result.value else { return }
                self?.playEventBtn.hidden = false;
                self?.eventHolderView.updateViewWithModel(event);
        }
        
        userProfileViewModel.loadEventsData(event.id)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .start();
        
        if let owner = event.owner {
            userProfileViewModel
                .loadUserDataProfile(owner.id)
                .takeUntil(self.rac_willDeallocSignalProducer())
                .start();
        }
        
        if let opponent = event.opponent {
            userProfileViewModel
                .loadUserDataProfile(opponent.id)
                .takeUntil(self.rac_willDeallocSignalProducer())
                .producer
                .observeOn(UIScheduler())
                .start { [weak self] observer in
                    if let value = observer.value {
                        self?.userProfileViewModel.updateOwnerWithUserEntity(value)
                        self?.tableView.reloadData()
                    }
            }
        }
        
        if let follower = event.following {
            userProfileViewModel
                .loadUserDataProfile(follower.id)
                .takeUntil(self.rac_willDeallocSignalProducer())
                .producer
                .observeOn(UIScheduler())
                .start { [weak self] observer in
                    
                    if let value = observer.value {
                        self?.userProfileViewModel.updateOwnerWithUserEntity(value)
                        self?.tableView.reloadData()
                    }
            }
        }
    }
    
    //MARK - SessionProtocolInfoable
    func openChatWithUser(cell: SessionInfoCell) {
        
        var entity:EventBaseEntity!;
        guard let indexPath = tableView.indexPathForCell(cell) else {
            return;
        }
        
        if indexPath.row == 0, let owner = event.owner {
            entity = owner;
        } else {
            if event.typeId == EventType.StartFollow.rawValue, let following = event.following {
                entity = following;
            } else if event.typeId == EventType.TalkSession.rawValue, let partner = event.partners.first {
                entity = partner;
            } else if let opponent = event.opponent {
                entity = opponent;
            }
        }
        
        if entity != nil {
            messagesViewModel.openMessagesViewController(entity);
        }
    }
    
    func followUser(cell: SessionInfoCell) {
        var user: Owner?
        var status: Int?
        
        if let opponent = event.opponent {
            user = opponent
            status = opponent.link
        }
        
        if let following = event.following {
            user = following
            status = following.link
        }
        
        if event.typeId == EventType.TalkSession.rawValue && tableView.indexPathForCell(cell)?.row == 0,
            let owner = event.owner {
            user = owner
            status = owner.link
        } else if let partner = event.partners.first {
            user = partner
            status = partner.link
        }
        
        if let user = user, let status = status {
            if status == FollowingStatus.Followed.rawValue {
                wsProfileViewModel.unfollowUser(user.id)
                userProfileViewModel.updateOwner(user, value: FollowingStatus.Unfollowed.rawValue)
                
                dispatch_async(dispatch_get_main_queue()) {
                    cell.followButton.imageView?.image = R.image.follow_session_icon()
                }
            } else {
                wsProfileViewModel.followUser(user.id)
                userProfileViewModel.updateOwner(user, value: FollowingStatus.Followed.rawValue)
                
                dispatch_async(dispatch_get_main_queue()) {
                    cell.followButton.imageView?.image = R.image.unfollow_session_icon()
                }
            }
        }
    }
    
    func playEvent() {
        guard let tmpEvent = userProfileViewModel.selfEvent.value, let playlist = tmpEvent.playlist else { return }
        eventPlayer.fullScrennDelegate = self;
        playEventBtn.removeFromSuperview();
        headerContentView.addSubview(eventPlayer);
        eventPlayer.play(playlist.name);
        
        let events = playlist.events
        let tmpArray = Array(events);
        var duration = 0;
        for i in tmpArray {
            duration += i.duration
        }
        eventPlayer.configureProgressSlider(duration)
        view.setNeedsUpdateConstraints();
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        
        if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            updateLandscapeConstrains();
        } else {
            updatePortrainConstrains();
        }
        if let _ = playEventBtn.superview {
            playEventBtn.centerWith(headerContentView);
            playEventBtn.y = playEventBtn.y - (heightEventDescription * 0.5);
        }
    }
    
    final func updatePortrainConstrains() {
        addBackButton();
        
        if screenType == .FullScreen {
            fullscreenView.frame = UIScreen.mainScreen().bounds;
            eventPlayer.removeFromSuperview();
            if let navigationView = navigationController?.view {
                navigationView.addSubview(eventPlayer);
            }
            if let s = eventPlayer.superview {
                eventPlayer.width = fullscreenView.width;
                eventPlayer.height = fullscreenView.height;
                eventPlayer.centerWith(s);
                eventPlayer.player.scalingMode = MPMovieScalingMode.AspectFit;
            }
        } else {
            if let _ = headerContentView.superview {
                headerContentView.frame = CGRectMake(0, 0, view.width, (view.width * 0.75) + heightEventDescription);
            }
            if let _ = eventPlayer.superview {
                eventPlayer.x = 0;
                eventPlayer.y = 0;
                eventPlayer.width = UIScreen.mainScreen().bounds.width;
                eventPlayer.height = UIScreen.mainScreen().bounds.width * 0.75;
                eventPlayer.player.scalingMode = MPMovieScalingMode.AspectFill;
            }
            if let _ = eventHolderView.superview {
                eventHolderView.frame = CGRectMake(0, view.width * 0.75, view.width, heightEventDescription);
            }
        }
    }
    
    final func updateLandscapeConstrains() {
        removeBackButton();
        fullscreenView.frame = UIScreen.mainScreen().bounds;
        
        if screenType == .FullScreen {
            if let _ = eventPlayer.superview {
                eventPlayer.size = fullscreenView.size;
                eventPlayer.y = 0;
                eventPlayer.centerWith(fullscreenView);
                eventPlayer.player.scalingMode = MPMovieScalingMode.AspectFit;
            }
        } else {
            if let _ = headerContentView.superview {
                headerContentView.frame = CGRectMake(0, 0, view.width, view.height + heightEventDescription);
            }
            if let _ = eventPlayer.superview {
                eventPlayer.width = view.height * 1.33;
                eventPlayer.height = view.height;
                eventPlayer.y = 0;
                eventPlayer.centerXWith(headerContentView);
                eventPlayer.player.scalingMode = MPMovieScalingMode.AspectFit;
            }
            if let _ = eventHolderView.superview {
                eventHolderView.frame = CGRectMake(0, view.height, view.width, heightEventDescription);
            }
        }
    }
    
    deinit {
        eventPlayer.releasePlayer()
    }
    
    func changeScreenSize(type: ScreenSizeEvent) {
        fullscreenView.backgroundColor = UIColor.blackColor();
        screenType = type;
        setNeedsStatusBarAppearanceUpdate();
        
        if type == .FullScreen {
            eventPlayer.removeFromSuperview();
            fullscreenView.addSubview(eventPlayer);
            if let navigationView = navigationController?.view {
                navigationView.addSubview(fullscreenView);
            }
        } else {
            eventPlayer.removeFromSuperview();
            fullscreenView.removeFromSuperview();
            headerContentView.addSubview(eventPlayer);
        }
        view.setNeedsUpdateConstraints();
    }
    
    private func addNotifications() {
        weak var weakSelf = self;
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                weakSelf?.eventPlayer.pause();
        }
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                weakSelf?.eventPlayer.resume();
        }
    }
    
    private func addShareMenuButton() {
        let rightBarButtonItem = UIBarButtonItem(image: R.image.menu_share_icon(), style: .Plain, target: self, action: #selector(showActivateServiceAlert))
        navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    func showShareMenu() {
        // TODO: change to main server
        let url = Constants.eventUrl + String(event.id)
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func showActivateServiceAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: R.string.localizable.close(), style: .Cancel, handler: nil))
        let shareAction = UIAlertAction(title: R.string.localizable.share_title(), style: .Default) { [weak self] action in
            self?.showShareMenu()
        }
        alert.addAction(shareAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
