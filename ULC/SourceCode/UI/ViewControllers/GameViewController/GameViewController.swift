//
//  GameViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import VideoCore
import KSYMediaPlayer
import ReactiveCocoa
import ObjectMapper

class GameViewController: GeneralGameViewController, GameBehaviorDelegate {

    var streamSession: VCSimpleSession?
    var rtmpPlayer: KSYMoviePlayerController?
    var playbackTimer: NSTimer?
    
    var rightPlayerUseCase:PlayerUseCase?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        guard let viewModel = viewModel else { return }
        viewModel.cleanUpUnityState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        guard let wsViewModel = wsViewModel else { return }
        wsViewModel.resume()
        
        if let _view = UnityGetGLView() where _view.hidden{
            _view.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mode = .STREAMER
        self.addCustomViews()
        self.bindSignals()
        if let model = model {
            viewModel = GameViewModel(model: model)
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { _ in
            self.bindStream()
            self.bindPlayback()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.updateUIForGameModes()
    }
    
    override func onLeave() {
        super.onLeave()
        
        if self.mode == .FINISH {
            leave()
        } else {
            let alert = UIAlertController(title: R.string.localizable.leave_warning(), message: R.string.localizable.leave_alert_description(), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: R.string.localizable.ok().uppercaseString, style: UIAlertActionStyle.Default, handler: {
                [weak self] action in
                guard let strongSelf = self else { return }
                    strongSelf.leave()
                }))
            self.presentViewController(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor(named: .LoginButtonNormal)
        }
    }
    
    private func leave() {
        self.close()
        orientation = .PORTRAIT
        wsViewModel?.endSession()
        guard let viewModel = viewModel else { return }
        viewModel.cleanUpUnityState()
    }
    
    private func close() {
        releasePlayback()
        releaseStream()
        
        if let _ = self.presentingViewController {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    override func onEnterBackground() {
        super.onEnterBackground()
        self.close()
    }
    
    override func onSessionState(model: WSSessionState) {
        super.onSessionState(model)
        let type = model.type
        
        if type == SessionEvents.SESSION_STATE.rawValue {
            guard let state = model.sessionState?.state else { return }
            
            if state == GameSessionState.STATE_GAME.rawValue {
                
            }
            
            if state == GameSessionState.STATE_EXECUTION.rawValue {
                configureWishView()
            }
            
            if state == GameSessionState.STATE_CALCULATIONS.rawValue {
                
            }
            
            if state == GameSessionState.STATE_RATING.rawValue {
                gameView.commonMode()
                gameView.mainPlaceholderLabel.text = R.string.localizable.now_spectators_voting_you()
            }
            
            if state == GameSessionState.STATE_SESSION_END.rawValue {
                
            }
        }
        
        if type == SessionEvents.BEGIN_EXECUTION.rawValue {
            configureWishView()
        }
        
        if type == SessionEvents.LOSER_DONE_HIS_PERFORMANCE.rawValue {
            self.looserDoneMode()
        }
    }
    
    private func configureWishView() {
        if winner == .LEFT {
            wishView.finishButton.hidden = true
            wishView.finishButton.enabled = false
            wishView.descriptionLabel.text = R.string.localizable.wish_winner_title()
        } else {
            wishView.finishButton.hidden = false
            wishView.finishButton.enabled = true
            wishView.descriptionLabel.text = R.string.localizable.finish_alert_description()
        }
    }
    
    private func addCustomViews() {
        bottomView.initWithMode(.GAME)
        bottomView.gradientView.initClearGradient([0.0, 0.0])
        bottomView.leaveButton.addTarget(self, action: #selector(leaveAction), forControlEvents: .TouchUpInside)
        
        gameView.leftPlayerButton.addTarget(self, action: #selector(readyAction), forControlEvents: .TouchUpInside)
        if wishView.superview != nil {
            self.leftPlayerInfoView.showCameraSwitchButton()
            self.leftPlayerInfoView.cameraSwitchButton.addTarget(self, action: #selector(switchCameraAction), forControlEvents: .TouchUpInside)
            wishView.finishButton.addTarget(self, action: #selector(wishAction), forControlEvents: .TouchUpInside)
        }
        // handle gameView target
    }
    
    private func bindPlayback() {
        guard let viewModel = viewModel else { return }
        
        self.rightPlayerUseCase = PlayerUseCaseProvider().makeGamePlayerUseCase(self)
        
        //let playbackURL = NSURL(string: )
        
        let apiEndpoint = getBasePlaybackURL()
        let path = "\(apiEndpoint)/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.rightPlayerModel.value?.id))"
    
        guard let playbackView = rightPlayerUseCase?.view(path) else { return }
        
        if playbackView.superview == nil {
            
            //guard let rtmpPlayer = rtmpPlayer else { return }
            
            playbackView.contentMode = .ScaleAspectFit
            playbackView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight]
            playbackView.frame = rightSurfaceView.bounds
            
            //rtmpPlayer.shouldEnableVideoPostProcessing = true
            //rtmpPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX
            //rtmpPlayer.videoDecoderMode = .Hardware
            //rtmpPlayer.setTimeout(5, readTimeout: 10)
            //rtmpPlayer.setVolume(0.75, rigthVolume: 0.75)
            
            rightSurfaceView.addSubview(playbackView)
            rightSurfaceView.bringSubviewToFront(rightPlayerInfoView)
            rightSurfaceView.bringSubviewToFront(rightActivityIndicator)
            rightSurfaceView.bringSubviewToFront(rightPlayerXPLabel)
            //rtmpPlayer.prepareToPlay()
            bindPlaybackTimer()
            rightActivityIndicator.startAnimating()
        }
    }
    
    private func bindStream() {
        guard let viewModel = viewModel else { return }
        let videoCaptureSize = CGSizeMake(320, 240)
        
        streamSession = VCSimpleSession(videoSize: videoCaptureSize,
                                        frameRate: 24, bitrate: 450000,
                                        useInterfaceOrientation: false,
                                        cameraState: VCCameraState.Front,
                                        aspectMode: VCAspectMode.AscpectModeFill)
        
        guard let streamSession = streamSession else { return }
        
        streamSession.useAdaptiveBitrate = false
        streamSession.micGain = 0.0
        streamSession.orientationLocked = false
        streamSession.delegate = self
        
        streamSession.startRtmpSessionWithURL("\(getBasePlaybackURL())", andStreamKey:
            videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.leftPlayerModel.value?.id))
        
        streamSession.previewView.frame = leftSurfaceView.bounds
        leftSurfaceView.addSubview(streamSession.previewView)
        leftSurfaceView.bringSubviewToFront(leftPlayerInfoView)
        leftSurfaceView.bringSubviewToFront(leftActivityIndicator)
        leftSurfaceView.bringSubviewToFront(leftPlayerXPLabel)
    }
    
    private func bindPlaybackTimer() {
        if playbackTimer == nil {
            playbackTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD, target: self, selector: #selector(handlePlayback), userInfo: nil, repeats: true)
        }
    }
    
    private func updateUIForGameModes() {
        guard let mode = self.mode else { return }
        
        switch mode {
            
        case .WISH:
            //
            break
            
        case .DONE:
            
            break
            
        case .END:
            break
            
        case .FINISH:
            break
            
        case .GAME:
            if let _ = unityView.superview {
                unityView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.bottom.equalTo(self.view)
                }
            }
            break
            
        case .NOT_SUPPORTED:
            break
            
        case .SPECTATOR:
            break
            
        case .START:
            break
            
        case .STREAMER:
            break
            
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
            let viewModel = viewModel else { return }
        
        wsViewModel.gameStateSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self,
                    let message = observer.value,
                    let data = message.data else { return }
                
                if data.playersData.count > 1 {
                    if data.playersData[0].ready && data.playersData[1].ready {
                        strongSelf.gameFullscreenMode()
                    }
                } else {
                    debugPrint("Broken gameStateSignal data")
                    return
                }
        }
        
        wsViewModel.startRoundSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let strongSelf = self else { return }
                strongSelf.gameFullscreenMode()
        }
        
        wsViewModel.gameRoundResultSignal.observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let strongSelf = self else { return }
               // strongSelf.gameDefaultMode()
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
            if self.mode == .GAME {
                self.gameDefaultMode()
            } else if self.mode == .WISH {
                self.gameDefaultMode()
                self.wishMode()
            }
        }
    }
    
    private func releasePlayback() {
        if let playbackTimer = playbackTimer {
            playbackTimer.invalidate()
            rightPlayerUseCase?.releasePlayer()
        }
    }
    
    private func releaseStream() {
        guard let streamSession = streamSession else { return }
        streamSession.endRtmpSession()
    }
    
    @objc private func handlePlayback() {
        guard let viewModel = viewModel else { return }
        rightPlayerUseCase?.reconnectPlayer(withPath: "\(getBasePlaybackURL())/\(videostreamNamePattern(viewModel.gameModel.value?.id, playerID: viewModel.rightPlayerModel.value?.id))")
    }
    
    // MARK game modes
    private func gameFullscreenMode() {
        self.orientation = .LANDSCAPE
        self.mode = .GAME
        
        forceSwitchOrientationToLandscape()
        
        self.gameView.hidden = true
        self.unityView.hidden = true
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.unityView.hidden = false // Some UI feature for nice swithing to fullscreen when unity initialization in progress
        }
        self.view.bringSubviewToFront(unityView)
        view.y = 0
        leftPlayerInfoView.hidden = true
        rightPlayerInfoView.hidden = true
        leftSurfaceView.hidden = true
        rightSurfaceView.hidden = true
        bottomView.hidden = true
        
        self.updateViewConstraints()
    }
    
    private func gameDefaultMode() {
        self.orientation = .ALL
        self.mode = .STREAMER
        
        self.gameView.hidden = false
        self.unityView.hidden = false

        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        leftSurfaceView.hidden = false
        rightSurfaceView.hidden = false
        bottomView.hidden = false
        self.view.needsUpdateConstraints()
        
        unityView.hidden = true
        gameView.leftPlayerButton.enabled = true
        gameView.leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Normal, cornerRadius: 2)
        gameView.rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Normal, cornerRadius: 2)
    }
    
