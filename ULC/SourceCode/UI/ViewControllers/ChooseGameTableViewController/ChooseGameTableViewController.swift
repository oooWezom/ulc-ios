//
//  ChooseGameTableViewController.swift
//  ULC
//
//  Created by Alexey on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ObjectMapper
import MBProgressHUD

class ChooseGameTableViewController: BaseEventViewController, StartGameDelegate, UISearchBarDelegate, ChooseGameCheckDelegate {
    
    // MARK Private properties
    private let searchController                = UISearchController(searchResultsController: nil)
    private var games                           = [GameEntity]()
    private let viewModel                       = ChooseGameViewModel()
    let playButton                              = UIButton(frame: CGRectMake(0, 0, 50, 50))
    var filteredGames                           = [GameEntity]()
    let unityManager                            = UnityManager()
    var wsGameEntity: WSGameCreateEntity?
    let userProfileViewModel = UserProfileViewModel();
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchController.searchBar.sizeToFit();
        wsProfileViewModel.resume();
        ulcButton.hidden = true
        self.navigationController?.hidesBarsOnSwipe = false
        //MARK return portrait orientation if last controller was landscape
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        
        if let _view = UnityGetGLView() where !_view.hidden{
            _view.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        wsProfileViewModel.pause();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.hidesBarsOnSwipe = false
        tableView.register(ChooseGameTableViewCell.self)
        configureNavigationBar()
        self.title = R.string.localizable.choose_game()//#MARK localized
        configureSearchBar()
        customAlertMessageController.startGameDelegate = self
        games.appendContentsOf(viewModel.getGamesArray())
        
        configureSignals();
    }
    
    
    deinit{
        Swift.debugPrint("ChooseGameTableViewController DEINIT")
    }
    
    func configureSignals() {
        
        self.wsProfileViewModel.lookingForGameHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
            guard let message = observer.value else {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                return
            }
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            switch message.result {
            case 1:
                self.customAlertMessageController.showSearchOpponent(self.wsProfileViewModel)
                break
            case 3:
                self.showAlertMessage(message.message, handler: nil)
                break
            case 4:
                if let game = message.game {
                    self.reconnect(game)
                }
                break;
            case 6:
                if let game = message.game {
                    self.reconnect(game)
                }
                break
            case 7:
                self.showAlertMessage(message.message, handler: nil)
                break
                
            default:
                break
            }
        }
        
        self.wsProfileViewModel.createGameResultHandler.signal
            .observeOn(UIScheduler())
            .observeResult{ [unowned self] observer in
            
            guard let message = observer.value else {
                return
            }
            self.wsGameEntity = message
            self.customAlertMessageController.showGameStart();
        }
        observeUserData();
    }
    
    func reconnect(message:WSGameEntity){
        
        let wsGameCreateEntity = WSGameCreateEntity()
        wsGameCreateEntity.game = message
        
        unityManager.initialUnity(message, ownerID: viewModel.currentId)
        
        self.wsGameEntity = wsGameCreateEntity
        self.openUnityViewController()
    }
    
    private func configureSearchBar() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor(named: .NavigationBarColor)
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        filterContentForSearchText(searchString!)
    }
    
    func openUnityViewController() {
        if let gameEntity = wsGameEntity {
            viewModel.openGameViewController(gameEntity)
            //viewModel.openStreamerGameSessionVC(gameEntity);
        }
    }
    
    func cancelStartGame() {
    }
    
    private func configureNavigationBar() {
        let enabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonEnable)]
        let disabledAttribute = [NSForegroundColorAttributeName: UIColor(named: .DoneButtonDisable)]


        let doneText = NSAttributedString(string: R.string.localizable.start(), attributes: enabledAttribute) //#MARK localize
        let notDoneText = NSAttributedString(string: R.string.localizable.start(), attributes: disabledAttribute)
        let rightButton = UIBarButtonItem(customView: playButton)
        playButton.addTarget(self, action: #selector(startButtonAction), forControlEvents: .TouchUpInside)
        
        playButton.setAttributedTitle(doneText, forState: .Normal)
        playButton.setAttributedTitle(notDoneText, forState: .Selected)
        
        self.navigationItem.setRightBarButtonItems([rightButton], animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
    }
    
    func startButtonAction() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        var gamesArr = [Int]()
        games.forEach { it in
            if it.isChecked {
                gamesArr.append(it.gameId)
            }
        }
        
        if gamesArr.isEmpty {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            showAlertMessage(R.string.localizable.please_choose_a_game(), handler: nil);
            
        } else {
            self.wsProfileViewModel.lookingForGame(gamesArr)
        }
    }
    
    func cancelGameSearch() {
        self.wsProfileViewModel.cancelGameSearch()
    }
    
    func check(gameID: Int) {
        var count = 0
        games.forEach { it in
            if it.isChecked {
                count += 1
            }
        }
        if gameID == GameID.RANDOM.rawValue {
            if count == games.count {
                games[0].isChecked = false
                self.tableView.reloadData()
            } else {
                games.forEach { it in
                    it.isChecked = true
                    self.tableView.reloadData()
                }
            }
        } else {
            if count == games.count {
                if games[0].isChecked {
                    games[0].isChecked = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredGames.count
        }
        return games.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ChooseGameTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.delegate = self
        let game: GameEntity
        if searchController.active && searchController.searchBar.text != "" {
            game = filteredGames[indexPath.row]
        } else {
            game = games[indexPath.row]
        }
        
        cell.updateWithModel(game)
        return cell
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredGames = games.filter { game in
            return (game.title.lowercaseString.containsString(searchText.lowercaseString))
        }
        tableView.reloadData()
    }
    //
    private func observeUserData() {
        weak var weakSelf = self;
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                weakSelf?.observeUserProfile();
                weakSelf?.userProfileViewModel.loadUserDataProfile(0).start();
        }
        observeUserProfile();
        userProfileViewModel.loadUserDataProfile(0).start();
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
                if status != .Playing {
                    return;
                }
                if let game = user.game where status == .Playing {
                    self?.showAlertMessage("", message: R.string.localizable.current_game(), completitionHandler: { _ in
                        if let strongSelf = self {
                            if strongSelf.view.window != nil && strongSelf.isViewLoaded() {
                                let tmpGame = WSGameEntity.create(game);
                                strongSelf.unityManager.initialUnity(tmpGame, ownerID: strongSelf.viewModel.currentId)
                                //strongSelf.viewModel.openStreamerGameSessionVC(WSGameCreateEntity.create(tmpGame));
                                strongSelf.viewModel.openGameViewController(WSGameCreateEntity.create(tmpGame))
                            }
                        }
                    })
                }
        }
    }
}

extension ChooseGameTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForChooseGameController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
