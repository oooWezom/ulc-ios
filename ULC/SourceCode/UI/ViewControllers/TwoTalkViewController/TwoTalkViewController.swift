//
//  TwoTalkViewController.swift
//  ULC
//
//  Created by Vitya on 8/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MBProgressHUD

class TwoTalkViewController: WSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, FilterTwoTalkDelegate {
    
    @IBOutlet weak var topPlaceholderView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var talkSessionCountLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var categoriesIconCollectionView: UICollectionView!
    @IBOutlet weak var currentSessionsCollectionView: UICollectionView!
    
    //Mark - Private properties
    private let refreshControl          = UIRefreshControl()
    private var makeTwoTalkView         = MakeTwoTalkView.instanciateFromNib()
    private var filterTwoTalkView       = FilterTwoTalkView.instanciateFromNib()
    private var selectedTalkCategoryId  = 0
    private var timer:NSTimer!;
    
    private let viewModel = TwoTalkViewModel()
    
    @IBAction func twoTalkButtonAction(sender: AnyObject) {
        filterViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureNavigationBar()
        addNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        attachSignals()
        startUpdateTalksList()
        
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopUpdateTalksList()
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func configureCollectionView() {
        
        categoriesIconCollectionView.delegate = self
        categoriesIconCollectionView.dataSource = self
        categoriesIconCollectionView.register(TalkCategoryIconCell.self)
        categoriesIconCollectionView.allowsSelection = true
        
        currentSessionsCollectionView.delegate = self
        currentSessionsCollectionView.dataSource = self
        currentSessionsCollectionView.register(TwoTalkTwoStreamersCell.self)
        currentSessionsCollectionView.register(TwoTalkOneStreamerCell.self)
        currentSessionsCollectionView.insideTopBy(10)
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: .ValueChanged)
        currentSessionsCollectionView.addSubview(refreshControl)
    }
    
