//
//  SpectatorTalkSessionViewController.swift
//  ULC
//
//  Created by Vitya on 9/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import RealmSwift
import ReactiveCocoa
import MBProgressHUD
import SnapKit
import KSYMediaPlayer

enum DisconnectPlayer {
    case Left
    case Right
    case All
}

class SpectatorTalkSessionViewController: GeneralStreamViewController {
    
    let spectatorTalkSessionViewModel = SpectatorTalkSessionViewModel()
    let wsProfileViewModel = WSProfileViewModel()
    
    // MARK:- private properties
    private let askedQuasionAlertView   = AskedQuastionAlertView()
    private var leftTimer:NSTimer?
    private var rightTimer:NSTimer?
    private var leftLikesBuffer         = 0
    private var rightLikesBuffer        = 0
    
    var burstTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userType = .Spectator;
        configureInterfaceIcons();
        setupSignals();
        
        bottomView.leftHeartView.likeButton.addTarget(self, action: #selector(likeStream), forControlEvents: .TouchUpInside);
        bottomView.rightHeartView.likeButton.addTarget(self, action: #selector(likeStream), forControlEvents: .TouchUpInside);
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.view.setNeedsUpdateConstraints();
        }
        addNotificationsObserver();
    }
    
    private func addNotificationsObserver() {
        weak var weakSelf = self;
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_)  in
                weakSelf?.resumePlayers();
        }
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                weakSelf?.pausePlayers();
        }
    }
    
    func sendLeftUserLikes() {
        wsTalkViewModel.sendTalkLikes(leftLikesBuffer)
        leftLikesBuffer = 0
        leftTimer?.invalidate()
        leftTimer = nil;
    }
    
    func sendRightUserLikes() {
        if let linked = wsSessionInfo.linked?.first {
            wsTalkViewModel.sendTalkOppinentLikes(linked.id, likesCount: rightLikesBuffer);
            rightLikesBuffer = 0
            rightTimer?.invalidate()
            rightTimer = nil;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        chatView.spectatorsCount.text = wsSessionInfo.spectators.roundValueAsString()
        wsProfileViewModel.resume()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        canTryReconnectRightPlayer  = false
        canTryReconnectLeftPlayer   = false
        stopPlayers(.All);
        wsProfileViewModel.pause()
    }
    
    override func configureGestureRecognizers() {
        super.configureGestureRecognizers()
        
        let reportLeftUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(showLeftUserReportAlertMessage))
        firstSreamerAvatarView.reportPlaceholderView.addGestureRecognizer(reportLeftUserTapGesture)
        
        let randomIconTapGesture = UITapGestureRecognizer(target: self, action: #selector(showAskedAlertMessage))
        bottomView.askView.userInteractionEnabled = true
        bottomView.askView.addGestureRecognizer(randomIconTapGesture)
        
        let nextSessionTapGesture = UITapGestureRecognizer(target: self, action: #selector(nextSession))
        bottomView.nextView.addGestureRecognizer(nextSessionTapGesture)
        
        let prefferLeftUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(prefferUser))
        firstSreamerAvatarView.prefferPlaceholderView.addGestureRecognizer(prefferLeftUserTapGesture)
        
        let prefferRightUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(prefferUser))
        secondSreamerAvatarView.prefferPlaceholderView.addGestureRecognizer(prefferRightUserTapGesture)
    }
    
    func showLeftUserReportAlertMessage(sender: UITapGestureRecognizer) {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            if preferedStreamer == .LeftStreamer {
                reportUserBehaviorAlertView.showAlertMessage(wsTalkViewModel, userId: wsSessionInfo.id )
            } else {
                if let userId = wsSessionInfo.linked?.first?.id {
                    reportUserBehaviorAlertView.showAlertMessage(wsTalkViewModel, userId: userId)
                }
            }
        }
    }
    
    override func showRightUserReportAlertMessage() {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            super.showRightUserReportAlertMessage()
            if preferedStreamer == .RightStreamer {
                reportUserBehaviorAlertView.showAlertMessage(wsTalkViewModel, userId: wsSessionInfo.id )
            } else {
                if let userId = wsSessionInfo.linked?.first?.id {
                    reportUserBehaviorAlertView.showAlertMessage(wsTalkViewModel, userId: userId)
                }
            }
        }
    }
    
    private func configureLeftPlayer() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            self?.leftActivityIndicator.startAnimating();
            if let streamer = strongSelf.wsSessionInfo.streamer {
                strongSelf.firstSreamerAvatarView.updateViewWithModel(streamer);
            }
            let url = NSURL(string: "\(strongSelf.videoBaseURL)/t_\(strongSelf.wsSessionInfo.id)")!;
            strongSelf.leftRTMPPlayer = KSYMoviePlayerController(contentURL: url)
            strongSelf.configurePlayers(strongSelf.leftRTMPPlayer)
        }
    }
    
    private func configureRightPlayer() {
        
        guard  let linked = wsSessionInfo.linked,
            let first = linked.first,
            let streamer = first.streamer else {
                return;
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            self?.rightActivityIndicator.startAnimating();
            let url = NSURL(string: "\(strongSelf.videoBaseURL)/t_\(first.id)");
            strongSelf.rightRTMPPlayer = KSYMoviePlayerController(contentURL: url)
            strongSelf.configurePlayers(strongSelf.rightRTMPPlayer);
            strongSelf.secondSreamerAvatarView.updateViewWithModel(streamer, isExistSecondStreamer: false);
        }
    }
    
    private func configurePlayers(player: KSYMoviePlayerController) {
        
        guard let playerView = player.view else {
            return;
        }
        
        if playerView.superview == nil {
            
            playerView.contentMode = .ScaleAspectFit;
            playerView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight];
            
            player.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX;
            player.videoDecoderMode = .Hardware;
            player.shouldEnableVideoPostProcessing = true ////
            player.setTimeout(Constants.PLAYER_PREPARE_TIMEOUT, readTimeout: Constants.PLAYER_READ_TIMEOUT);
            player.setVolume(Constants.PLAYER_LEFT_VOLUME, rigthVolume: Constants.PLAYER_RIGHT_VOLUME);
            
            if streamTypeView == StreamTypeView.TwoStreamer {
                //configure 2 players
                if player == leftRTMPPlayer {
                    playerView.frame = ownerVideoPreview.bounds;
                    ownerVideoPreview.addSubview(playerView);
                    playerView.addSubview(leftActivityIndicator);
                    player.prepareToPlay()
                    //player.play();
                    canTryReconnectLeftPlayer = true
                    setupLeftPlayerReconnectTimer()
                } else {
                    playerView.frame = guestVideoPreview.bounds;
                    guestVideoPreview.addSubview(playerView);
                    playerView.addSubview(rightActivityIndicator);
                    player.prepareToPlay()
                    //player.play();
                    canTryReconnectRightPlayer = true
                    setupRightPlayerReconnectTimer()
                }
            } else {
                //configure 1 player
                playerView.frame = ownerVideoPreview.bounds;
                ownerVideoPreview.addSubview(playerView);
                playerView.addSubview(leftActivityIndicator);
                leftActivityIndicator.center = CGPointMake(CGRectGetMidX(playerView.bounds), CGRectGetMidY(playerView.bounds));
                player.prepareToPlay()
                // player.play();
                canTryReconnectLeftPlayer = true
                setupLeftPlayerReconnectTimer()
            }
            view.setNeedsUpdateConstraints();
        }
    }
    
    override func configureInterfaceIcons() {
        super.configureInterfaceIcons()
        bottomView.allowRenamingSession(false, allowEditImage: false)
        setStreamerAsPreferred( .LeftStreamer)
    }
    
    func sendDonateMessage() {
        wsTalkViewModel.sendDonateMessage(askedQuasionAlertView.messageTextView.text)
        askedQuasionAlertView.messageTextView.text = ""
        askedQuasionAlertView.close()
    }
    
    func showAskedAlertMessage() {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            askedQuasionAlertView.showAlertMessage()
            askedQuasionAlertView.sendButton.addTarget(self, action: #selector(sendDonateMessage), forControlEvents: .TouchUpInside)
        }
    }
    
    func nextSession() {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            wsTalkViewModel.findTalk(wsSessionInfo.category, except: wsSessionInfo.id)
            bottomView.startNextButtonProgress()
        }
    }
    
    func prefferUser(gesture: UITapGestureRecognizer) {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            if let talkId = wsSessionInfo.linked?.first?.id {
                wsTalkViewModel.swithTalk(talkId)
            }
        }
    }
    
    override func configureSignals() {
        super.configureSignals()
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        
        spectatorTalkSessionViewModel.getCurrentUserInfo()
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] (observer, disposable) -> () in
                
                observer.observeCompleted ({
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
                
                observer.observeFailed ({ (let error) in
                    Swift.debugPrint(error)
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
        }
    }
    
    override func sendButtonTouch() {
        super.sendButtonTouch()
        //MARK:- add self message into array
        if let currentUserInfo = spectatorTalkSessionViewModel.getSelfUser() {
            let messageEntity  = WSTalkChatMessageEntity.createWSTalkChatEntity(messageView.messageTextView.text, sender: currentUserInfo)
            self.chatView.addNewMessage(messageEntity)
        }
        messageView.messageTextView.text = ""
        messageView.sendMessageButton.enabled = false
    }
    
    final func likeStream(sender: UIButton) {
        
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            if sender == bottomView.leftHeartView.likeButton {
                bottomView.showLeftHeartAnimation()
                bottomView.addLeftLikes(1)
            } else {
                bottomView.showRightHeartAnimation()
                bottomView.addRightLikes(1)
            }
            
            if preferedStreamer == .LeftStreamer && sender == bottomView.leftHeartView.likeButton ||
                preferedStreamer == .RightStreamer && sender == bottomView.rightHeartView.likeButton  {
                leftLikesBuffer += 1
                if leftTimer == nil {
                    leftTimer = NSTimer.scheduledTimerWithTimeInterval(2,
                                                                       target: self,
                                                                       selector: #selector(sendLeftUserLikes),
                                                                       userInfo: nil,
                                                                       repeats: false)
                }
            } else {
                rightLikesBuffer += 1
                if  rightTimer == nil {
                    rightTimer = NSTimer.scheduledTimerWithTimeInterval(2,
                                                                        target: self,
                                                                        selector: #selector(sendRightUserLikes),
                                                                        userInfo: nil,
                                                                        repeats: false)
                }
            }
        }
    }
    
    deinit {
        if signAlertViewController != nil {
            signAlertViewController.view.removeFromSuperview();
        }
    }
}

