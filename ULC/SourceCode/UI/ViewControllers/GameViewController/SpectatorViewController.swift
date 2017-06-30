//
//  SpectatorViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import KSYMediaPlayer
import ReactiveCocoa
import ObjectMapper

class SpectatorViewController: GeneralGameViewController {
    
    var leftRTMPPlayer: KSYMoviePlayerController?
    var rightRTMPPlayer: KSYMoviePlayerController?
    var rateViewController: RateCircleViewController?
    
    var leftPlaybackTimer: NSTimer?
    var rightPlaybackTimer: NSTimer?
    var isGameSupported = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let wsViewModel = wsViewModel,
            let viewModel = viewModel else { return }
        
        wsViewModel.resume()
        
        if let model = model as? GameSessionsEntity {
            viewModel.initUnitySpectator(model)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // on leave
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let model = model as? GameSessionsEntity else { return }
        
        if model.game == GameID.SPIN_THE_DISKS.rawValue  {
            isGameSupported = true
        } else if model.game == GameID.ROCK_SPOCK.rawValue {
            isGameSupported = true
        } else {
            isGameSupported = false
        }
        //isGameSupported = GameID.SPIN_THE_DISKS.rawValue || GameID.ROCK_SPOCK.rawValue == model.game
        
        self.mode = isGameSupported ? .SPECTATOR : .NOT_SUPPORTED
        
        addCustomViews()
        bindSignals()
        
        if self.mode == .NOT_SUPPORTED {
            self.gameView.gameNotSupportedMode()
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.bindLeftPlayback()
            strongSelf.bindRightPlayback()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if let rateViewController = rateViewController {
            self.view.bringSubviewToFront(rateViewController.view)
        }
        
        if self.mode == .NOT_SUPPORTED {
            
        }
    }
    
    override func onLeave() {
        super.onLeave()
        orientation = .PORTRAIT
        releasePlaybacks()
        
        if let _ = self.presentingViewController {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func onEnterBackground() {
        super.onEnterBackground()
        self.onLeave()
    }
    
    override func onSessionState(model: WSSessionState) {
        super.onSessionState(model)
        let type = model.type
        
        if type == SessionEvents.SESSION_STATE.rawValue {
            guard let state = model.sessionState?.state else { return }
            
            if state == GameSessionState.STATE_EXECUTION.rawValue {
                
            }
        }
        
        if type == SessionEvents.BEGIN_EXECUTION.rawValue {
            
        }
        
        if type == SessionEvents.LOSER_DONE_HIS_PERFORMANCE.rawValue {
            self.looserDoneMode()
        }
    }
    
    override func onFinish() {
        super.onFinish()
        if self.mode == .GAME {
            self.spectatorDefaultMode()
        }
    }
    
    @objc private func spinTheDisksAction(notification: NSNotification) {
        guard let message = notification.object else { return }
        handleUnityMessage(message)
    }
    
    @objc private func rockSpockMessageAction(notification: NSNotification) {
        guard let message = notification.object else { return }
        handleUnityMessage(message)
    }
    
    private func handleUnityMessage(message:AnyObject) {
        
        guard let json = convertStringToDictionary(message as! String),
            let category = Mapper<UnityMessage>().map(json),
            let type = category.type else { return }
        
        if type == 1005 {
            self.spectatorDefaultMode()
        }
    }
    
    private func bindSignals() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(rockSpockMessageAction(_:)),
                                                         name: "RockSpockMessageNotification",
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(spinTheDisksAction(_:)),
                                                         name: "SpinTheDisksMessageNotification",
                                                         object: nil)
        
        guard let wsViewModel = wsViewModel,
            let _ = viewModel else { return }
        
        wsViewModel.startRoundSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let strongSelf = self else { return }
                strongSelf.spectatorGameMode()
        }
        
        wsViewModel.gameStateSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value,
                    let data = message.data else { return }
                
                if data.playersData.count > 1 {
                    
                    if data.playersData[0].ready {
                        strongSelf.gameView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                    }
                    
                    if data.playersData[1].ready {
                        strongSelf.gameView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                    }
                    
                    if data.playersData[0].ready && data.playersData[1].ready {
                        strongSelf.spectatorGameMode()
                    }
                } else {
                    debugPrint("Broken gameStateSignal data")
                    return
                }
        }
        
