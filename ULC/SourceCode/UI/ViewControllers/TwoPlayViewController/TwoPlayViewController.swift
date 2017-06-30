//
//  2PlayViewController.swift
//  ULC
//
//  Created by Alexey on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Foundation
import SnapKit
import ReactiveCocoa
import MBProgressHUD

class TwoPlayViewController: WSBaseViewController, UITableViewDelegate, UITableViewDataSource, FilterTwoPlayDelegate {

	// MARK outlets
	@IBOutlet weak var emptyLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var mainView: UIView!
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var playSessionsCount: UILabel!
	@IBOutlet weak var twoPlayButton: UIButton!
	@IBOutlet weak var indicatorImage: UIImageView!
	@IBOutlet weak var watchLabel: UILabel!
	// MARK private fields
	private let viewModel       = TwoPlayViewModel()
    private let unityManager    = UnityManager()

	var allSessionAction: Action<(), (), NoError>?
	var followingSessionAction: Action<(), (), NoError>?
	var makeTwoPlayView = MakeTwoPlayView.instanciateFromNib()
	var filterTwoPlayView = FilterTwoPlayView.instanciateFromNib()
	var players = [GameSessionsEntity]()
	let refreshControl = UIRefreshControl()
    private var timer:NSTimer?;

	@IBAction func twoPlayButtonAction(sender: AnyObject) {
		filterViews()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		loadGameSessions()
		let value = UIInterfaceOrientation.Portrait.rawValue
		UIDevice.currentDevice().setValue(value, forKey: "orientation")

		if let _view = UnityGetGLView() where !_view.hidden{
			_view.hidden = true
		}
        timer = NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: #selector(TwoPlayViewController.reloadCells), userInfo: nil, repeats: true)
	}
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        timer?.invalidate();
        timer = nil;
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		if viewModel.getGamesArray().isEmpty {
			viewModel.fillGames()
		}

		configureViews()

		self.navigationController?.setNavigationBarHidden(false, animated: true)
		self.navigationController?.hidesBarsOnSwipe = false

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.Plain, target:nil, action:nil)
    }

	func configureViews() {
		twoPlayButton.titleLabel?.text = R.string.localizable.two_play_with_number()
		refreshControl.addTarget(self, action: #selector(TwoPlayViewController.refresh(_:)), forControlEvents: .ValueChanged)
		tableView.addSubview(refreshControl)

		if let menuImage = R.image.menu_main_icon() {
			self.addLeftBarButtonWithImage(menuImage)
		}

		if let expandIcon = R.image.expand_icon() {
			indicatorImage.image = expandIcon
		}

		filterTwoPlayView.x = 0
		filterTwoPlayView.y = 0
		makeTwoPlayView.x = 0
		makeTwoPlayView.y = 0

		mainView.addSubview(makeTwoPlayView)

		if let _ = makeTwoPlayView.superview {
			let gesture = UITapGestureRecognizer(target: self, action: #selector(TwoPlayViewController.makeSession(_:)))
			makeTwoPlayView.makeTwoPlaySessionView.addGestureRecognizer(gesture)
		}
		makeTwoPlayView.frame = mainView.bounds
		tableView.register(TwoPlayViewCell.self)

		let topViewgesture = UITapGestureRecognizer(target: self, action: #selector(TwoPlayViewController.filterAction(_:)))
		topView.addGestureRecognizer(topViewgesture)
		tableView.allowsSelection = true

		watchLabel.text = R.string.localizable.watch_other().uppercaseString
	}

	func filterAction(sender: UITapGestureRecognizer) {
		filterViews()
	}

	func refresh(refreshControl: UIRefreshControl) {
		loadGameSessions()
	}

	func reloadCells() {
		tableView.reloadData()
	}

	func filterViews() {
		if let _ = makeTwoPlayView.superview {
			makeTwoPlayView.removeFromSuperview()
			filterTwoPlayView.frame = mainView.bounds
			mainView.addSubview(filterTwoPlayView)
			filterTwoPlayView.delegate = self

			if let collapseIcon = R.image.collapse_icon() {
				indicatorImage.image = collapseIcon
			}

		} else {
			filterTwoPlayView.removeFromSuperview()
			mainView.addSubview(makeTwoPlayView)

			if let expandIcon = R.image.expand_icon() {
				indicatorImage.image = expandIcon
			}

			let gesture = UITapGestureRecognizer(target: self, action: #selector(TwoPlayViewController.makeSession(_:)))
			makeTwoPlayView.makeTwoPlaySessionView.addGestureRecognizer(gesture)
		}
	}

	private func loadGameSessions() {
		self.viewModel.loadActiveSessions()
			.producer
			.observeOn(UIScheduler())
			.startWithSignal({ [weak self](observer, disposable) -> () in
				observer.observeCompleted({
					self?.tableView.reloadData();
					self?.reload()
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
					self?.refreshControl.endRefreshing()
				})
				observer.observeFailed({ (error: ULCError) in
					MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
					self?.refreshControl.endRefreshing()
				})
    })
	}

	func makeSession(sender: UITapGestureRecognizer) {
		if let vc = R.storyboard.main.chooseGameTableViewController() {
			self.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.games.value != nil ? viewModel.games.value!.count : 0
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let newCell:TwoPlayViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
		if let sessions = viewModel.games.value {
			placeholderText(sessions.count)
		}
		if let value = viewModel.games.value {
			newCell.updateViewWithModel(value[indexPath.row])
		}

		return newCell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! TwoPlayViewCell

		if let model = cell.gameEntity {

			if model.players.first?.id == viewModel.currentId || model.players.last?.id == viewModel.currentId{
				let game = WSGameEntity.create(model)
				let wsGameCreateEntity = WSGameCreateEntity.create(game)
				unityManager.initialUnity(game, ownerID: viewModel.currentId)
				//viewModel.openStreamerGameSessionVC(wsGameCreateEntity)
                viewModel.openGameViewController(wsGameCreateEntity)
			} else {
				//viewModel.openSpectatorGameSessionVC(model, viewTypeController: viewTypeController)
                viewModel.openSpectatorViewController(model, viewControllerType: viewTypeController)
			}
		}
	}

	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		let height = self.tableView.frame.height * 0.5
		return height + 20;
	}

	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0
	}

	func placeholderText(count: Int) {
		if count == 0 {
			playSessionsCount.text = ""
			emptyLabel.enabled = true
			emptyLabel.text = R.string.localizable.no_active_game_sessions()
		} else {
			playSessionsCount.text = String(count)
			emptyLabel.enabled = false
			emptyLabel.text = ""
		}
	}

	func allSessionsClick() {
		filterViews()
	}

	func followSessionsClick() {
		filterViews()
	}

	func reload(){
		if let sessions = viewModel.games.value {
			placeholderText(sessions.count)
		} else {
			placeholderText(0)
		}
	}
}
