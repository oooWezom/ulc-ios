//
//  LanguageViewController.swift
//  ULC
//
//  Created by Alexey on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

protocol LanguageDelegate {
    func setLanguages(languages: [LanguageEntity])
}

import UIKit
import ReactiveCocoa
import MBProgressHUD
import ObjectMapper
import ReactiveCocoa

class LanguageViewController: UITableViewController {
 
    // MARK private properties
    private let viewModel = LanguagesViewModel();
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let presenter = PresenterImpl()
    
    var selectedLanguages = [LanguageEntity]()
    var filteredLanguages = [LanguageEntity]()
    
    var delegate:LanguageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchController.searchBar.sizeToFit()
    }
    
    private func configure() {
        configureTableView();
        configureSearchBar();
        configureStatusBar();
        configureNavigationBar();
        configureSignals();
    }
    
    private func configureTableView() {
        tableView.register(LanguageTableViewCell.self)
        tableView.separatorStyle = .SingleLine
        tableView.allowsMultipleSelection = true
    }
    
    private func configureSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.tintColor = UIColor(named: .NavigationBarColor)
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func configureStatusBar() {
        let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView
        statusBar!.backgroundColor = UIColor.whiteColor()
    }
    
    private func configureNavigationBar() {

		self.title = R.string.localizable.language()
        
        let playButton = UIButton(frame: CGRectMake(0, 0, 100, 50))
		playButton.contentHorizontalAlignment = .Right
        playButton.addTarget(self, action: #selector(doneButtonClicked), forControlEvents: .TouchUpInside)
        
        let enabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonEnable)]
        let disabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonDisable)]
        
        let doneText = NSAttributedString(string: R.string.localizable.done(), attributes: enabledAttribute)
        let notDoneText = NSAttributedString(string: R.string.localizable.done(), attributes: disabledAttribute)
        
        playButton.setAttributedTitle(doneText, forState: .Normal)
        playButton.setAttributedTitle(notDoneText, forState: .Selected)
        
        let rightButton = UIBarButtonItem(customView: playButton)
        
        self.navigationItem.setRightBarButtonItems([rightButton], animated: true)
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
    }

    func configureSignals() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        viewModel.getLanguagesList()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) in
            
            observer.observeCompleted({
                self?.tableView.reloadData();
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            })
            
            observer.observeFailed({ (error: NSError) in
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            })
        }
    }
    
    func doneButtonClicked(sender: UIButton) {
        if !selectedLanguages.isEmpty {
            delegate?.setLanguages(selectedLanguages)
        }
        if let nc = self.navigationController {
            nc.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true) {}
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredLanguages.count
        }
        return viewModel.languages.value != nil ? viewModel.languages.value!.count : 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: LanguageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        var language = LanguageEntity();
        
        if searchController.active && searchController.searchBar.text != "" {
            cell.languageName.text = filteredLanguages[indexPath.row].displayName;
            language = filteredLanguages[indexPath.row];
        } else {
            language = viewModel.languages.value![indexPath.row];
            cell.languageName.text = language.displayName;
        }
        
        if selectedLanguages.contains(language) {
            cell.selectionImage.image = R.image.check_done_icon()
            cell.contentView.backgroundColor = UIColor(named: .CellBackgroundColor)
        } else {
            cell.selectionImage.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let langs = viewModel.languages.value else {
            return;
        }
        let language = langs[indexPath.row];
        if selectedLanguages.contains(language) {
            selectedLanguages.removeObject(language);
        } else {
            selectedLanguages.append(language)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic);
    }
    
    deinit {
        searchController.view.removeFromSuperview();
    }
}

//Mark UISearchBarDelegate Delegate
extension LanguageViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
}

//Mark UISearchResultsUpdating Delegate
extension LanguageViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        guard let items = viewModel.languages.value else {
            return;
        }
        filteredLanguages = items.filter {
            $0.displayName.lowercaseString.hasPrefix(searchController.searchBar.text!.lowercaseString);
        }
        tableView.reloadData()
    }
}