        wsViewModel.gameRoundResultSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self else { return }
                //strongSelf.spectatorDefaultMode()
        }
        
        wsViewModel.gameRoundResultSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let strongSelf = self else { return }
        }
    }
    
    private func addCustomViews() {
        bottomView.initWithMode(.SPECTATOR)
        bottomView.gradientView.initBlackGradient([0.0, 1.0])
        bottomView.leaveButton.addTarget(self, action: #selector(leaveAction), forControlEvents: .TouchUpInside)
        
        if let leave = R.image.game_leave() {
            bottomView.leaveImageView.image = leave
        }
        
        if let next = R.image.game_next() {
            bottomView.nextImageView.image = next
        }
        
        gameView.leftPlayerButton.enabled = false
        gameView.rightPlayerButton.enabled = false
        
        //self.gameView.hidden = true
        self.unityView.hidden = false
        self.gameView.spectatorMode()
    }
    
    private func looserDoneMode() {
        //self.mode = .DONE
        self.mode = isGameSupported ? .DONE : .NOT_SUPPORTED
        
        if self.mode == .NOT_SUPPORTED {
            self.gameView.gameNotSupportedMode()
        } else {
            self.gameView.doneMode()
        }
        
        guard let model = model as? GameSessionsEntity else { return }
        self.ratePlayer(.LEFT_PLAYER, playerModels: model.players)
    }
    
    private func spectatorDefaultMode() {
        self.orientation = .ALL
        self.mode = isGameSupported ? .SPECTATOR : .NOT_SUPPORTED
        
        self.gameView.hidden = false
        self.unityView.hidden = false
        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        leftSurfaceView.hidden = false
        rightSurfaceView.hidden = false
        bottomView.hidden = false
        self.view.needsUpdateConstraints()
        
        gameView.leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
        gameView.rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
    }
    
    private func spectatorGameMode() {
        //self.mode = .GAME
        self.mode = isGameSupported ? .GAME : .NOT_SUPPORTED
        
        if self.mode != .NOT_SUPPORTED {
            self.gameView.hidden = true
        }
    }
    
    private func bindLeftPlayback() {
        
        guard let viewModel = viewModel else { return }
        
        let leftPlaybackURL = NSURL(string: "\(getBasePlaybackURL())/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.leftPlayerModel.value?.id))")
        
        leftRTMPPlayer = KSYMoviePlayerController(contentURL: leftPlaybackURL)
        
        guard let leftPlaybackView = leftRTMPPlayer?.view else { return }
        
        if leftPlaybackView.superview == nil {
            
            guard let leftRTMPPlayer = leftRTMPPlayer else { return }
            
            leftPlaybackView.contentMode = .ScaleAspectFit
            leftPlaybackView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight]
            leftPlaybackView.frame = leftSurfaceView.bounds
            
            leftRTMPPlayer.shouldEnableVideoPostProcessing = true
            leftRTMPPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX
            leftRTMPPlayer.videoDecoderMode = .Hardware
            leftRTMPPlayer.setTimeout(5, readTimeout: 10)
            leftRTMPPlayer.setVolume(0.75, rigthVolume: 0.75)
            
            leftSurfaceView.addSubview(leftPlaybackView)
            leftSurfaceView.bringSubviewToFront(leftPlayerInfoView)
            leftSurfaceView.bringSubviewToFront(leftActivityIndicator)
            leftSurfaceView.bringSubviewToFront(leftPlayerXPLabel)
            
            leftRTMPPlayer.prepareToPlay()
            bindRightPlaybackTimer()
            leftActivityIndicator.startAnimating()
        }
    }
    
    private func bindRightPlayback() {
        guard let viewModel = viewModel else { return }
        let rightPlaybackURL = NSURL(string: "\(getBasePlaybackURL())/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.rightPlayerModel.value?.id))")
        print("bindRightPlayback".uppercaseString + " \(rightPlaybackURL?.baseURL)" )
        rightRTMPPlayer = KSYMoviePlayerController(contentURL: rightPlaybackURL)
        guard let rightPlaybackView = rightRTMPPlayer?.view else { return }
        
        if rightPlaybackView.superview == nil {
            guard let rightRTMPPlayer = rightRTMPPlayer else { return }
            
            rightPlaybackView.contentMode = .ScaleAspectFit
            rightPlaybackView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight]
            rightPlaybackView.frame = rightSurfaceView.bounds
            
            rightRTMPPlayer.shouldEnableVideoPostProcessing = true
            rightRTMPPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX
            rightRTMPPlayer.videoDecoderMode = .Hardware
            rightRTMPPlayer.setTimeout(5, readTimeout: 10)
            rightRTMPPlayer.setVolume(0.75, rigthVolume: 0.75)
            
            rightSurfaceView.addSubview(rightPlaybackView)
            rightSurfaceView.bringSubviewToFront(rightPlayerInfoView)
            rightSurfaceView.bringSubviewToFront(rightActivityIndicator)
            rightSurfaceView.bringSubviewToFront(rightPlayerXPLabel)
            rightRTMPPlayer.prepareToPlay()
            bindLeftPlaybackTimer()
            rightActivityIndicator.startAnimating()
            // handle timer
        }
    }
    
    func bindLeftPlaybackTimer() {
        if leftPlaybackTimer == nil {
            leftPlaybackTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD, target: self, selector: #selector(handleLeftPlayback), userInfo: nil, repeats: true)
        }
    }
    
    func bindRightPlaybackTimer() {
        if rightPlaybackTimer == nil {
            rightPlaybackTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD, target: self, selector: #selector(handleRightPlayback), userInfo: nil, repeats: true)
        }
    }
    
    func unbindPlaybackTimers() {
    }
    
    @objc private func handleLeftPlayback() {
        guard let player = leftRTMPPlayer else { return }
        
        print("HANDLE LEFT PLAYER: \(player.playbackState.rawValue) \(player.contentURL)")
        
        switch player.playbackState {
            
        case .Interrupted:
            print("HANDLE LEFT PLAYER: \("Interrupted".uppercaseString)")
            break
            
        case .Paused:
            print("HANDLE LEFT PLAYER: \("Paused".uppercaseString)")
            break
            
        case .Playing:
            leftActivityIndicator.stopAnimating()
            print("HANDLE LEFT PLAYER: \("Playing".uppercaseString)")
            break
            
        case .Stopped:
            leftActivityIndicator.startAnimating()
            guard let viewModel = viewModel else { return }
            guard let leftPlaybackURL = NSURL(string: "\(getBasePlaybackURL())/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.leftPlayerModel.value?.id))") else { return }
            forceReconnectPlayer(player,url: leftPlaybackURL)
            print("HANDLE LEFT PLAYER: \("Stopped".uppercaseString)")
            break
            
        case .SeekingForward:
            print("HANDLE LEFT PLAYER: \("SeekingForward".uppercaseString)")
            break
            
        case .SeekingBackward:
            print("HANDLE LEFT PLAYER: \("SeekingBackward".uppercaseString)")
            break
        }
    }
    
    @objc private func handleRightPlayback() {
        guard let player = rightRTMPPlayer else { return }
        
        switch player.playbackState {
            
        case .Interrupted:
            break
            
        case .Paused:
            break
            
        case .Playing:
            rightActivityIndicator.stopAnimating()
            break
            
        case .Stopped:
            rightActivityIndicator.startAnimating()
            guard let viewModel = viewModel else { return }
            guard let rightPlaybackURL = NSURL(string: "\(getBasePlaybackURL())/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.rightPlayerModel.value?.id))") else { return }
            forceReconnectPlayer(player, url: rightPlaybackURL)
            break
            
        case .SeekingForward:
            break
            
        case .SeekingBackward:
            break
        }
    }
    
    private func releasePlaybacks() {
        if let leftRTMPPlayer = leftRTMPPlayer, let leftPlaybackTimer = leftPlaybackTimer {
            leftPlaybackTimer.invalidate()
            leftRTMPPlayer.pause()
            leftRTMPPlayer.reset(true)
            leftRTMPPlayer.stop()
        }
        leftRTMPPlayer = nil;
        leftPlaybackTimer = nil;
        
        if let rightRTMPPlayer = rightRTMPPlayer, let rightPlaybackTimer = rightPlaybackTimer  {
            rightPlaybackTimer.invalidate()
            rightRTMPPlayer.pause()
            rightRTMPPlayer.reset(true)
            rightRTMPPlayer.stop()
        }
        rightRTMPPlayer = nil;
        rightPlaybackTimer = nil;
    }
    
    private func bindRateView() {
        guard let rateViewController = R.storyboard.main.rateCircleViewController() else { return }
        self.rateViewController = rateViewController
        self.rateViewController?.delegate = self
        self.addChildViewController(rateViewController)
        self.view.addSubview(rateViewController.view)
        didMoveToParentViewController(rateViewController)
        rateViewController.start()
    }
    
    func unbindRateView() {
        if rateViewController != nil {
            rateViewController?.willMoveToParentViewController(nil)
            rateViewController?.view.removeFromSuperview()
            rateViewController?.removeFromParentViewController()
            rateViewController?.stop()
            rateViewController = nil
        }
    }
    
    func ratePlayer(player:Players, playerModels:[WSPlayerEntity]) {
        
        bindRateView()
        guard let rateViewController = rateViewController else { return }
        
        if player == .LEFT_PLAYER {
            rateViewController.updateWithModel(playerModels[0], player: .LEFT_PLAYER)
        }
        
        if player == .RIGHT_PLAYER {
            rateViewController.updateWithModel(playerModels[1], player: .RIGHT_PLAYER)
        }
    }
    
}