//
//  TwoPlayStreamerViewController.swift
//  ULC
//
//  Created by Alexey on 10/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveCocoa
import VideoCore
import KSYMediaPlayer

class TwoPlayStreamerViewController: GeneralTwoPlayViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureNotifications();
        viewModel.wsSessionViewModel?.resume()
        
        if let _view = UnityGetGLView() where _view.hidden{
            _view.hidden = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewModel.wsSessionViewModel?.pause()
    }
    
    deinit {
        unityView.removeFromSuperview()
        unityView = nil
        Swift.debugPrint("deinit called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .streamer
        winner = .none
        isPresented = .allOrientations
        configureViews();
        configureCommonViews();
        configureCommonSignals();
        configureSignals();
        resizeFont();
    }
    
    func configureNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(sendAndroidMessage),
            name: "UnityGameMessageNotification",
            object: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({
            (ctx) in
            //MARK CALLED WILL
        }) {
            (ctx) in
            // MARK CALLED DID
            self.chatView.scrollToBottom()
            self.newUnityView.updateConstraints()
            self.resizeFont();
            self.leftPlayerInfoView.setNeedsUpdateConstraints()
            self.rightPlayerInfoView.setNeedsUpdateConstraints()
            if UIApplication.sharedApplication().statusBarOrientation.isLandscape {
                self.view.y = 0
            } else {
                self.view.y = 20
            }
            self.centralizeIndicators();
        }
    }
    
    func centralizeIndicators() {
        self.leftActivityIndicator.center = CGPointMake(CGRectGetMidX(self.videoStreamPreview.bounds), CGRectGetMidY(self.videoStreamPreview.bounds));
        self.rightActivityIndicator.center = CGPointMake(CGRectGetMidX(self.rightPlaybackView.bounds), CGRectGetMidY(self.rightPlaybackView.bounds));
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        changeViewVisibility(orientation);
        var newHeight = (self.view.frame.size.width * 0.5) * 0.75
        centralizeIndicators()
        
        if let state = state {
            
            switch state {
                
            case .streamer:
                
                videoStreamPreview.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.bottom.equalTo(leftPlayerSurfaceView)
                }
                break;
                
            case .wish:
                newHeight = (self.view.frame.size.width * 0.66) * 0.75
                if self.newUnityView.hidden{
                    self.newUnityView.hidden = false
                }
                
                newUnityView.mainPlaceholderLabel.text = R.string.localizable.let_the_execution_begin()
                self.newUnityView.wishMode()
                
                if winner == .first {
                    videoStreamPreview.snp_remakeConstraints {
                        (make) in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.34)
                        make.height.equalTo(newHeight * 0.5)
                    }
                    
                    videoStreamPreview.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                    
                } else if winner == .second {
                    
                    wishView.hidden = false
                    wishView.descriptionLabel.text = R.string.localizable.finish_alert_description()
                    wishView.finishButton.addTarget(self, action: #selector(wishAction), forControlEvents: .TouchUpInside)
                    
                    wishView.updateConstraints()
                    
                    videoStreamPreview.snp_remakeConstraints {
                        (make) in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.66)
                        make.height.equalTo(newHeight)
                    }
                    videoStreamPreview.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                }
                
                break;
                
            case .finish:
                newUnityView.hidden = false
                self.newUnityView.finishMode()
                remakeCommonConstraints(newHeight, orientation: orientation)
                break;
            case .done:
                newUnityView.hidden = false
                self.newUnityView.doneMode()
                newUnityView.mainPlaceholderLabel.text = R.string.localizable.now_spectators_voting_you()
                remakeCommonConstraints(newHeight, orientation: orientation)
                
                videoStreamPreview.snp_remakeConstraints { (make) -> Void in
                    make.top.left.right.bottom.equalTo(leftPlayerSurfaceView)
                }
                break;
            default:
                break;
                
            }
        }
    }
    
    func configureViews() {
        newUnityView.streamerMode()
        view.addSubview(videoStreamPreview)
        view.addSubview(rightPlaybackView)
        rightPlaybackView.backgroundColor = .blackColor()
    //    bottomView.leaveLabel.textColor = UIColor.blackColor()
    //    bottomView.nextLabel.hidden = true
        bottomView.nextButton.hidden = true
        bottomView.nextImageView.hidden = true
        bottomView.gradientView.initClearGradient([0.0, 0.0])
        
        rightPlayerInfoView.optionButton.addTarget(self, action: #selector(hideRightOptionsAction), forControlEvents: .TouchUpInside)
        //rightPlayerInfoView.prefferButton.addTarget(self, action: #selector(prefferAction), forControlEvents: .TouchUpInside)
        rightPlayerInfoView.followButton.addTarget(self, action: #selector(followAction), forControlEvents: .TouchUpInside)
        rightPlayerInfoView.reportButton.addTarget(self, action: #selector(reportAction), forControlEvents: .TouchUpInside)
        bottomView.leaveButton.addTarget(self, action: #selector(streamerLeaveAction), forControlEvents: .TouchUpInside)
        messageView.sendMessageButton.addTarget(self, action: #selector(sendMessageAction), forControlEvents: .TouchUpInside)
        
        newUnityView.leftPlayerButton.addTarget(self, action: #selector(readyAction), forControlEvents: .TouchUpInside)
    }
    
    func readyAction() {
        newUnityView.leftPlayerButton.enabled = false
        newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
        
        viewModel.wsSessionViewModel!.sendReadyMessage(leftPlayerID)
    }
    
    func streamerLeaveAction() {
        if state == .finish {
            leaveAction(R.string.localizable.leave_session(), description: R.string.localizable.leave_session_quastion())
        } else {
            leaveAction(R.string.localizable.leave_warning(), description: R.string.localizable.leave_alert_description())
        }
    }
    
    func prefferAction() {}
    
    func followAction() {}
    
    func reportAction() {}
    
    func exitFullscreenMode() {
        isPresented = .allOrientations
        state = .streamer
        
        leftPlayerSurfaceView.hidden = false
        rightPlayerSurfaceView.hidden = false
        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        rightPlaybackView.hidden = false
        videoStreamPreview.hidden = false
        messageView.hidden = false
        rightPlayerInfoView.hidden = false
        bottomView.hidden = false
        updateViewConstraints()
        
        leftLikeViewPlaceHolder.hidden = false
        rightLikeViewPlaceHolder.hidden = false
        
        addUnityViewGestureRecognizer()
        
        newUnityView.hidden = false
        newUnityView.leftPlayerButton.enabled = true
        newUnityView.leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Normal, cornerRadius: 2)
        newUnityView.leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
        newUnityView.rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
    }
    
    func beginExecution() {
        unityView.hidden = true
        self.state = .wish
        leftPlayerInfoView.hidden = true
        rightPlayerInfoView.hidden = true
        updateViewConstraints()
        if bottomView.leaveButton.hidden {
            bottomView.leaveButton.hidden = false;
        }
        newUnityView.hidden = false
    }
    
    func finish() {
        if state == .game {
            exitFullscreenMode()
        }
        state = .finish
        newUnityView.finishMode()
        timer?.invalidate()
        updateViewConstraints()
    }
    
    func exitWishMode() {
        self.state = .streamer
        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        newUnityView.finishMode()
        wishView.descriptionLabel.text = ""
        wishView.damageConstraints()
        wishView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }
        self.updateViewConstraints()
    }
    
    func switchToFullscreenMode() {
        state = .game
        updateViewConstraints()
        doneClicked()
        if UIApplication.sharedApplication().statusBarOrientation.isPortrait {
            let value = UIInterfaceOrientation.LandscapeLeft.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
        self.newUnityView.hidden = true
        self.unityView.hidden = true
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.unityView.hidden = false
        }
        
        unityView.gestureRecognizers?.forEach { it in
            unityView.removeGestureRecognizer(it)
        }
        
        isPresented = .onlyLandscape
        view.y = 0
        
        leftPlayerSurfaceView.hidden = true
        rightPlayerSurfaceView.hidden = true
        leftPlayerInfoView.hidden = true
        rightPlayerInfoView.hidden = true
        rightPlaybackView.hidden = true
        videoStreamPreview.hidden = true

        messageView.hidden = true
        self.bottomView.hidden = true
        
        leftLikeViewPlaceHolder.hidden = true
        rightLikeViewPlaceHolder.hidden = true
        
        self.chatView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }
        self.unityView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.right.bottom.equalTo(self.view)
        }
        
        
    }
    
    func playerForceDisconnectedState(model:AnyObject){
        
        if rightRTMPPlayer != nil {
            self.lastPlaybackTime = rightRTMPPlayer.currentPlaybackTime
        }
        
        guard let entity = model as? WSPlayerDisconnectedEntity else{return;}
        
        if self.spectatorsCount > 0 {
            handleSpectatorsCount(self.spectatorsCount - 1)
        }
        
        if let user = entity.user {
            if user.closed_session {
                
                if self.state == .game {
                    self.exitFullscreenMode()
                }
                
                if self.state == .wish {
                    self.exitWishMode()
                }
                self.bottomView.hidden = false
                self.state = .finish
                self.unityView.hidden = true
                self.newUnityView.finishMode()
                self.updateViewConstraints()
            }
        }
    }
    
    func configureSignals() {
        
        viewModel.playerReadySignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                
                guard let message = observer.value else {
                    return
                }
                
                if message.id == self?.leftPlayerID {
                    self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }else {
                    self?.newUnityView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
        }
        
        viewModel.gameStateSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                
                guard let message = observer.value else {
                    return
                }
                
                if message.data?.playersData.first?.wins == 3 || message.data?.playersData.last?.wins == 3 {
                    // self?.newUnityView.hidden = true
                }
                
                if message.data?.playersData.first?.ready == true {
                    self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Normal, cornerRadius: 2)
                    self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
                
                if message.data?.playersData.last?.ready == true {
                    self?.newUnityView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
                
                if message.data?.playersData.first?.ready == true && message.data?.playersData.last?.ready == true {
                    self?.newUnityView.hidden = true
                }
                
                if message.data?.playersData.first?.ready == true && message.data?.playersData.last?.ready == true {
                    self?.switchToFullscreenMode()
                }
        }
        
        viewModel.gameRoundStartSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.switchToFullscreenMode()
        }
        
        viewModel.gameWinnerResultSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.exitFullscreenMode()
                self?.handleRoundIndicators(message)
        }
        
        viewModel.playerDisconnectedSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.playerForceDisconnectedState(message)
        }
        
        self.viewModel.gameFinalResultSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let message = observer.value else {
                    return
                }
                if self?.state == .wish {
                    self?.exitWishMode()
                }
                if let strongSelf = self {
                    strongSelf.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: strongSelf, selector: #selector(strongSelf.finish), userInfo: nil, repeats: false)
                }
                
                message.sessionState?.playersStats.forEach {
                    it in
                    
                    if it.id == self?.leftPlayerID {
                        self?.addCurrentPlayerXp(it.exp)
                    } else {
                        self?.addOpponentPlayerXp(it.exp)
                    }
                }
        }
        
        viewModel.gameRoundResultSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                
                guard let message = observer.value else {
                    return
                }
                
                if message.final {
                    if message.winner_id == self?.leftPlayerID {
                        self?.winner = .first
                    } else {
                        self?.winner = .second
                    }
                }
        }
        
        viewModel.sessionStateSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                
                guard let message = observer.value, let strongSelf = self else {
                    return
                }
                
                switch message.type {
                case SessionEvents.SESSION_STATE.rawValue:
                    
                    if let spectators = message.sessionState?.spectators {
                        self?.handleSpectatorsCount(spectators)
                    }
                    
                    if let state = message.sessionState?.state {
                        switch state {
                        case 1:
                            
                            break;
                        case 2:
                            if let looserId = message.sessionState?.loserID {
                                if looserId == self?.leftPlayerID {
                                    strongSelf.winner = .second
                                } else {
                                    strongSelf.winner = .first
                                }
                            }
                            strongSelf.beginExecution()
                            break;
                        case 3:
                            self?.newUnityView.commonMode()
                            self?.newUnityView.mainPlaceholderLabel.text = R.string.localizable.now_spectators_voting_you()
                            break;
                        default:
                            break;
                        }
                    }
                    break
                case SessionEvents.BEGIN_EXECUTION.rawValue:
                    strongSelf.beginExecution()
                    break
                case SessionEvents.LOSER_DONE_HIS_PERFORMANCE.rawValue:
                    strongSelf.wishView.finishButton.backgroundColor = UIColor.orangeColor()
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) { _ in
                        strongSelf.looserDoneHisPerfomance()
                    }
                    break
                    
                default:
                    break
                }
        }
        
        viewModel.fetchGameData()
            .producer
            .observeOn(UIScheduler())
            .startWithSignal({ [weak self] observer, disposable in
                observer.observeCompleted({
                    
                    if let videoBaseURL = self?.viewModel.game.value?.game?.videoUrl {
                        self?.videoBaseURL = videoBaseURL
                    }
                    
                    if let currentPlayerData = self?.viewModel.currentPlayer.value {
                        self?.leftPlayerInfoView.updateWithModel(currentPlayerData)
                        self?.leftPlayerID = currentPlayerData.id
                    }
                    
                    if let opponentPlayerData = self?.viewModel.opponentPlayer.value {
                        self?.rightPlayerInfoView.updateWithModel(opponentPlayerData)
                        self?.rightPlayerID = opponentPlayerData.id
                    }
                    
                    if let session = self?.viewModel.game.value {
                        if let sessionID = session.game?.id {
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) { _ in
                                self?.initStream(sessionID, userID: self?.leftPlayerID)
                                self?.initPlayback(sessionID, userID: self?.rightPlayerID)
                            }
                        }
                    }
                })
			})
    }
    
    
    @objc func sendAndroidMessage(notification: NSNotification) {
        if let object = notification.object {
            self.viewModel.handleUnityMessage(object)
        }
    }
    
    func looserDoneHisPerfomance() {
        self.state = .done
        wishView.damageConstraints()
        wishView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }
        leftPlayerInfoView.hidden = false
        rightPlayerInfoView.hidden = false
        newUnityView.doneMode()
        newUnityView.mainPlaceholderLabel.text = R.string.localizable.now_spectators_voting_you()
        wishView.descriptionLabel.text = ""
        self.updateViewConstraints()
    }
    
    func leftPlayerIsWinner(newHeight: CGFloat) {
        
    }
    
    func wishAction() {
        viewModel.donePerfomance()
    }
    
    func rightPlayerIsWinner(newHeight: CGFloat) {
    }
    
    func initStream(sessionID: Int?, userID: Int?) {
        let newHeight = (leftPlayerSurfaceView.width / 4) * 3;
        videoStreamPreview.width = leftPlayerSurfaceView.width
        videoStreamPreview.height = newHeight
        let videoCaptureSize = CGSizeMake(320, 240);
        
        streamingSession = VCSimpleSession(videoSize: videoCaptureSize,
                                           frameRate: 24, bitrate: 450000,
                                           useInterfaceOrientation: false,
                                           cameraState: VCCameraState.Front,
                                           aspectMode: VCAspectMode.AscpectModeFill);
        streamingSession.useAdaptiveBitrate = false;
        
        if let sessionID = sessionID {
            if let userID = userID {
                streamingSession.startRtmpSessionWithURL("\(self.videoBaseURL)/", andStreamKey: videostreamNamePattern(sessionID, playerID: userID))
            }
        }
        
        streamingSession.micGain = 0.0
        streamingSession.orientationLocked = false;
        streamingSession.delegate = self;
        self.videoStreamPreview.addSubview(streamingSession.previewView);
        streamingSession.previewView.frame = self.leftPlayerSurfaceView.bounds;
    }
    
    func initPlayback(sessionID: Int?, userID: Int?) {
        
        rightRTMPPlayer = KSYMoviePlayerController(contentURL: NSURL(string: "\(self.videoBaseURL)/" + videostreamNamePattern(sessionID!, playerID: userID!)))
        self._sessionID = sessionID!;
        self._playerID = userID!;
        
        guard let playerView = rightRTMPPlayer.view else {
            return;
        }
        
        let newHeight = (rightPlayerSurfaceView.width / 4) * 3;
        rightPlaybackView.width = rightPlayerSurfaceView.width
        rightPlaybackView.height = newHeight
        
        if playerView.superview == nil {
            
            rightRTMPPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX;
            rightRTMPPlayer.videoDecoderMode = .Hardware;
            rightRTMPPlayer.setTimeout(5, readTimeout: 10);
            rightRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
            rightRTMPPlayer.shouldEnableVideoPostProcessing = true
            playerView.contentMode = .ScaleAspectFit;
            playerView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight];
            playerView.frame = rightPlayerSurfaceView.bounds;
            rightPlaybackView.addSubview(playerView);
            playerView.addSubview(rightActivityIndicator);
            rightActivityIndicator.center = CGPointMake(CGRectGetMidX(rightPlaybackView.bounds), CGRectGetMidY(rightPlaybackView.bounds));
            rightRTMPPlayer.prepareToPlay()
            //rightRTMPPlayer.play();
            setupRightPlayerReconnectTimer()
        }
    }
}

extension TwoPlayStreamerViewController: VCSessionDelegate {
    // MARK - VCSessionDelegate
    func connectionStatusChanged(sessionState: VCSessionState) {
        switch sessionState {
        case .None:
            break;
        case .PreviewStarted:
            break;
        case .Starting:
            break;
        case .Started:
            break;
        case .Ended:
            break;
        case .Error:
            if streamingSession != nil {
                streamingSession.endRtmpSession();
            }
            break;
        }
    }
}
