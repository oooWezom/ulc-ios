//
//  MessagesViewController.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import MBProgressHUD

class ConversationsViewController: BaseMessagesViewController {
    
    private let viewModel = MessagesViewModel();
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.hidesBarsOnSwipe = false
        
        bindSignals()
    }
    
    override func configureTableView() {
        super.configureTableView();
        
        tableView.rowHeight = 94;
        tableView.register(ConversationCell);
        tableView.separatorStyle = .SingleLine
    }
    
    override func configureViews() {
        super.configureViews();
        
        self.title = R.string.localizable.messages(); //#MARK localized
        addMenuButton();
    }
    
    override func refresh() {
        super.refresh()
        
        loadMessages()
    }
    
    private func loadMessages(){
        
        viewModel.fetchConversations()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) -> () in
                
                observer.observeCompleted({
                    self?.tableView.reloadData();
                    if let refreshControl = self?.refreshControl {
                        refreshControl.endRefreshing()
                    }
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                observer.observeFailed({ (let error) in
                    if let refreshControl = self?.refreshControl {
                        refreshControl.endRefreshing()
                    }
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
        }
    }
    
    private func bindSignals() {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        loadMessages()
        
        // MARK: - WS signals
        wsProfileViewModel.readInstantMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.tableView.reloadData();
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
        }
        
        wsProfileViewModel.instantMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.loadMessages()
        }
        
        let newInstantMessageSignal = wsProfileViewModel.newInstantMessageHadler.0;
        
        newInstantMessageSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.loadMessages()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel.conversations.value != nil) ? viewModel.conversations.value!.count : 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: ConversationCell = tableView.dequeueReusableCell(forIndexPath: indexPath);
        if let model = viewModel.conversations.value?[indexPath.row] {
            cell.updateViewWithModel(model);
        }
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let entity = viewModel.conversations.value?[indexPath.row], let partner = entity.parther else {
            return;
        }
        viewModel.openMessagesViewController(partner);
    }
}
