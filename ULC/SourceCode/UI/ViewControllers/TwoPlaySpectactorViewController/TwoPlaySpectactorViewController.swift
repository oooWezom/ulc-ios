//
//  TwoPlaySpectactorViewController.swift
//  ULC
//
//  Created by Alexey on 10/10/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReactiveCocoa
import KSYMediaPlayer

class TwoPlaySpectactorViewController: GeneralTwoPlayViewController, RateCircleViewDelegate {
    
    var gameEntity: GameSessionsEntity?
    var rateViewController: RateCircleViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.wsSessionViewModel?.resume()
        viewModel.initUnitySpectator(gameEntity!)
        
        if let _view = UnityGetGLView() where _view.hidden {
            _view.hidden = false
        }

		if gameEntity?.game == GameID.SPIN_THE_DISKS.rawValue {
			isGameSupported = true
		} else {
			isGameSupported = false
		}

		state = isGameSupported ? .spectator : .not_supported
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        viewModel.wsSessionViewModel?.pause()
        if let _ = rateViewController {
            removeRate()
        }
        viewModel.cleanUpUnityState()
    }
    
    deinit {
        unityView.removeFromSuperview()
        unityView = nil
        Swift.debugPrint("deinit called")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoBaseURL = gameEntity?.videoUrl {
            self.videoBaseURL = videoBaseURL
        }
        

        winner = .none
        configureViews()
        configureCommonViews()
        
        configureCommonSignals()
        configureSignals()
        self.isPresented = .allOrientations;
        
        leftPlayerID = gameEntity!.players.first!.id
        rightPlayerID = gameEntity!.players.last!.id
        
        leftPlayerInfoView.updateWithModel(gameEntity!.players.first!)
        rightPlayerInfoView.updateWithModel(gameEntity!.players.last!)
        
        //configurePlayers()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            [weak self] in
            self?.configurePlayers()
        }
        
        resizeFont()
        
    }
    
    func centralizeIndicators() {
        self.leftActivityIndicator.center = CGPointMake(CGRectGetMidX(self.leftPlaybackView.bounds), CGRectGetMidY(self.leftPlaybackView.bounds));
        self.rightActivityIndicator.center = CGPointMake(CGRectGetMidX(self.rightPlaybackView.bounds), CGRectGetMidY(self.rightPlaybackView.bounds));
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({
            (ctx) in
            // Swift.debugPrint("WILL")
        }) {
            (ctx) in
            // Swift.debugPrint("DID")
            self.newUnityView.updateConstraints()
            self.resizeFont();
            self.leftPlayerInfoView.setNeedsUpdateConstraints()
            self.rightPlayerInfoView.setNeedsUpdateConstraints()
            if UIApplication.sharedApplication().statusBarOrientation.isLandscape {
                self.view.y = 0
            } else {
                self.view.y = 20
            }
            
            self.centralizeIndicators()
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        changeViewVisibility(orientation);
        var newHeight = (self.view.frame.size.width * 0.5) * 0.75
        centralizeIndicators()
        
        if let state = state {
            
            switch state {

			case .not_supported:
				newUnityView.gameNotSupportedMode()
				break
                
            case .spectator:
                
                leftPlaybackView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.bottom.equalTo(leftPlayerSurfaceView)
                }
                
                rightPlaybackView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.bottom.equalTo(rightPlayerSurfaceView)
                }
                
                break;
                
            case .wish:
                newHeight = (self.view.frame.size.width * 0.66) * 0.75
                newUnityView.wishMode()
                if winner == .first {
                    leftPlaybackView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.34)
                        make.height.equalTo(newHeight * 0.5)
                    }
                    
                    leftPlaybackView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                } else {
                    wishView.hidden = false
                    wishView.descriptionLabel.text = ""
                    
                    leftPlaybackView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.66)
                        make.height.equalTo(newHeight)
                    }
                    
                    leftPlaybackView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                }
                
                break;
                
            case .done:
                newUnityView.doneMode()
                remakeCommonConstraints(newHeight, orientation: orientation)
                
                leftPlaybackView.snp_remakeConstraints {
                    (make) -> Void in
                    make.top.left.right.bottom.equalTo(leftPlayerSurfaceView)
                }
                
                break;
                
            case .finish:
                
                
                if leftRTMPPlayer != nil && rightRTMPPlayer != nil{
                    leftRTMPPlayer.view.frame  = leftPlayerSurfaceView.bounds;
                    rightRTMPPlayer.view.frame  = rightPlayerSurfaceView.bounds;
                }
                
                remakeCommonConstraints(newHeight, orientation: orientation)
                newUnityView.finishMode()
                break;
                
            default:
                break;
                
            }
        }
    }
    
    func configureViews() {
        newUnityView.spectatorMode()
        view.addSubview(leftPlaybackView)
        view.addSubview(rightPlaybackView)
        
        leftPlaybackView.backgroundColor = .blackColor()
        rightPlaybackView.backgroundColor = .blackColor()
        
        bottomView.gradientView.initBlackGradient([0.0, 1.0])
    //    bottomView.leaveLabel.textColor = UIColor.whiteColor()
    //    bottomView.nextLabel.textColor = UIColor.whiteColor()
        
        if let leave = R.image.game_leave() {
            bottomView.leaveImageView.image = leave
        }
        
        if let next = R.image.game_next() {
            bottomView.nextImageView.image = next
        }
        
        leftLikesButton.addTarget(self, action: #selector(leftLikeAction), forControlEvents: .TouchUpInside)
        rightLikesButton.addTarget(self, action: #selector(rightLikeAction), forControlEvents: .TouchUpInside)
        
        leftPlayerInfoView.optionButton.addTarget(self, action: #selector(hideLeftOptionsAction), forControlEvents: .TouchUpInside)
        rightPlayerInfoView.optionButton.addTarget(self, action: #selector(hideRightOptionsAction), forControlEvents: .TouchUpInside)
        //rightPlayerInfoView.prefferButton.addTarget(self, action: #selector(prefferAction), forControlEvents: .TouchUpInside)
        rightPlayerInfoView.followButton.addTarget(self, action: #selector(followAction), forControlEvents: .TouchUpInside)
        rightPlayerInfoView.reportButton.addTarget(self, action: #selector(reportAction), forControlEvents: .TouchUpInside)
        bottomView.leaveButton.addTarget(self, action: #selector(spectatorLeaveAction), forControlEvents: .TouchUpInside)
        bottomView.nextButton.addTarget(self, action: #selector(nextAction), forControlEvents: .TouchUpInside)
        messageView.sendMessageButton.addTarget(self, action: #selector(sendMessageAction), forControlEvents: .TouchUpInside)
    }
    
    func spectatorLeaveAction() {
		leaveActionSpectator()
        //leaveAction(R.string.localizable.leave_session(), description: R.string.localizable.leave_session_quastion())
    }
    
    func configurePlayers() {
        
        if let _ = gameEntity?.players.first {
            let url = NSURL(string: "\(self.videoBaseURL)/" + videostreamNamePattern((gameEntity?.id)!, playerID: leftPlayerID))
            leftRTMPPlayer = KSYMoviePlayerController(contentURL: url)
            
            guard let playerView = leftRTMPPlayer.view else {
                return;
            }
            
            let newHeight = (leftPlayerSurfaceView.width / 4) * 3;
            leftPlaybackView.width = leftPlayerSurfaceView.width
            leftPlaybackView.height = newHeight
            
            if playerView.superview == nil {
                
                playerView.contentMode = .ScaleAspectFit;
                playerView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight];
                playerView.frame = leftPlayerSurfaceView.bounds;
                leftRTMPPlayer.shouldEnableVideoPostProcessing = true
                leftRTMPPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX;
                leftRTMPPlayer.videoDecoderMode = .Hardware;
                leftRTMPPlayer.setTimeout(5, readTimeout: 10);
                leftRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
                playerView.frame = leftPlaybackView.bounds;
                leftPlaybackView.addSubview(playerView);
                playerView.addSubview(leftActivityIndicator);
                leftActivityIndicator.center = CGPointMake(CGRectGetMidX(leftPlaybackView.bounds), CGRectGetMidY(leftPlaybackView.bounds));
                leftRTMPPlayer.prepareToPlay()
                setupLeftPlayerReconnectTimer()
            }
        }
        
        if let _ = gameEntity?.players.last {
            
            rightRTMPPlayer = KSYMoviePlayerController(contentURL: NSURL(string: "\(self.videoBaseURL)/" + videostreamNamePattern((gameEntity?.id)!, playerID: rightPlayerID)))
            
            guard let playerView = rightRTMPPlayer.view else {
                return;
            }
            
            let newHeight = (rightPlayerSurfaceView.width / 4) * 3;
            rightPlaybackView.width = rightPlayerSurfaceView.width
            rightPlaybackView.height = newHeight
            
            if playerView.superview == nil {
                
                playerView.contentMode = .ScaleAspectFit;
                playerView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight];
                playerView.frame = rightPlayerSurfaceView.bounds;
                rightRTMPPlayer.shouldEnableVideoPostProcessing = true 
                rightRTMPPlayer.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX;
                rightRTMPPlayer.videoDecoderMode = .Hardware;
                rightRTMPPlayer.setTimeout(5, readTimeout: 10);
                rightRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
                playerView.frame = rightPlaybackView.bounds
                rightPlaybackView.addSubview(playerView);
                playerView.addSubview(rightActivityIndicator);
                rightActivityIndicator.center = CGPointMake(CGRectGetMidX(rightPlaybackView.bounds), CGRectGetMidY(rightPlaybackView.bounds));
                rightRTMPPlayer.prepareToPlay()
                setupRightPlayerReconnectTimer()
            }
        }
    }
    
    func finish() {
        state = isGameSupported ? .finish : .not_supported
        timer?.invalidate()
        newUnityView.finishMode()
        unityView.hidden = true
        updateViewConstraints()
    }
    
    func beginExecution() {
        newUnityView.wishMode()
        unityView.hidden = true
        state = isGameSupported ? .wish : .not_supported
        updateViewConstraints()
        leftPlayerInfoView.hidden = true
        rightPlayerInfoView.hidden = true
        
        if bottomView.leaveButton.hidden {
            bottomView.leaveButton.hidden = false;
        }
    }
    
    func nextAction() {
        viewModel.lookingGameToWatch(7, except: (gameEntity?.id)!)
    }
    
    func prefferAction() {
		if viewTypeController == .Anonymous {
			self.presentViewController(signAlertViewController, animated: true, completion: nil);
		}
    }

    func followAction() {
		if viewTypeController == .Anonymous {
			self.presentViewController(signAlertViewController, animated: true, completion: nil);
		}
    }

    func reportAction() {
		if viewTypeController == .Anonymous {
			self.presentViewController(signAlertViewController, animated: true, completion: nil);
		}
    }

    func gameResultState(model:AnyObject){
        guard let entity = model as? WSGameResult else {return;}
        
        if self.state == .wish {
            self.exitWishMode()
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.finish), userInfo: nil, repeats: false)
        
        entity.sessionState?.playersStats.forEach {
            it in
            
            if it.id == self.leftPlayerID {
                self.addCurrentPlayerXp(it.exp)
            } else {
                self.addOpponentPlayerXp(it.exp)
            }
        }
    }
    
    func playerForceDisconnectedState(model:AnyObject) {
        
        guard let entity = model as? WSPlayerDisconnectedEntity else {
            return;
        }
        
        if self.spectatorsCount > 0 {
            handleSpectatorsCount(self.spectatorsCount - 1)
        }
        
        if let user = entity.user {
            
            if user.id == leftPlayerID {
                lastLeftPlayerPlaybackTime = leftRTMPPlayer.currentPlaybackTime
            }else {
                self.lastPlaybackTime = rightRTMPPlayer.currentPlaybackTime
            }
            
            if user.closed_session {
                self.bottomView.hidden = false
                
                self.wishView.damageConstraints()
                newUnityView.finishMode()
                unityView.hidden = true
                state = isGameSupported ? .finish : .not_supported
                leftPlayerInfoView.hidden = false
                rightPlayerInfoView.hidden = false
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    [weak self] in
                    self?.centralizeIndicators()
                }
                self.updateViewConstraints()
                
                //pause left player
                if leftPlayerID == user.id {
                    streamerLeftAlert();
                } else {
                    if rightRTMPPlayer != nil {
                        rightRTMPPlayer.pause();
                    }
                }
                
            } else {
                
            }
        }
    }
    
    func exitWishMode() {
        state = isGameSupported ? .spectator : .not_supported
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
    
    func configureSignals() {
        
        viewModel.playerDisconnectedSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.playerForceDisconnectedState(message)
        }
        
        self.viewModel
            .gameFinalResultSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.gameResultState(message)
        }
        
        viewModel.gameRoundResultSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.newUnityView.hidden = false
                self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
                self?.newUnityView.rightPlayerButton.setBackgroundColor(UIColor(named: .UnityButtonNormalColor), forState: UIControlState.Disabled, cornerRadius: 2)
                
                if message.final {
                    if message.winner_id == self?.leftPlayerID {
                        self?.winner = .first
                    } else {
                        self?.winner = .second
                    }
                }
        }
        
        viewModel.gameRoundStartSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    //self?.newUnityView.hidden = true
					self?.newUnityView.hidden = self!.isGameSupported ? true : false
                }
        }
        
        viewModel.gameStateSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                
                if message.data?.playersData.first?.ready == true {
                    self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
                
                if message.data?.playersData.last?.ready == true {
                    self?.newUnityView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
                
                if message.data?.playersData.first?.ready == true && message.data?.playersData.last?.ready == true {
                    //self?.newUnityView.hidden = true
					 self?.newUnityView.hidden = self!.isGameSupported ? true : false
                }
        }
        
        viewModel.playerReadySignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                if message.id == self?.leftPlayerID {
                    self?.newUnityView.leftPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                } else {
                    self?.newUnityView.rightPlayerButton.setBackgroundColor(UIColor.orangeColor(), forState: UIControlState.Disabled, cornerRadius: 2)
                }
        }
        
        viewModel.gameWinnerResultSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                self?.handleRoundIndicators(message)
        }
        
        viewModel.sessionStateSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                guard let message = observer.value, let strongSelf = self else {
                    return
                }
                
                if let state = message.sessionState {
                    self?.handleSpectatorsCount(state.spectators)
                }
                
                switch message.type {
                case SessionEvents.SESSION_STATE.rawValue:
                    
                    if let spectators = message.sessionState?.spectators{
                        self?.handleSpectatorsCount(spectators)
                    }
                    
                    if let state = message.sessionState?.state{
                        switch state {
                        case 1:
                            
                            break;
                        case 2:
                            if let looserId = message.sessionState?.loserID{
                                if looserId == strongSelf.leftPlayerID {
                                    strongSelf.winner = .second
                                } else {
                                    strongSelf.winner = .first
                                }
                            }
                            strongSelf.beginExecution()
                            break;
                        case 3:
                            self?.newUnityView.doneMode()
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
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.35 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) { _ in
                        strongSelf.looserDoneHisPerfomance()
                    }
                    break
                default:
                    break
                }
        }
    }
    
    func looserDoneHisPerfomance() {
        //self.state = .done
		state = isGameSupported ? .done : .not_supported
        wishView.damageConstraints()
        
        wishView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.width.height.equalTo(0)
        }

		if state == .done {
			newUnityView.doneMode()
			rateFirstPlayer()
		} else if state == .not_supported {
			newUnityView.gameNotSupportedMode()
		}

		view.endEditing(true)
		leftPlayerInfoView.hidden    = false
		rightPlayerInfoView.hidden   = false



        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            [weak self] in
            self?.centralizeIndicators()
        }
        updateViewConstraints()
    }
    
    func showCircleView() {
        if let rateViewController = R.storyboard.main.rateCircleViewController() {
            self.rateViewController = rateViewController
            self.rateViewController!.delegate = self
        }
        
        addChildViewController(rateViewController!)
        self.view.addSubview(rateViewController!.view)
        didMoveToParentViewController(rateViewController)
        rateViewController?.start()
    }
    
    func removeRate() {
        rateViewController?.willMoveToParentViewController(nil)
        rateViewController?.view.removeFromSuperview()
        rateViewController?.removeFromParentViewController()
        rateViewController?.stop()
        rateViewController = nil;
    }
    
    func rateFirstPlayer() {
        showCircleView()
        if let player = gameEntity?.players.first {
            if let rateViewController = rateViewController {
                rateViewController.updateWithModel(player, player: .LEFT_PLAYER)
            }
        }
    }
    
    func rateSecondPlayer() {
        showCircleView()
        if let player = gameEntity?.players.last {
            if let rateViewController = rateViewController {
                rateViewController.updateWithModel(player, player: .RIGHT_PLAYER)
            }
        }
    }
    
    //MARK RateCircleViewDelegate
    func rateTimeIsOver(player: Players) {
        removeRate()
        if player == .LEFT_PLAYER {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.rateSecondPlayer()
            }
        }
    }
    
    //MARK RateCircleViewDelegate
    func like(player: Players) {
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            removeRate()
            if player == .LEFT_PLAYER {
                viewModel.plusVote(leftPlayerID)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.rateSecondPlayer()
                }
            } else {
                viewModel.plusVote(rightPlayerID)
            }
        }
    }
    
    //MARK RateCircleViewDelegate
    func dislike(player: Players) {
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            removeRate()
            if player == .LEFT_PLAYER {
                viewModel.minusVote(leftPlayerID)
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    [weak self] in
                    self?.rateSecondPlayer()
                }
            } else {
                viewModel.minusVote(rightPlayerID)
            }
        }
    }
}

