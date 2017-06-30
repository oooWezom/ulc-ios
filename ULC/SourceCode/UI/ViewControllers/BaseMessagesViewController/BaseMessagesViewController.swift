//
//  BaseMessagesViewController.swift
//  ULC
//
//  Created by Alex on 7/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class BaseMessagesViewController: BaseEventViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func configureViews() {
        super.configureViews();
        
        addRefreshControll();
        if let refreshControl = refreshControl {
            refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        }
    }
    
    override func configureTableView() {
        super.configureTableView();
        
        configureSearchBar();
    }
    
    private func configureSearchBar() {
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.layer.borderWidth = 1
        searchController.searchBar.layer.borderColor = UIColor(named: .EventSeparatorLine).CGColor
        searchController.searchBar.tintColor = UIColor(named: .NavigationBarColor)
        searchController.searchBar.barTintColor = UIColor(named: .EventSeparatorLine)
        
        searchController.searchBar.placeholder = "\(R.string.localizable.search_here())..." //#MARK localized
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
    }
    
    deinit {
        searchController.view.removeFromSuperview();
    }
    
    //MARK UISearchResultsUpdating, UISearchBarDelegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {}
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {}
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {}
}