    func configureNavigationBar() {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.Plain, target:nil, action:nil)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let topViewgesture = UITapGestureRecognizer(target: self, action: #selector(self.topViewAction(_:)))
        topView.addGestureRecognizer(topViewgesture)
        
        if let menuImage = R.image.menu_main_icon(),
            let expandImage = R.image.expand_icon() {
            
            addLeftBarButtonWithImage(menuImage)
            indicatorImageView.image = expandImage
        }
        
        filterTwoTalkView.delegate = self
        
        topPlaceholderView.addSubview(makeTwoTalkView)
        makeTwoTalkView.frame = topPlaceholderView.bounds
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.makeSession(_:)))
        makeTwoTalkView.makeTwoTalkSessionView.addGestureRecognizer(gesture)
    }
    
    private func addNotifications() {
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
    }
    
    private func attachSignals() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        loadTalkSessions()
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
    
    func topViewAction(sender: UITapGestureRecognizer) {
        filterViews()
    }
    
    func startUpdateTalksList() {
        timer = NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: #selector(self.reloadCells), userInfo: nil, repeats: true)
    }
    
    func stopUpdateTalksList() {
        timer.invalidate()
    }
    
    func filterViews() {
        if let _ = makeTwoTalkView.superview, let collapseImage = R.image.collapse_icon() {
            filterTwoTalkView.frame = topPlaceholderView.bounds
            makeTwoTalkView.removeFromSuperview()
            topPlaceholderView.addSubview(filterTwoTalkView)
            indicatorImageView.image = collapseImage
            
        } else if let expandImage = R.image.expand_icon() {
            filterTwoTalkView.removeFromSuperview()
            topPlaceholderView.addSubview(makeTwoTalkView)
            indicatorImageView.image = expandImage
        }
    }
    
    func makeSession(sender: UITapGestureRecognizer) {
        if let vc = R.storyboard.main.makeTwoTalkSessionViewController() {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        loadTalkSessions()
    }
    
    private func loadTalkSessions() {
        self.viewModel.loadActiveSessions(0)
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) in observer.observeCompleted {
                guard let strongSelf = self else {
                    return;
                }
                strongSelf.reload()
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    strongSelf.refreshControl.endRefreshing()
                }
                observer.observeFailed { _ in
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    self?.refreshControl.endRefreshing()
                }
        }
    }
    
    func reloadCells() {
        dispatch_after(1, dispatch_get_main_queue()) { [weak self] in
            self?.currentSessionsCollectionView.reloadData();
        }
    }
    
    // MARK: - Table view data source
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.isEqual(self.categoriesIconCollectionView) {
            return viewModel.talksCategory.value.count
        }
        
        if collectionView.isEqual(self.currentSessionsCollectionView) && viewModel.talksSession.value != nil {
            
            if selectedTalkCategoryId == 0 {
                return viewModel.talksSession.value!.count
            } else {
                return viewModel.talksSession.value!.filter{ $0.category == selectedTalkCategoryId }.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView.isEqual(self.currentSessionsCollectionView), let value = viewModel.talksSession.value {
            return  getTwoTalkCell(collectionView, indexPath: indexPath, value: value)
        } else {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TalkCategoryIconCell
            cell.updateViewWithModel(viewModel.talksCategory.value[indexPath.row])
            cell.roundIconImageView.hidden = !cell.selected
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView.isEqual(categoriesIconCollectionView) {
            
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TalkCategoryIconCell {
                cell.roundIconImageView.hidden = false
                selectedTalkCategoryId = viewModel.talksCategory.value[indexPath.row].id
                currentSessionsCollectionView.reloadData()
            }
            
        } else {
            
            if let value = viewModel.talksSession.value {
                let session = value[indexPath.row]
                if session.streamer?.id == viewModel.currentId {
                    //MARK:- reconnect to own session as streamer, left position
                    viewModel.openTalkContainerVC(session.id, message: session)
                } else if let linked = session.linked?.first where linked.streamer?.id == viewModel.currentId {
                    //MARK:- reconnect to own session as streamer, right position
                    wsProfileViewModel.createTwoTalk(1, name: "")
                } else {
                    //MARK:- open session as spectator
                    viewModel.openSpectatorTalkSessionVC(session, viewControllerType: .Normal);
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.isEqual(categoriesIconCollectionView) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TalkCategoryIconCell {
                cell.roundIconImageView.hidden = true
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.isEqual(currentSessionsCollectionView) {
            return CGSizeMake(collectionView.width * 0.5 - 10, collectionView.width * 0.5)
        } else {
            return CGSizeMake(60, 60)
        }
    }
    
    func placeholderText(count: Int) {
        if count == 0 {
            talkSessionCountLabel.text = ""
            emptyLabel.enabled = true
            emptyLabel.text = R.string.localizable.no_active_talk_sessions()
        } else {
            talkSessionCountLabel.text = count.roundValueAsString()
            emptyLabel.enabled = false
            emptyLabel.text = ""
        }
    }
    
    func reload(){
        if let sessions = viewModel.talksSession.value {
            placeholderText(sessions.count)
        } else {
            placeholderText(0)
        }
        currentSessionsCollectionView.reloadData();
    }
    
    func getTwoTalkCell(collectionView: UICollectionView, indexPath: NSIndexPath, value: [TalkSessionsResponseEntity]) -> UICollectionViewCell {
        
        var talks = value
        
        if selectedTalkCategoryId != 0 {
            talks = viewModel.talksSession.value!.filter { (talks : TalkSessionsResponseEntity) -> Bool in
                return talks.category == selectedTalkCategoryId
            }
        }
        
        if let linked = talks[indexPath.row].linked where linked.isEmpty {
            let oneStreamerCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TwoTalkOneStreamerCell
            oneStreamerCell.updateViewWithModel(talks[indexPath.row])
            return oneStreamerCell
            
        } else {
            let twoStreamersCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TwoTalkTwoStreamersCell
            twoStreamersCell.updateViewWithModel(talks[indexPath.row])
            return twoStreamersCell
        }
    }
    
    // MARK:- FilterTwoTalkDelegate methods
    func allSessionsClick() {
        categoriesIconCollectionView.selectItemAtIndexPath(nil, animated: true, scrollPosition: .None)
        selectedTalkCategoryId = 0
        categoriesIconCollectionView.reloadData()
        currentSessionsCollectionView.reloadData()
        
        filterViews()
    }
    
    func followSessionsClick() {
        filterViews()
    }
    
    deinit {
        debugPrint("TwoTalkViewController deinit")
    }
}
