//
//  GeneralGameViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import KSYMediaPlayer
import ObjectMapper

public class GeneralGameViewController: UIViewController, UITextFieldDelegate {
    
    // MARK views
    public let leftSurfaceView = UIView()
    public let rightSurfaceView = UIView()
    private let messageView = SendMessageView()
    
    let wishView = WishView()
    let gameView = UnityView()
    var unityView = UnityGetGLView()
    let chatView = ChatView.instanciateFromNib()
    let bottomView = TwoPlayGamingBottomView.instanciateFromNib()
    let leftPlayerInfoView = PlayerInfoView(position: .Left)
    let rightPlayerInfoView = PlayerInfoView(position: .Right)
    let leftActivityIndicator = UIActivityIndicatorView()
    let rightActivityIndicator = UIActivityIndicatorView()
    let leftPlayerXPLabel = UILabel()
    let rightPlayerXPLabel = UILabel()
    var signAlertViewController: UIAlertController!
    
    // MARK fields
    var wsViewModel:WSSessionViewModel?
    var viewModel:GameViewModel?
    var model:AnyObject?
    var orientation = GameViewOrientations.ALL
    var mode:GameMode?
    var viewTypeController:ViewTypeController = .Normal
    var winner:WinnerMode = .NONE
    var isAnimationBlock = false
    let animDuration = 0.5
    let animDelay = 0.0
    var levelFontSize: CGFloat = 15.0
    var winnersArray = [Int]()
    var isKeyboardShown = false
    var spectatorsCount = 0
    
    // MARK override functions
    var resultData: WSGameStateDataEntity?
    let unityEntityFactory = UnityEntityFactory()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initWSViewModel(model)
        viewModel = GameViewModel(model: model)
        
        addCustomViews()
        bindSignals()
        
        leftPlayerInfoView.updateWithModel(viewModel?.leftPlayerModel.value)
        rightPlayerInfoView.updateWithModel(viewModel?.rightPlayerModel.value)
        
