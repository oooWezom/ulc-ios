//
//  NewsFeedViewController.swift
//  ULC
//
//  Created by Alex on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import MBProgressHUD
import ReactiveCocoa
import Result

class NewsFeedViewController: BaseEventViewController {
    
    var newsFeedFilterViewModel: NewsFeedFiltering = NewsFeedFilterViewModel();
    
    var feedType = FeedType.All
    
    override func viewDidLoad() {
        super.viewDidLoad();
        fetchEvents();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        tableView.reloadData();
    }
    
    override func configureViews() {
        super.configureViews();
        
        self.title = R.string.localizable.newsfeed()

        if userProfileID == 0 {
            let rightButton = UIBarButtonItem(image: R.image.settings_icon(), style: .Plain, target: self, action: #selector(openFollwoingSetting));
            self.navigationItem.rightBarButtonItem = rightButton;
        }
        
        if userProfileID == newsFeedFilterViewModel.currentId  ||  userProfileID == 0 {
            addMenuButton();
        } else {
            addBackButton();
        }
        addRefreshControll();
    }

    override func configureTableView() {
        super.configureTableView();

        tableView.register(EventCell.self);
        tableView.rowHeight = 78;
        tableView.tableHeaderView = nil;
        tableView.alwaysBounceVertical = false;
        tableView.backgroundColor = UIColor(named: .EventCellBackgound);
    }

    override func refresh() {
        fetchAllEvents(false);
    }
    
    func openFollwoingSetting() {
        newsFeedFilterViewModel.openNewsFeedFilter();
    }
    
    private func fetchEvents() {
        newsFeedFilterViewModel.feedType = feedType;
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        switch feedType {
            
        case .All:
            fetchAllEvents(false);
            break;
            
        case .Games:
            fetchGamesEvetns(false);
            break;
            
        case .Talk:
            fetchTalkEvents(false);
            break;
            
        default:
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            break;
        }
        
    }
    
    private func fetchAllEvents(ifNeedMore: Bool = true) {
        
        newsFeedFilterViewModel
            .loadFollowingEvents(userProfileID, ifNeedMore: ifNeedMore)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal({ [unowned self] (observer, disposable) -> () in
            observer.observeCompleted({
                self.tableView.reloadData();
                self.pagingSpinner.stopAnimating();
                self.refreshControl?.endRefreshing()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            })
                
            observer.observeFailed({ (let error) in
                self.pagingSpinner.stopAnimating();
                self.refreshControl?.endRefreshing()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            })
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.tableView.tableFooterView = nil;
            }
        })
    }
    
    private func fetchGamesEvetns(ifNeedMore: Bool = true ) {
        
        newsFeedFilterViewModel
            .loadGameEvents(userProfileID, ifNeedMore: ifNeedMore)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal({ [weak self] (observer, disposable) -> () in
                observer.observeCompleted({
                    self?.tableView.reloadData();
                    self?.pagingSpinner.stopAnimating();
                    self?.refreshControl?.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                
                observer.observeFailed({ (let error) in
                    self?.pagingSpinner.stopAnimating();
                    self?.refreshControl?.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.tableView.tableFooterView = nil;
                }
        })
    }
    
    private func fetchTalkEvents(ifNeedMore: Bool = true) {
        
        newsFeedFilterViewModel
            .loadTalkEvents(userProfileID, ifNeedMore: ifNeedMore)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal({ [weak self] (observer, disposable) -> () in
                observer.observeCompleted({
                    self?.tableView.reloadData();
                    self?.pagingSpinner.stopAnimating();
                    self?.refreshControl?.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                observer.observeFailed({ (let error) in
                    self?.pagingSpinner.stopAnimating();
                    self?.refreshControl?.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.tableView.tableFooterView = nil;
                }
            })
    }
    
    private func loadFollowingEvents() {
        tableView.tableFooterView = pagingSpinner
        pagingSpinner.startAnimating()
        
        fetchAllEvents();
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeedFilterViewModel.followingEvents.value != nil ? newsFeedFilterViewModel.followingEvents.value!.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:EventCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.updateViewWithModel(newsFeedFilterViewModel.followingEvents.value![indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event = newsFeedFilterViewModel.followingEvents.value![indexPath.row];
        newsFeedFilterViewModel.openSessionInfoViewController(event);
    }
    
    //MARK: - Scroll view delegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.bounds.size.height) >= scrollView.contentSize.height {
            loadFollowingEvents();
        }
    }
}
