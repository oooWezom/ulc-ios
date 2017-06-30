//
//  BlackListViewController.swift
//  ULC
//
//  Created by Vitya on 7/19/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import MBProgressHUD
import ReactiveCocoa
import Result

class BlackListViewController: BaseEventViewController, UISearchBarDelegate {
    
    let viewModel = BlackListViewModel()
    
    let blackListHeaderView = BlackListViewHeader.instanciateFromNib();
    let searchController = UISearchController(searchResultsController: nil)
    
    var blackList: [EventBaseEntity]?
    var filteredBlackList = [EventBaseEntity]()
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        connectSignals(false);
        configureSearchBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        ulcButton.hidden = true;
        tableView.reloadData();
    }
    
    override func configureViews() {
        super.configureViews();

        self.title = R.string.localizable.black_list() //#MARK localized
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        
        addRefreshControll();
    }
    
    override func configureTableView() {
        super.configureTableView();
        
        tableView.register(BlackListCell.self);
        tableView.rowHeight = 50;
        tableView.alwaysBounceVertical = false;
        tableView.separatorStyle = .None;
    }
    
    override func refresh() {
        connectSignals(false);
    }
    
    private func configureSearchBar() {
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor(named: .EventSeparatorLine).CGColor
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor(named: .NavigationBarColor)
        searchController.searchBar.barTintColor = UIColor(named: .EventSeparatorLine)
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func connectSignals(ifNeedMore: Bool = true) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        viewModel.fetchData(offset, loadMore: ifNeedMore)
            .producer
            .observeOn(UIScheduler())
            .startWithSignal({ [unowned self] (observer, disposable) -> () in
                
                observer.observeCompleted({
                    self.blackList = self.viewModel.items.value
                    Swift.debugPrint(self.viewModel.items.value)
                    self.tableView.reloadData();
                    self.pagingSpinner.stopAnimating();
                    self.refreshControl?.endRefreshing()
                    if let blackList = self.blackList {
                        self.blackListHeaderView.setUsersCount(blackList.count)
                    }
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
                
                observer.observeFailed({ (let error) in
                    self.pagingSpinner.stopAnimating();
                    self.refreshControl?.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.tableView.tableFooterView = nil;
                }})
    }
    
    private func loadBlackList() {
        tableView.tableFooterView = pagingSpinner
        pagingSpinner.startAnimating()
        connectSignals();
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.emptyMessage("")
        if searchController.active && searchController.searchBar.text != "" {
            return filteredBlackList.count
        } else if let array = blackList where array.count > 0 {
            return array.count
        } else {
            self.emptyMessage(R.string.localizable.your_black_list_is_empty()) //#MARK localized
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return blackListHeaderView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:BlackListCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        guard let blackList = blackList else {
            return cell
        }
        
        let list: EventBaseEntity
        if searchController.active && searchController.searchBar.text != "" {
            list = filteredBlackList[indexPath.row]
        } else {
            list = blackList[indexPath.row]
        }
        
        cell.updateViewWithModel(list)
        cell.unblockButton.addTarget(self, action: #selector(unblockButtonTouch), forControlEvents: .TouchUpInside)
        cell.unblockButton.tag = indexPath.row
        return cell
    }
    
    func unblockButtonTouch(sender: UIButton) {
        guard let value = viewModel.items.value else {
            return
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        var userId = 0
        
        if searchController.active && searchController.searchBar.text != "" {
             userId = filteredBlackList[sender.tag].id
        } else {
             userId = value[sender.tag].id
        }
        
        viewModel.removeFromBlackList(userId).start { [unowned self] observer in
            
            switch(observer.event) {
            case .Completed:
                
                if self.searchController.active && self.searchController.searchBar.text != "" {
                    self.filteredBlackList.removeAtIndex(sender.tag)
                }
                
                self.blackList?.removeAll()
                self.viewModel.reloadBlackListData()
                self.connectSignals(false)
                
                if let blackList = self.blackList {
                    self.blackListHeaderView.setUsersCount(blackList.count)
                }
                Swift.debugPrint(self.blackList)
                 self.tableView.reloadData()
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
            case .Failed(let error):
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                self.showULCError(error)
                
            default:
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            }
        }
    }
    
    func emptyMessage(message: String) {
        let messageLabel = UILabel(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGrayColor()
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .Center;
        messageLabel.font = UIFont.systemFontOfSize(30)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel;
    }
    
    func filterContentForSearchText(searchText: String) {
        guard let blackList = blackList else {
            return
        }
        
        filteredBlackList = blackList.filter { blackList in
            return (blackList.name.lowercaseString.containsString(searchText.lowercaseString))
        }
        tableView.reloadData()
    }
    
    // MARK UISearchResultsUpdating, UISearchBarDelegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterContentForSearchText(searchString!)
    }
    
}

extension BlackListViewController: UISearchResultsUpdating {
    func updateSearchResultsForChooseGameController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