        bindTargets()
        bindGestureRecognizers()
        bindViewTypeController()
        calculateFontSize(self.getInterfaceOrientation(), reverse: false)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true;
        bindObservers()
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false;
        self.orientation = .PORTRAIT
        self.forceSwitchOrientationToPortrait()
        unbindPingTimer()
        unbindObservers()
    }
    
    override public func updateViewConstraints() {
        super.updateViewConstraints()
        changeMessageViewVisibility(false)
        remakeConstraints(getSurfaceHeight())
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({
            (ctx) in
            self.configureStatusBar(true)
            self.changeMessageViewVisibility(true)
            self.calculateFontSize(self.getInterfaceOrientation(), reverse: true)
            // MARK CALLED WILL
        }) {
            (ctx) in
            // MARK CALLED DID
            if self.getInterfaceOrientation().isLandscape {
                self.view.endEditing(true)
            }
        }
    }
    
    // MARK public methods
    
    public func changeMessageViewVisibility(reverse:Bool) {
        if !reverse {
            if getInterfaceOrientation().isPortrait {
                messageView.updateConstraints()
            } else {
                messageView.resetConstraints()
            }
        } else {
            if getInterfaceOrientation().isLandscape {
                self.chatView.hidden = true
                messageView.resetConstraints()
            } else {
                self.chatView.hidden = false
                messageView.updateConstraints()
            }
        }
    }
    
    public func getBasePlaybackURL() -> String {
        guard let url = viewModel?.gameModel.value?.videoUrl else { return "" }
        return url
    }
    
    public func forceReconnectPlayer(player:KSYMoviePlayerController, url:NSURL) {
        player.setVolume(0.75, rigthVolume: 0.75)
        player.reload(url, flush: false, mode: .Accurate)
        player.prepareToPlay()
    }
    
    public func bindViewTypeController() {
        if viewTypeController == .Anonymous {
            signAlertViewController = UIAlertController.init(title: R.string.localizable.please_sign(),
                                                             message: R.string.localizable.functionaly(),
                                                             preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .Cancel) { action in
            }
            signAlertViewController.addAction(cancelAction)
            let oKAction = UIAlertAction(title: R.string.localizable.ok(), style: .Default) { [weak self] action in
                self?.dismissViewControllerAnimated(true, completion: {
                    if let nc = UIApplication.topNavigationViewController() as?  ULCNavigationViewController {
                        if let vc = nc.viewControllers.first {
                            vc.popViewController();
                        }
                    }
                })
            }
            signAlertViewController.addAction(oKAction)
            oKAction.setValue(UIColor.init(named: .LoginButtonNormal), forKey: "titleTextColor");
            cancelAction.setValue(UIColor.blackColor(), forKey: "titleTextColor");
        }
    }
    
    // MARK private methods
    private func bindTargets() {
        self.leftPlayerInfoView.optionButton.addTarget(self, action: #selector(leftInfoAction), forControlEvents: .TouchUpInside)
        self.rightPlayerInfoView.optionButton.addTarget(self, action: #selector(rightInfoAction), forControlEvents: .TouchUpInside)
        self.messageView.sendMessageButton.addTarget(self, action: #selector(sendMessageAction), forControlEvents: .TouchUpInside)
    }
    
    private func bindGestureRecognizers() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.view.addGestureRecognizer(tap)
    }
    
    private func addCustomViews() {
        self.view.addSubview(leftSurfaceView)
        self.view.addSubview(rightSurfaceView)
        self.view.addSubview(unityView)
        self.view.addSubview(gameView)
        self.view.addSubview(chatView)
        self.view.addSubview(messageView)
        self.view.addSubview(bottomView)
        self.view.addSubview(wishView)
        self.leftSurfaceView.addSubview(leftPlayerInfoView)
        self.rightSurfaceView.addSubview(rightPlayerInfoView)
        self.leftSurfaceView.addSubview(leftActivityIndicator)
        self.rightSurfaceView.addSubview(rightActivityIndicator)
        self.leftSurfaceView.addSubview(leftPlayerXPLabel)
        self.rightSurfaceView.addSubview(rightPlayerXPLabel)
        
        leftPlayerXPLabel.textColor = UIColor.whiteColor()
        rightPlayerXPLabel.textColor = UIColor.whiteColor()
        leftPlayerXPLabel.textAlignment = .Right
        rightPlayerXPLabel.textAlignment = .Left
        
        gameView.hidden = false
        unityView.hidden = true
        wishView.hidden = true
        
        configureStatusBar(false)
        
        leftSurfaceView.backgroundColor = UIColor.blackColor()
        rightSurfaceView.backgroundColor = UIColor.blackColor()
        
        self.view.needsUpdateConstraints()
    }
    
    private func remakeConstraints(height:CGFloat) {
        
        if getInterfaceOrientation().isPortrait {
            
            self.view.addSubview(chatView)
            self.view.addSubview(messageView)
            
            chatView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(gameView.snp_bottom).priorityLow()
                make.left.right.equalTo(view).priorityLow()
                make.bottom.equalTo(view).offset(-20).priorityLow()
            }
            
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view).offset(-20)
                make.height.equalTo(40)
            }
            
            messageView.updateConstraints()
            
        } else {
            chatView.removeFromSuperview()
            messageView.removeFromSuperview()
        }
        
        // BEGIN
        if self.mode == .SPECTATOR || self.mode == .STREAMER || self.mode == .GAME || self.mode == .DONE || self.mode == .FINISH || self.mode == .NOT_SUPPORTED {
            
            leftSurfaceView.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.equalTo(self.view)
                make.width.equalTo(self.view).multipliedBy(0.5)
                make.height.equalTo(height)
            }
            
            rightSurfaceView.snp_remakeConstraints {
                (make) -> Void in
                make.top.right.equalTo(self.view)
                make.width.equalTo(self.view).multipliedBy(0.5)
                make.height.equalTo(height)
            }
            
            if let _ = leftPlayerInfoView.superview {
                leftPlayerInfoView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.equalTo(leftSurfaceView)
                    make.height.equalTo(leftSurfaceView)
                }
            }
            
            if let _ = rightPlayerInfoView.superview {
                rightPlayerInfoView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.equalTo(rightSurfaceView)
                    make.height.equalTo(rightSurfaceView)
                }
            }
            
            bottomView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.bottom.equalTo(gameView)
                make.height.equalTo(30)
            }
            
            leftActivityIndicator.snp_remakeConstraints {
                (make) -> Void in
                make.height.width.equalTo(20)
                make.centerX.centerY.equalTo(leftSurfaceView)
            }
            
            rightActivityIndicator.snp_remakeConstraints {
                (make) -> Void in
                make.height.width.equalTo(20)
                make.centerX.centerY.equalTo(rightSurfaceView)
            }
            
            leftPlayerXPLabel.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(leftSurfaceView).offset(30)
                make.right.equalTo(leftSurfaceView).offset(-30)
                make.left.equalTo(leftSurfaceView)
            }
            
            rightPlayerXPLabel.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(rightSurfaceView).offset(30)
                make.left.equalTo(rightSurfaceView).offset(30)
                make.right.equalTo(rightSurfaceView)
            }
            
            if getInterfaceOrientation().isPortrait {
                
                gameView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(leftSurfaceView.snp_bottom)
                    make.left.right.equalTo(view)
                    make.height.equalTo(view).multipliedBy(0.15)
                }
                
                if let _ = unityView.superview {
                    unityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(leftSurfaceView.snp_bottom)
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(self.view).multipliedBy(0.15)
                    }
                }
                
            } else {
                
                gameView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(leftSurfaceView.snp_bottom)
                    make.left.right.bottom.equalTo(self.view)
                }
                
                if let _ = unityView.superview {
                    unityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(leftSurfaceView.snp_bottom)
                        make.left.right.bottom.equalTo(self.view)
                    }
                }
            }
        }
        // END
        
        if self.mode == .WISH {
            
            // BEGIN
            wishView.hidden = false
            wishView.updateConstraints()
            gameView.wishMode()
            
            bottomView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.bottom.equalTo(gameView)
                make.height.equalTo(30)
            }
            
            if getInterfaceOrientation().isPortrait {
                
                gameView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view).offset(getWishHeight())
                    make.left.right.equalTo(self.view)
                    make.height.equalTo(self.view).multipliedBy(0.1)
                }
                
            } else {
                
                gameView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view).offset(getWishHeight())
                    make.left.right.bottom.equalTo(self.view)
                }
            }
            
            if winner == .LEFT {
                
                leftSurfaceView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view)
                    make.left.equalTo(self.view)
                    make.width.equalTo(self.view).multipliedBy(0.34)
                    make.height.equalTo(getWishHeight() * 0.5)
                }
                
                rightSurfaceView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.width.equalTo(self.view).multipliedBy(0.66)
                    make.height.equalTo(getWishHeight())
                }
                
                wishView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(leftSurfaceView.snp_bottom)
                    make.left.right.equalTo(leftSurfaceView)
                    make.bottom.equalTo(rightSurfaceView)
                }
                
                self.doAnimationOnce()
                
            } else {
                
                wishView.updateConstraints()
                
                leftSurfaceView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view)
                    make.left.equalTo(self.view)
                    make.width.equalTo(self.view).multipliedBy(0.66)
                    make.height.equalTo(getWishHeight())
                }
                
                rightSurfaceView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.width.equalTo(self.view).multipliedBy(0.34)
                    make.height.equalTo(getWishHeight() * 0.5)
                }
                
                wishView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.equalTo(rightSurfaceView.snp_bottom)
                    make.left.right.equalTo(rightSurfaceView)
                    make.bottom.equalTo(leftSurfaceView)
                }
                
                self.doAnimationOnce()
                
            }
            // END
        }
    }
    
    private func doAnimationOnce() {
        if !isAnimationBlock {
            leftSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
            rightSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
            wishView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
        }
        
        self.isAnimationBlock = true
    }
    
    private func initWSViewModel(model:AnyObject?) {
        
        // MARK initialize when GameViewController
        if let model = model as? WSGameCreateEntity,
            let game = model.game {
            wsViewModel = WSSessionViewModel(sessionId: game.id)
        }
        
        // MARK initialize when SpectatorViewController
        if let model = model as? GameSessionsEntity {
            wsViewModel = WSSessionViewModel(sessionId: model.id)
        }
    }
    
    private func bindPingTimer() {
        if let viewModel = wsViewModel {
            viewModel.runPingTimer()
        }
    }
    
    private func unbindPingTimer() {
        if let viewModel = wsViewModel {
            viewModel.destroyPingTimer()
        }
    }
    
    private func configureStatusBar(reverse:Bool) {
        // MARK reverse need for ident view.y before screen rotate
        if reverse {
            if !self.getInterfaceOrientation().isLandscape {
                self.view.y = 20
            } else {
                self.view.y = 0
            }
        } else {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                [weak self] in
                if self!.getInterfaceOrientation().isLandscape {
                    self?.view.y = 0
                } else {
                    self?.view.y = 20
                }
            }
        }
    }
    
    private func dummyConfiguration() {
        
        #if DEBUG
            leftSurfaceView.backgroundColor = UIColor.greenColor()
            rightSurfaceView.backgroundColor = UIColor.yellowColor()
            gameView.backgroundColor = UIColor.redColor()
            chatView.backgroundColor = UIColor.blueColor()
            messageView.backgroundColor = UIColor.orangeColor()
        #else
            
        #endif
    }
    
    private func bindObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(didHideKeyboard),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(willChangeKeyboardFrame(_:)),
                                                         name: UIKeyboardWillChangeFrameNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(didEnterBackground),
                                                         name: UIApplicationDidEnterBackgroundNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(unityMessageAction(_:)),
                                                         name: "UnityGameMessageNotification",
                                                         object: nil)
        

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(rockSpockUnityMessageAction(_:)),
                                                         name: "RockSpockMessageNotification",
                                                         object: nil)

        // MARK: Message Router
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(messageRouterObtainActivity(_:)),
                                                         name: "MessageRouterObtainActivity",
                                                         object: nil)
        
        // MARK: RockSpock Message Router
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(unityRockSpockObtainActivity(_:)),
                                                         name: "RockSpockMessageRouterObtainActivity",
                                                         object: nil)
        
        // MARK: SpinTheDisks Message Router
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(unitySpinTheDisksObtainActivity(_:)),
                                                         name: "SpinTheDisksMessageRouterObtainActivity",
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(spinTheDisksMessageAction(_:)),
                                                         name: "SpinTheDisksMessageNotification",
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(handleSocketNotification(_:)),
                                                         name: "SocketNotifiction",
                                                         object: nil)
        
        //SocketNotifiction
    }
    
    
    
    func consideGameType(dictionary:[String:AnyObject]) {
        guard let model = viewModel?.gameModel.value else { return }
        guard let value = unityEntityFactory.createEntity(dictionary) else { return }
        guard let jsonValue = value.toJSONString() else { return }
        let gameType = model.game
        
        switch gameType {
        case GameID.SPIN_THE_DISKS.rawValue:
            UnitySendMessage("SpinTheDisksMessageRouter", "OnMessage", jsonValue)
            break;
        case GameID.ROCK_SPOCK.rawValue:
            UnitySendMessage("RockSpockMessageRouter", "OnMessage", jsonValue)
            break
        default:
            break
        }
    }
    
    func handleSocketNotification(notification: NSNotification) {
        guard let object = notification.object else { return }
        guard object is [String:AnyObject] else { return }
        if let dictionary = object as? [String:AnyObject] {
            self.consideGameType(dictionary)
        }
    }
    
    func messageRouterObtainActivity(notification: NSNotification) {
        self.viewModel?.initialUnityGame()
    }
    
    func unitySpinTheDisksObtainActivity(notification: NSNotification) {
        if let json = GameStateSingleton.shared.gameInitChachedStateObject?.toJSONString() {
            UnityManager().sendMessage("SpinTheDisksMessageRouter", method: "OnMessage", value: json)
        }
    }
    
    func unityRockSpockObtainActivity(notification: NSNotification) {
        //viewModel?.initialUnityGame()
        if let json = GameStateSingleton.shared.gameInitChachedStateObject?.toJSONString() {
            UnityManager().sendMessage("RockSpockMessageRouter", method: "OnMessage", value: json)
        }
    }

    private func unbindObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UnityGameMessageNotification", object: nil)
    }
    
    private func bindSignals() {
        guard let wsViewModel = wsViewModel else { return }
        guard let viewModel = viewModel else { return }
        
        wsViewModel.playerReadySignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else { return }
                
                if message.id == viewModel.leftPlayerModel.value?.id {
                    strongSelf.gameView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Normal, cornerRadius: 2)
                    strongSelf.gameView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                } else {
                    strongSelf.gameView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Normal, cornerRadius: 2)
                    strongSelf.gameView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
        }
        
        wsViewModel.gameFoundSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self else { return }
                
                guard let message = observer.value else {
                    return
                }
        }
        
        wsViewModel.gameMessageSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else { return }
                
                strongSelf.chatView.addNewMessage(message)
        }
        
        wsViewModel.spectatorConnectedSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else { return }
                
                strongSelf.spectatorsCount = strongSelf.spectatorsCount + 1
                strongSelf.chatView.spectatorsCount.text = "\(strongSelf.spectatorsCount)"
        }
        
        wsViewModel.gameStateSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                ////////////////////////////////////////////////////////////////////////
                
                guard let strongSelf = self,
                    let message = observer.value,
                    let data = message.data else { return }
                
                strongSelf.resultData = data
                
                for item in data.playersData {
                    if item.id == viewModel.leftPlayerModel.value?.id {
                        strongSelf.leftPlayerInfoView.updateIndicatorsFromState(item.wins)
                        if item.wins > 0 {
                            for _ in 1 ... item.wins {
                                strongSelf.winnersArray.append(item.id)
                            }
                        }
                    } else {
                        strongSelf.rightPlayerInfoView.updateIndicatorsFromState(item.wins)
                        if item.wins > 0 {
                            for _ in 1 ... item.wins {
                                strongSelf.winnersArray.append(item.id)
                            }
                        }
                    }
                }
                
                strongSelf.handleRoundIndicators(strongSelf.winnersArray)
                
                ////////////////////////////////////////////////////////////////////////
        }
        
        wsViewModel.gameRoundResultSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else { return }
                
                if message.final {
                    if message.winner_id == viewModel.leftPlayerModel.value?.id {
                        strongSelf.winner = .LEFT
                    } else {
                        strongSelf.winner = .RIGHT
                    }
                }
                
                if message.winner_id != 0 {
                    strongSelf.winnersArray.append(message.winner_id)
                }
                
                strongSelf.handleRoundIndicators(strongSelf.winnersArray)
        }
        
        wsViewModel.sessionStateSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value
                    else { return }
                
                strongSelf.onSessionState(message)
        }
        
        wsViewModel.userDisconnectedSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else {return}
                
                strongSelf.playerForceDisconneted(message)
        }
        
        wsViewModel.gameResultSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value else {return}
                
                if strongSelf.mode == .WISH {
                    // exit wish mode
                }
                // wait 5 second while users voting after finish
                NSTimer.scheduledTimerWithTimeInterval(5, target: strongSelf, selector: #selector(strongSelf.finishAction), userInfo: nil, repeats: false)
                
                guard let state = message.sessionState else { return }
                if state.playersStats.count > 1 {
                    //WSPlayerStats
                    for item in state.playersStats {
                        if item.id == viewModel.leftPlayerModel.value?.id {
                            // add left player xp
                            strongSelf.addXp(.LEFT, count: item.exp)
                        } else {
                            // add right player xp
                            strongSelf.addXp(.RIGHT, count: item.exp)
                        }
                    }
                } else {
                    debugPrint("Broken game result data")
                    return
                }
        }
    }
    
    
    public func calculateSpectatorsCount(count: Int) {
        spectatorsCount = count
        chatView.spectatorsCount.text = "\(spectatorsCount)"
    }
    
    private func calculateFontSize(orientation: UIInterfaceOrientation, reverse:Bool) {
        self.leftPlayerInfoView.updateFontSize(orientation, reverse:reverse)
        self.rightPlayerInfoView.updateFontSize(orientation, reverse:reverse)
        self.wishView.updateFontSize(orientation)
        
        if orientation.isPortrait {
            levelFontSize = 11.0
        } else {
            levelFontSize = 15.0
        }
        
        leftPlayerXPLabel.font = UIFont(name: "HelveticaNeue-Medium", size: levelFontSize)
        rightPlayerXPLabel.font = UIFont(name: "HelveticaNeue-Medium", size: levelFontSize)
    }
    
    // MARK keyboard behavior
    @objc private func didHideKeyboard() {
        self.isKeyboardShown = false
        if getInterfaceOrientation().isPortrait {
            if let _ = messageView.superview {
                messageView.snp_remakeConstraints {
                    (make) -> Void in
                    make.left.right.equalTo(view)
                    make.bottom.equalTo(view).offset(-20)
                    make.height.equalTo(40)
                }
            }
        } else {
            if let _ = messageView.superview {
                messageView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.width.height.equalTo(0)
                }
            }
        }
    }
    
    @objc private func willChangeKeyboardFrame(notification: NSNotification) {
        self.isKeyboardShown = true
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        
        if let _ = messageView.superview {
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view).offset(-(keyboardRectangle.size.height + 20))
                make.height.equalTo(40)
            }
        }
    }
    
    // MARK actions
    func leaveAction() {
        onLeave()
    }
    
    @objc private func unityMessageAction(notification: NSNotification) {
        guard let message = notification.object else { return }
        handleUnityMessage(message)
    }
    
    @objc private func spinTheDisksMessageAction(notification: NSNotification) {
        guard let message = notification.object else { return }
        handleUnityMessage(message)
    }
    
    @objc private func rockSpockUnityMessageAction(notification: NSNotification) {
        guard let message = notification.object else { return }
        handleRockSpockUnityMessage(message)
    }
    
    private func handleUnityMessage(message:AnyObject) {
        
        guard let json = convertStringToDictionary(message as! String),
            let category = Mapper<UnityMessage>().map(json),
            let type = category.type,
            let wsViewModel = wsViewModel,
            let viewModel = viewModel else { return }
        
        if type == 0 {
            wsViewModel.sendReadyMessage(viewModel.leftPlayerModel.value?.id) // needed send current player id
        } else if type == 1 {
            guard let message = category.message,
                let messageJson = convertStringToDictionary(message),
                let moveMessage = Mapper<WSGameMoveMessage>().map(messageJson) else { return }
            
            wsViewModel.sendMoveMessage(moveMessage)
        }
    }
    
   private func handleRockSpockUnityMessage(message:AnyObject) {
        
        guard let json = convertStringToDictionary(message as! String),
            let category = Mapper<UnityMessage>().map(json),
            let type = category.type,
            let wsViewModel = wsViewModel,
            let viewModel = viewModel else { return }
        
        if type == 0 {
            wsViewModel.sendReadyMessage(viewModel.leftPlayerModel.value?.id) // needed send current player id
        } else if type == 1 {
            
            guard let message = category.message,
                let messageJson = convertStringToDictionary(message),
                let moveMessage = Mapper<MoveRockSpockMessage>().map(messageJson) else { return }
                
            wsViewModel.sendMoveRockSpockMessage(moveMessage)
            
        } else if type == 1005 {
            //handleGameResult()
        }
    }
    
    func handleGameResult() {
//        guard let viewModel = viewModel else { return }
//        
//        if let resultData = resultData {
//            for item in resultData.playersData {
//                if item.id == viewModel.leftPlayerModel.value?.id {
//                    leftPlayerInfoView.updateIndicatorsFromState(item.wins)
//                    if item.wins > 0 {
//                        for _ in 1 ... item.wins {
//                            winnersArray.append(item.id)
//                        }
//                    }
//                } else {
//                    rightPlayerInfoView.updateIndicatorsFromState(item.wins)
//                    if item.wins > 0 {
//                        for _ in 1 ... item.wins {
//                            winnersArray.append(item.id)
//                        }
//                    }
//                }
//            }
//            
//            handleRoundIndicators(winnersArray)
//        }
    
    }
    
    @objc private func didEnterBackground() {
        onEnterBackground()
    }
    
    @objc private func leftInfoAction() {
        leftPlayerInfoView.placeholderView.hidden = leftPlayerInfoView.placeholderView.hidden ? false : true
    }
    
    @objc private func rightInfoAction() {
        rightPlayerInfoView.placeholderView.hidden = rightPlayerInfoView.placeholderView.hidden ? false : true
    }
    
    @objc private func sendMessageAction() {
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil)
        } else {
            let text = messageView.messageTextView.text;
            let spacesCount = text.characters.filter { $0 == " " }.count
            let charctersCount = text.characters.count
            if spacesCount == charctersCount {
                messageView.messageTextView.text = ""
                messageView.sendMessageButton.enabled = false
            } else {
                guard let viewModel = viewModel else { return }
                guard let wsViewModel = wsViewModel else { return }
                wsViewModel.sendMessage(text)
                messageView.messageTextView.text = ""
                messageView.sendMessageButton.enabled = false
                chatView.addNewMessage(WSGameChatMessageEntity.createWSGameChatEntity(text, sender: viewModel.getSelfUser()!))
            }
        }
    }
    
    @objc private func tapAction() {
        if !isKeyboardShown {
            if self.mode != .WISH {
                leftPlayerInfoView.hidden = leftPlayerInfoView.hidden ? false : true
                rightPlayerInfoView.hidden = rightPlayerInfoView.hidden ? false : true
                bottomView.hidden = bottomView.hidden ? false : true
            }
            
            if self.mode == .FINISH {
                leftPlayerXPLabel.hidden = leftPlayerXPLabel.hidden ? false : true
                rightPlayerXPLabel.hidden = rightPlayerXPLabel.hidden ? false : true
            }
        } else {
            self.view.endEditing(true)
        }
    }
    
    @objc private func finishAction() {
        self.onFinish()
    }
    
     func wishMode() {
        self.orientation = .ALL
        self.mode = .WISH
        self.updateViewConstraints()
        self.unityView.removeFromSuperview()
        self.leftPlayerInfoView.removeFromSuperview()
        self.rightPlayerInfoView.removeFromSuperview()
    }
    
    private func playerForceDisconneted(model:WSPlayerDisconnectedEntity) {
        guard let user = model.user else { return }
        
        if self.spectatorsCount > 0 {
            self.calculateSpectatorsCount(self.spectatorsCount - 1)
        }
        
        if user.closed_session {
            if self.mode == .WISH {
                if wishView.superview != nil {
                    self.wishView.removeFromSuperview()
                }
            }
            self.onFinish()
        }
    }
    
    // MARK
    public func onLeave() {
        
    }
    
    public func onFinish() {
        self.orientation = .ALL
        self.mode = .FINISH
        if let _ = unityView.superview {
            unityView.removeFromSuperview()
        }
        
        gameView.finishMode()
        
        if leftPlayerInfoView.superview == nil {
            self.leftSurfaceView.addSubview(leftPlayerInfoView)
        }
        
        if rightPlayerInfoView.superview == nil {
            self.rightSurfaceView.addSubview(rightPlayerInfoView)
        }
        
        if wishView.superview != nil {
            self.wishView.removeFromSuperview()
        }
        
        self.updateViewConstraints()
    }
    
    public func onEnterBackground() {
        orientation = .PORTRAIT
    }
    
    private func handleRoundIndicators(ids: [Int]) {
        guard let viewModel = viewModel else { return }
        var firstIds = [Int]()
        var secondIds = [Int]()
        
        if !ids.isEmpty {
            for id in ids {
                if id == viewModel.leftPlayerModel.value?.id {
                    firstIds.append(id)
                } else {
                    secondIds.append(id)
                }
            }
        }
        self.leftPlayerInfoView.updateIndicators(firstIds)
        self.rightPlayerInfoView.updateIndicators(secondIds)
    }
    
    func onSessionState(model:WSSessionState) {
        let type = model.type
        
        if type == SessionEvents.SESSION_STATE.rawValue {
            guard let state = model.sessionState?.state else { return }
            
            if let spectators = model.sessionState?.spectators {
                self.calculateSpectatorsCount(spectators)
            }
            
            if state == GameSessionState.STATE_EXECUTION.rawValue {
                
                guard let looserID = model.sessionState?.loserID else { return }
                
                if viewModel?.leftPlayerModel.value?.id == looserID || viewModel?.currentId == looserID {
                    self.winner = .RIGHT
                } else {
                    self.winner = .LEFT
                }
                
                self.wishMode()
            }
        }
        
        if type == SessionEvents.BEGIN_EXECUTION.rawValue {
            self.wishMode()
            
        }
        
        if type == SessionEvents.LOSER_DONE_HIS_PERFORMANCE.rawValue {
            self.looserDoneMode()
        }
    }
    
    private func looserDoneMode() {
        self.mode = .DONE
        self.leftSurfaceView.addSubview(leftPlayerInfoView)
        self.rightSurfaceView.addSubview(rightPlayerInfoView)
        self.wishView.removeFromSuperview()
        self.updateViewConstraints()
    }
    
    func addXp(winner:WinnerMode, count:Int) {
        if winner == .LEFT {
            leftPlayerInfoView.hideIndicators(true)
            leftPlayerXPLabel.hidden = false
            leftPlayerXPLabel.text = count > 0 ? "+ \(count) \(R.string.localizable.xp())" : "\(count) \(R.string.localizable.xp())"
        }
        
        if winner == .RIGHT {
            rightPlayerInfoView.hideIndicators(true)
            rightPlayerXPLabel.hidden = false
            rightPlayerXPLabel.text = count > 0 ? "+ \(count) \(R.string.localizable.xp())" : "\(count) \(R.string.localizable.xp())"
        }
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    deinit {
        print("DEINIT: ************")
        UnitySendMessage("MessageRouter", "CleanSceneState","")
        
        if unityView.superview != nil {
            unityView.removeFromSuperview()
        }
        unityView = nil
        Swift.debugPrint("deinit called")
    }
    
}