    // MARK player modes
    private func looserDoneMode() {
        self.gameView.mainPlaceholderLabel.text = R.string.localizable.now_spectators_voting_you()
    }
    
    override func onFinish() {
        super.onFinish()
        self.mode = .FINISH
        
        self.gameView.hidden = false
        
        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        leftSurfaceView.hidden = false
        rightSurfaceView.hidden = false
        bottomView.hidden = false
        self.view.needsUpdateConstraints()
    }
    
    // MARK actions
    @objc private func readyAction() {
        guard let wsViewModel = wsViewModel,
            let viewModel = viewModel else { return }
        gameView.leftPlayerButton.enabled = false
        gameView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
        wsViewModel.sendReadyMessage(viewModel.leftPlayerModel.value?.id)
    }
    
    @objc private func switchCameraAction() {
        guard let streamSession = streamSession else { return }
        if streamSession.cameraState == .Front {
            streamSession.cameraState = .Back
        } else {
            streamSession.cameraState = .Front
        }
    }
    
    @objc private func wishAction() {
        guard let wsViewModel = wsViewModel else { return }
        wsViewModel.donePerfomance()
        self.wishView.finishButton.backgroundColor = UIColor.orangeColor()
        self.wishView.finishButton.enabled = false
    }
    
    deinit {
        
    }
    
}
