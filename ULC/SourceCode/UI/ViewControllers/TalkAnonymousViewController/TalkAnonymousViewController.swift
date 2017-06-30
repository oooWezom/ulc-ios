//
//  TalkAnonymousViewController.swift
//  ULC
//
//  Created by Alex on 2/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result
import SnapKit
import MBProgressHUD

class TalkAnonymousViewController: UIViewController {
    
    var talkTypeController:ViewTypeController!;
    @IBOutlet weak var containerView: UIView!
    
    lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.footerReferenceSize = CGSizeZero;
        layout.headerReferenceSize = CGSizeZero;
        let collectionView = UICollectionView(frame: CGRect(x: 5, y: 0, width: self.view.width, height: 60), collectionViewLayout: layout);
        collectionView.backgroundColor = UIColor.whiteColor();
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.register(TalkCategoryIconCell.self);
        collectionView.allowsSelection = true
        return collectionView;
    }();
    
    lazy var talksCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout();
        layout.scrollDirection = .Vertical;
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout);
        collectionView.backgroundColor = UIColor(named: .TalkViewBackgroundColor);
        collectionView.register(TwoTalkTwoStreamersCell.self);
        collectionView.register(TwoTalkOneStreamerCell.self);
        collectionView.delegate = self;
        collectionView.dataSource = self;
        return collectionView;
    }();
    
    let categoryViewModel:Categoring    = CategoryViewModel();
    let talkViewModel:TwoTalking        = TwoTalkViewModel()
    let wsProfileViewModel              = WSProfileViewModel()
    
    private let refreshControl          = UIRefreshControl();
    var groupId = 0;
    private let infoLabel = UILabel();

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let value = UIInterfaceOrientation.Portrait.rawValue
		UIDevice.currentDevice().setValue(value, forKey: "orientation")
	}
    
    override func viewDidLoad() {
        super.viewDidLoad();
        configureTalkCategories();
        setupSignals();
    }
    
    private func configureTalkCategories() {
        
        if talkTypeController == .Normal {
            
        }
        
        infoLabel.textColor     = UIColor(named: .ActivitySessionColor);
        infoLabel.textAlignment = .Center;
        infoLabel.text          = R.string.localizable.no_active_game_sessions();
        containerView.addSubview(infoLabel);
        
        containerView.addSubview(categoriesCollectionView);
        containerView.addSubview(talksCollectionView);
        
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.grayColor();
        talksCollectionView.addSubview(refreshControl);
        talksCollectionView.alwaysBounceVertical = true;
    }
    
    private func setupSignals() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        //fetch category icons
        categoryViewModel.categories
            .producer
            .observeOn(UIScheduler())
            .startWithResult { [weak self] _ in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self?.categoriesCollectionView.reloadData();
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                }
        }
        categoryViewModel.fetchTalkCategoryIcons();
        
        //fetch active sessions
        talkViewModel.talksSession
            .producer
            .observeOn(UIScheduler())
            .startWithResult { [weak self] result in
                guard let strongSelf = self else {
                    self?.talksCollectionView.hidden = true;
                    return;
                }
                strongSelf.talksCollectionView.hidden = false;
                strongSelf.talksCollectionView.reloadData();
                MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                strongSelf.refreshControl.endRefreshing()
        }
        talkViewModel.loadActiveSessions(groupId).start();
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints();
        infoLabel.snp_remakeConstraints { (make) in
            make.centerX.centerY.equalTo(view);
            make.left.right.equalTo(view);
            make.height.equalTo(20);
        }
        if talkTypeController == .Normal {
            print("");
        } else {
            categoriesCollectionView.snp_remakeConstraints { (make) in
                make.top.equalTo(5);
                make.left.right.equalTo(containerView);
                make.height.equalTo(65);
            }
        }
        talksCollectionView.snp_remakeConstraints { (make) in
            make.top.equalTo(categoriesCollectionView.snp_bottom).offset(5);
            make.left.bottom.equalTo(containerView).offset(5);
            make.right.equalTo(containerView).offset(-5);
        }
    }
    
    func refresh() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        talkViewModel.loadNewActiveSessions(groupId)
            .startWithSignal { [weak self] (signal, disposable) in
                signal.observeCompleted({
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                    self?.refreshControl.endRefreshing()
                })
        }
    }
}