//MARK - Observe Signals
extension SpectatorTalkSessionViewController {
    
    private func setupSignals() {
        
        wsProfileViewModel.inviteToTalkRequestHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                
                debugPrint("some new message")
                if let message = observer.value {
                    self.customAlertMessageController.showUserInviteAlertMessage(message, wsProfileViewModel: self.wsProfileViewModel, wsTalkViewModel: nil)
                }
        }
        
        wsProfileViewModel.createTalkResultHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [unowned self] observer in
                
                if let message = observer.value?.talk {
                    self.wsTalkViewModel.leaveTalk()
                    self.openStreamerViewController(message)
                }
        }
        
        wsTalkViewModel.inviteToTalkRequestHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                debugPrint("invite message in TalkViewModel")
        }
        
        wsTalkViewModel.talkLikesHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let session = observer.value, let strongSelf = self else {
                    return;
                }
                
                if strongSelf.preferedStreamer == .LeftStreamer {
                    if session.talk == strongSelf.wsSessionInfo.id {
                        strongSelf.bottomView.addLeftLikes(session.likes)
                        strongSelf.bottomView.showLeftHeartAnimation()
                    } else {
                        strongSelf.bottomView.addRightLikes(session.likes)
                        strongSelf.bottomView.showRightHeartAnimation()
                    }
                } else {
                    if session.talk == strongSelf.wsSessionInfo.id {
                        strongSelf.bottomView.addRightLikes(session.likes)
                        strongSelf.bottomView.showRightHeartAnimation()
                    } else {
                        strongSelf.bottomView.addLeftLikes(session.likes)
                        strongSelf.bottomView.showLeftHeartAnimation()
                    }
                }
        }
        
        wsTalkViewModel.talkStateHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value, let strongSelf =  self else {
                    return
                }
                
                strongSelf.bottomView.stopNextButtonProgress()
                
                if strongSelf.switchStreamerFlag {
                    strongSelf.switchStreamerFlag = false
                    return
                }
                
                if let _ = message.talk.linked?.first {
                    //2 streamer was connected
                    strongSelf.streamTypeView = .TwoStreamer;
                    strongSelf.configureLeftPlayer();
                    strongSelf.configureRightPlayer();
                    strongSelf.secondSreamerAvatarView.hidden = false;
                    //strongSelf.rightActivityIndicator.stopAnimating()
                } else {
                    //1 streamer is connected
                    strongSelf.streamTypeView = .LeftStreamer;
                    strongSelf.configureLeftPlayer();
                    //strongSelf.rightActivityIndicator.stopAnimating()
                    
                    // two spectators
                    if strongSelf.rightRTMPPlayer != nil {
                        strongSelf.rightRTMPPlayer.stop()
                    }
                }
        }
        
        wsTalkViewModel.switchTalkHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value, let strongSelf = self else {
                    return
                }
                //MARK:- switch between streamers only when message id equivalent to own spectator id
                if message.user == strongSelf.spectatorTalkSessionViewModel.currentId {
                    strongSelf.switchStreamerFlag = true
                    //  strongSelf.bottomView.quaseonLabel.text = ""
                    
                    if strongSelf.preferedStreamer == .LeftStreamer {
                        strongSelf.setStreamerAsPreferred(.RightStreamer)
                    } else {
                        strongSelf.setStreamerAsPreferred(.LeftStreamer)
                    }
                    // reinitiate new wsTalkViewModel
                    strongSelf.reinitWSTalkViewModel(message.to).getTalkState()
                }
        }
        
        //if our streamer connected
        wsTalkViewModel.streamerConnectedHandler.signal.observeResult { observer in
            if let _ = observer.value {
                Swift.debugPrint("");
            }
        }
        //if our streamer reconnected
        wsTalkViewModel.streamerReconnectedHandler.signal.observeResult { [weak self] observer in
            guard let streamer = observer.value,
                let strongSelf = self,
                let currentStreamer = strongSelf.wsSessionInfo.streamer else {
                    return;
            }
            
            if currentStreamer.id == streamer.user {
                if strongSelf.leftRTMPPlayer != nil {
                    strongSelf.lastLeftPlayerPlaybackTime = strongSelf.leftRTMPPlayer.currentPlaybackTime
                    //strongSelf.leftRTMPPlayer.play();
                }
            } else {
                if strongSelf.rightRTMPPlayer != nil {
                    strongSelf.lastRightPlayerPlaybackTime = strongSelf.rightRTMPPlayer.currentPlaybackTime
                    //strongSelf.rightRTMPPlayer.pause();
                }
            }
        }
        
        //if our streamer disconnected
        wsTalkViewModel.streamerDisconnectedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let streamer = observer.value, let currentStreamer = self?.wsSessionInfo.streamer else {
                    return;
                }
                if currentStreamer.id == streamer.user {
                    //self?.streamerLeftAlert();
                } else {
                    if self?.rightRTMPPlayer != nil {
                        self?.rightRTMPPlayer.pause();
                    }
                }
        }
        
        wsTalkViewModel.talkAddedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                
                guard let model = observer.value, let strongSelf = self else {
                    return;
                }
                debugPrint(model.talk.toJSON())
                debugPrint(self?.spectatorTalkSessionViewModel.currentId)
                
                if model.talk.streamer?.id == strongSelf.spectatorTalkSessionViewModel.currentId {
                    return
                }
                
                //strongSelf.leftActivityIndicator.hidden = strongSelf.leftRTMPPlayer.isPlaying()
                if  let linked = model.talk.linked, let _ = linked.first, let streamer = model.talk.streamer {
                    //2 streamer was connected
                    strongSelf.streamTypeView = .TwoStreamer;
                    strongSelf.secondSreamerAvatarView.hidden = false;
                    strongSelf.rightActivityIndicator.startAnimating()
                    strongSelf.attachStreamer(model.talk.id);
                    strongSelf.wsSessionInfo.addNewLinkedEntity(model.talk)
                    strongSelf.secondSreamerAvatarView.updateViewWithModel(streamer, isExistSecondStreamer: false);
                    //update likes when second user connected
                    //strongSelf.bottomView.setLeftLikes(strongSelf.wsSessionInfo.likes)
                    //strongSelf.bottomView.setRightLikes(strongSelf.wsSessionInfo.linked?.first?.likes)
                    
                    //FIX
                    strongSelf.bottomView.setLeftLikes(linked.first?.likes);
                    strongSelf.bottomView.setRightLikes(model.talk.likes);
                    
                } else {
                    Swift.debugPrint("-----");
                }
                strongSelf.configureInterfaceIcons()
                strongSelf.interfaceShowing()
        }
        
        //handle close current talk
        wsTalkViewModel.talkClosedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let model = observer.value else {
                    return;
                }
                //check if only one streamer
                if self?.streamTypeView != StreamTypeView.TwoStreamer {
                    //check current session status
                    if self?.wsSessionInfo == nil {
                        return;
                    }
                    //check if prefer-user has leaved session
                    if self?.wsSessionInfo.streamer?.id == model.talk.streamer?.id {
                        self?.showFinishAlert(R.string.localizable.streamer_has_just_leaved_session());
                    }
                } else {
                    self?.removeAnotherStreamer(model.talk.id)
                }
        }
        
        wsTalkViewModel.findTalkHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let talk = observer.value?.talk else {
                    self?.showAlertMessage("", message: R.string.localizable.there_are_no_active_session(), completitionHandler: nil);
                    self?.bottomView.stopNextButtonProgress()
                    return
                }
                
                //MARK:- if it is own talk then return
                if talk.streamer?.id == self?.spectatorTalkSessionViewModel.currentId
                    || talk.linked?.first?.streamer?.id == self?.spectatorTalkSessionViewModel.currentId {
                    self?.bottomView.stopNextButtonProgress()
                    return
                }
                
                if self?.leftLikesBuffer > 0 {
                    self?.sendLeftUserLikes();
                }
                
                if self?.rightLikesBuffer > 0 {
                    self?.sendRightUserLikes();
                }
                
                self?.canTryReconnectLeftPlayer   = false
                self?.canTryReconnectRightPlayer  = false
                
                if let leftTimer = self?.leftTimer where leftTimer.valid {
                    self?.leftLikesBuffer = 0
                    self?.leftTimer?.invalidate()
                    self?.leftTimer = nil;
                }
                
                if let rightTimer = self?.rightTimer where rightTimer.valid {
                    self?.rightLikesBuffer = 0
                    self?.rightTimer?.invalidate()
                    self?.rightTimer = nil;
                }
                
                self?.chatView.refreshChatView()
                // self?.bottomView.quaseonLabel.text = ""
                
                self?.stopPlayers(.All);
                
                // reinitiate new wsTalkViewModel
                self?.reinitWSTalkViewModel(talk.id)
                
                // reinitiate current session info
                self?.wsSessionInfo = talk
                
                //preffer left user
                self?.setStreamerAsPreferred(.LeftStreamer)
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    self?.view.setNeedsUpdateConstraints();
                }
        }
        
        //handle talk removed
        wsTalkViewModel.talkRemovedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let model = observer.value else {
                    return;
                }
                //check if only one streamer
                if self?.streamTypeView == .TwoStreamer {
                    self?.removeAnotherStreamer(model.talk.id)
                }
        }
    }
    
    private func removeAnotherStreamer(streamerId: Int) {
        
        //if two spectators are streaming
        if self.wsSessionInfo.id == streamerId {
            //first/left has leaved, we have to close session
            self.leaveCurrentSession();
        } else {
            //right has just leaved session
            self.disconnectPlayer(.Right);
            
            self.configureLeftPlayer();
            
            if self.preferedStreamer == .RightStreamer {
                self.wsSessionInfo.likes = self.bottomView.rightLikes
                self.wsSessionInfo.linked?.first?.likes = 0
                self.bottomView.reverLikes()
            }
            //preffer left user
            self.setStreamerAsPreferred(.LeftStreamer)
        }
    }
    
    private func reinitWSTalkViewModel(sessionId: Int) -> WSTalkViewModel {
        wsTalkViewModel.destroyPingTimer();
        wsTalkViewModel = nil;
        wsTalkViewModel = WSTalkViewModel(sessionId: sessionId)
        configureSignals()
        setupSignals()
        wsTalkViewModel.runPingTimer();
        return wsTalkViewModel
    }
    
    private func disconnectPlayer(player: DisconnectPlayer) {
        if player == .Right {
            canTryReconnectRightPlayer = false
            stopRightPlayer();
            streamTypeView = .LeftStreamer;
        } else if player == .Left {
            canTryReconnectLeftPlayer = false
            stopLeftPlayer();
            streamTypeView = .RightStreamer;
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.view.setNeedsUpdateConstraints();
        }
    }
    
    private func leaveCurrentSession() {
        canTryReconnectRightPlayer = false
        canTryReconnectLeftPlayer = false
        stopPlayers(.All);
        self.streamTypeView = StreamTypeView.RightStreamer;
        
        self.showFinishAlert(R.string.localizable.streamer_has_just_leaved_session());
    }
    
    private func attachStreamer(sessionID: Int) {
        canTryReconnectRightPlayer = false
        stopRightPlayer();
        let url = NSURL(string: "\(videoBaseURL)/t_\(sessionID)");
        rightRTMPPlayer = KSYMoviePlayerController(contentURL: url)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            if let strongSelf = self {
                strongSelf.configurePlayers(strongSelf.rightRTMPPlayer);
            }
        }
    }
    
    private func openStreamerViewController(message: TalkSessionsResponseEntity) {
        self.dismissViewControllerAnimated(false) { [unowned self] in
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.isPresentedVC)
            
            if let navigationVC = UIApplication.topNavigationViewController() as? ULCNavigationViewController,
                let spectatorVC = R.storyboard.main.talkContainerViewController() {
                
                self.wsTalkViewModel = nil
                spectatorVC.wsTalkSessionInfo = message
                navigationVC.presentedViewController?.presentViewController(spectatorVC, animated: true, completion: nil)
            }
        }
    }
}
