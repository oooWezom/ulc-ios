//
//  PlayAnonymousViewController.swift
//  ULC
//
//  Created by Alex on 2/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import Result
import MBProgressHUD

class PlayAnonymousViewController: WSBaseViewController {
    
    let tableView			= UITableView(frame:CGRectZero);
    let viewModel			= TwoPlayViewModel();
    let unityManager		= UnityManager()
    private let infoLabel	= UILabel();
	let refreshControl		= UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        confgiureViews();
        loadActivitiesGameSession();
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        infoLabel.snp_remakeConstraints { (make) in
            make.centerX.equalTo(view);
            make.centerY.equalTo(view);
            make.left.right.equalTo(view);
            make.height.equalTo(20);
        }
        tableView.snp_remakeConstraints { (make) in
            make.edges.equalTo(view);
        }
    }
    
    private func confgiureViews() {
        infoLabel.textColor = UIColor(named: .ActivitySessionColor);
        infoLabel.textAlignment = .Center;
        infoLabel.text = R.string.localizable.no_active_game_sessions();
        view.addSubview(infoLabel);
        tableView.register(TwoPlayViewCell.self);
        tableView.delegate = self;
        tableView.dataSource = self;
		tableView.backgroundColor = UIColor(named: .TwoPlaySessionsBackgroungColor);
		//
		refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
		refreshControl.tintColor = UIColor.grayColor();
        if #available(iOS 10.0, *) {
            //tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
		//
        view.addSubview(tableView);
    }

	func refresh(refreshControl: UIRefreshControl) {
		loadActivitiesGameSession()
	}
    
    private func loadActivitiesGameSession () {
        MBProgressHUD.showHUDAddedTo(view, animated: true);
        viewModel.games.producer.observeOn(UIScheduler()).startWithResult { [weak self] result in
            guard let value = result.value, let _ = value else {
				self?.refreshControl.endRefreshing()
				self?.infoLabel.hidden = true
                self?.tableView.hidden = true;
                MBProgressHUD.hideAllHUDsForView(self?.view, animated: true);
                return;
            }
            self?.tableView.hidden = false;
            self?.tableView.reloadData();
			self?.infoLabel.hidden = true
			self?.refreshControl.endRefreshing()
            MBProgressHUD.hideAllHUDsForView(self?.view, animated: true);
        }
        viewModel.loadActiveSessions().start();
    }
    
    deinit {
        Swift.debugPrint("dealloc: \(self)")
    }
}
