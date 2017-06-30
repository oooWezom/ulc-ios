//
//  FollowsViewController.swift
//  ULC
//
//  Created by Alex on 7/4/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import MBProgressHUD

enum FollowerType: Int {
    case Followers = 0
    case Following
}

class FollowersViewController: BaseMessagesViewController {
    
    let followersCountHeaderView = BlackListViewHeader.instanciateFromNib();

    //MARK Private properties
    private let viewModel   = FollowersViewModel();
    private let startFilter = UISegmentedControl(items: [R.string.localizable.followers(), R.string.localizable.following()]) //#MARK localized
    
    var shouldOpenFollowing = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        attachSignals(shouldUpdate: false);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.hidesBarsOnSwipe = false
    }
    
    override func configureViews() {
        super.configureViews();
        
        configureSegmentedBar();
        
        if userProfileID == 0 {
            addMenuButton();
        } else {
            addBackButton()
        }
        
        if shouldOpenFollowing {
            startFilter.selectedSegmentIndex = 1;
            viewModel.followerType.value = FollowerType.Following.rawValue;
        }
    }

    override func configureTableView() {
        super.configureTableView();
        

        tableView.register(FollowCell.self);
        tableView.rowHeight = 50
        tableView.separatorStyle = .None;
    }

    override func refresh() {
        attachSignals(shouldUpdate: true);
    }
    
    private func attachSignals(shouldUpdate shouldUpdate: Bool) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        startFilter.enabled = false;
        
        viewModel.fetchData(userProfileID, loadMore: shouldUpdate)
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) -> () in
                
                observer.observeCompleted({
                    self?.refreshControl?.endRefreshing()
                    self?.tableView.reloadData();
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    
                    if let value = self?.viewModel.items.value {
                        self?.followersCountHeaderView.setUsersCount(value.count)
                        
                        // MARK:- Follower Acknowledged via sockets
                        var followersId = [Int]()
                        for follower in value {
                            followersId.append(follower.id)
                        }
                        self?.wsProfileViewModel.followerAcknowledged(followersId)
                    }
                    
                    self?.startFilter.enabled = true;
                })
                
                observer.observeFailed({ (error: ULCError) in
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    self?.refreshControl?.endRefreshing()
                    self?.startFilter.enabled = true;
                })
        }
    }
    
    private func configureSegmentedBar() {
        startFilter.tintColor = UIColor(named: .LoginButtonNormal);
        startFilter.sizeToFit();
        self.navigationItem.titleView = startFilter;
        startFilter.selectedSegmentIndex = 0;
        startFilter.addTarget(self, action: #selector(segmentedControlValueChanged), forControlEvents: .ValueChanged);
    }

    func segmentedControlValueChanged(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0  {
            viewModel.followerType.value = FollowerType.Followers.rawValue;
        } else {
            viewModel.followerType.value = FollowerType.Following.rawValue;
        }
        attachSignals(shouldUpdate: false);
    }
    
    //MARK UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = viewModel.items.value else {
            return 0
        }
        return items.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FollowCell = tableView.dequeueReusableCell(forIndexPath: indexPath);
        
        if let model = viewModel.items.value?[indexPath.row] {
            cell.updateViewWithModel(model);
        }
        return cell;
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return followersCountHeaderView
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let userEntity = viewModel.items.value?[indexPath.row];
        if let entity = userEntity {
            if entity.id == 0 || entity.id == viewModel.currentId{
                viewModel.presenter.openCurrentUserProfileVCFromMenu(entity.id);
            }else {
                viewModel.presenter.openUserProfileVC(entity.id)
            }
        }
    }
    
    //MARK
    override func updateSearchResultsForSearchController(searchController: UISearchController) {}

    override func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.queryString.value = searchText
        attachSignals(shouldUpdate: false);
    }
    
    override func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text where !text.isEmpty {
            viewModel.queryString.value = ""
            attachSignals(shouldUpdate: false);
        }
    }
}
