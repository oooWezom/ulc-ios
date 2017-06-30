//
//  OneStreamerTalkViewController.swift
//  ULC
//
//  Created by Vitya on 9/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import VideoCore
import AVKit
import ReactiveCocoa
import KSYMediaPlayer

class StreamerSessionViewController: GeneralStreamViewController {
    
    private let changeNameAlertView     = ChangeNameAlertView()
    private let addAnotherStreamerIcon  = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userType = .Streamer;
        configureInterfaceIcons();
        configureWSSignals();
        
        weak var weakSelf = self;
        NSNotificationCenter
            .defaultCenter()
            .rac_addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { (_) in
                if weakSelf?.leaveAlertController != nil {
                    weakSelf?.leaveAlertController.dismissViewControllerAnimated(true, completion: nil);
                }
                weakSelf?.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        stopSession();
    }
    
    override func sendButtonTouch() {
        super.sendButtonTouch()
        
        if let wsTalkSessionInfo = wsSessionInfo {
            let messageEntity = WSTalkChatMessageEntity.createWSTalkChatEntity(messageView.messageTextView.text, sender: wsTalkSessionInfo)
            self.chatView.addNewMessage(messageEntity)
        }
        
        messageView.messageTextView.text = ""
        messageView.sendMessageButton.enabled = false
    }
    
    override func configureGestureRecognizers() {
        super.configureGestureRecognizers()
        
        let changeTalkNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(changeTalkName))
        bottomView.sessionNameLabel.addGestureRecognizer(changeTalkNameTapGesture)
        
        let detachTalkUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(detachTalk))
        secondSreamerAvatarView.prefferPlaceholderView.addGestureRecognizer(detachTalkUserTapGesture)
        
        let addAnotherStreamerTapGesture = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        addAnotherStreamerIcon.userInteractionEnabled = true
        addAnotherStreamerIcon.addGestureRecognizer(addAnotherStreamerTapGesture)
    }
    
    override func interfaceShowing() {
        super.interfaceShowing()
        
        bottomView.allowRenamingSession(true, allowEditImage: !isInterfaceShowing)
        
        if streamTypeView == .LeftStreamer {
            addAnotherStreamerIcon.hidden = isInterfaceShowing
        }
    }
    
    override func showRightUserReportAlertMessage() {
        super.showRightUserReportAlertMessage()
        
        if let userId = wsSessionInfo.linked?.first?.id {
            reportUserBehaviorAlertView.showAlertMessage(wsTalkViewModel, userId: userId)
        }
    }
    
    private func configureRTMP() {

        //Need after for OpenGL init
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
            let videoCaptureSize = CGSizeMake(320, 240);
            self.streamingVideoSession = VCSimpleSession(videoSize: videoCaptureSize,
                                                         frameRate: 24, bitrate: 450000,
                                                         useInterfaceOrientation: true,
                                                         cameraState: VCCameraState.Front,
                                                         aspectMode: VCAspectMode.AscpectModeFill);
            self.streamingVideoSession.orientationLocked = false;
            self.streamingVideoSession.useAdaptiveBitrate = false;
            self.streamingVideoSession.delegate = self;
            self.ownerVideoPreview.addSubview(self.streamingVideoSession.previewView);
            self.streamingVideoSession.previewView.frame = self.ownerVideoPreview.bounds;
            
            if let viewModel = self.wsTalkViewModel {
                let key = "t_\(viewModel.sessionID)";
                self.streamingVideoSession.startRtmpSessionWithURL("\(self.videoBaseURL)/", andStreamKey: key)
            }
        }
    }
    
    private func configureWSSignals() {
        
        // MARK:- WS signals
        wsTalkViewModel.talkLikesHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let session = observer.value else { return; }
                if session.talk == self?.wsSessionInfo.id {
                    self?.bottomView.addLeftLikes(session.likes)
                    self?.bottomView.showLeftHeartAnimation()
                } else {
                    self?.bottomView.addRightLikes(session.likes)
                    self?.bottomView.showRightHeartAnimation()
                }
        }
        
        wsTalkViewModel.inviteToTalkHandler.signal
            .observeOn(UIScheduler())
            .observeResult  { [weak self] observer in
                guard let message = observer.value,
                    let result = WSInviteToTalkResult(rawValue: message.result) else { return }
                
                self?.view.endEditing(true)
                
                if result == .OK {
                    Swift.debugPrint(message)
                } else {
                    self?.customAlertMessageController.removeController()
                    self?.showAlertMessage("", message: R.string.localizable.user_not_ready(), completitionHandler: nil);
                }
        }
        
        wsTalkViewModel.talkStateHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let talk = observer.value?.talk else {
                    return
                }
                
                self?.configureRTMP();
                
                if let linked = talk.linked?.first, let streamer = linked.streamer {
                    //2 streamer was connected
                    self?.secondSreamerAvatarView.updateViewWithModel(streamer, isExistSecondStreamer: false);
                    self?.streamTypeView = .TwoStreamer
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                        self?.attachStreamer(linked.id);
                    }
                }
                if let streamer = self?.wsSessionInfo.streamer {
                    self?.firstSreamerAvatarView.updateViewWithModel(streamer);
                }
        }
        
        wsTalkViewModel.talkAddedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let model = observer.value else {
                    return;
                }
                
                if  let _ = model.talk.linked?.first,
                    let streamer = model.talk.streamer {
                    //2 streamer was connected
                    self?.wsSessionInfo.addNewLinkedEntity(model.talk)
                    self?.secondSreamerAvatarView.updateViewWithModel(streamer, isExistSecondStreamer: false);
                    self?.streamTypeView = .TwoStreamer
                    
                    self?.bottomView.setLeftLikes(model.talk.linked?.first?.likes)
                    self?.bottomView.setRightLikes(model.talk.likes)
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                        self?.attachStreamer(model.talk.id)
                    }
                }
                self?.configureInterfaceIcons()
        }
        /*
        wsTalkViewModel.streamerConnectedSignal
            .observeOn(UIScheduler())
            .observeResult { observer in
                Swift.debugPrint("streamer connected")
        } */
        
        //handle close of second talk
        wsTalkViewModel.talkClosedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                //right has just leaved session
                self?.disconnectPlayer(.Right);
        }
        
        //handle talk removed
        wsTalkViewModel.talkRemovedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                //right has just leaved session
                self?.disconnectPlayer(.Right);
        }
    }
    
    override func configureInterfaceIcons() {
        super.configureInterfaceIcons()
        
        addAnotherStreamerIcon.image = R.image.add_user_icon()
        view.addSubview(addAnotherStreamerIcon)
        
        firstSreamerAvatarView.setViewType( .Streamer)
        secondSreamerAvatarView.setViewType( .Streamer)
        
        bottomView.allowRenamingSession(true, allowEditImage: true)
        navigationController?.navigationBarHidden = true
        
        frostedViewController.panGestureEnabled = false
        
        firstSreamerAvatarView.switchCameraButton.addTarget(self, action: #selector(switchCamera), forControlEvents: .TouchUpInside);
    }
    
    func changeTalkName(sender: UITapGestureRecognizer) {
        changeNameAlertView.showAlertMessage()
        changeNameAlertView.setFocusOnTextView()
        
        changeNameAlertView.okButton.addTarget(self, action: #selector(sendNewTalkName), forControlEvents: .TouchUpInside)
    }
    
    func sendNewTalkName(sender: UIButton) {
        if let message = changeNameAlertView.messageTextField.text {
            wsTalkViewModel.updateTalkData(message)
            changeNameAlertView.hideAlertMessage()
        }
    }
    
    func detachTalk(sender: UITapGestureRecognizer) {
        wsTalkViewModel.detachTalk()
    }
    
    private func attachStreamer(sessionID: Int) {
        streamTypeView = .TwoStreamer
        secondSreamerAvatarView.hidden = false;
        rightActivityIndicator.startAnimating();
        canTryReconnectRightPlayer = false
        stopRightPlayer();
        
        let url = NSURL(string: "\(videoBaseURL)/t_\(sessionID)");
        rightRTMPPlayer = KSYMoviePlayerController(contentURL: url)
        configurePlayers(rightRTMPPlayer);
    }
    
    private func configurePlayers(player: KSYMoviePlayerController) {
        
        guard let playerView = player.view else {
            return;
        }
        
        if playerView.superview == nil {
            
            playerView.contentMode = .ScaleAspectFit;
            playerView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleHeight];
            
            if streamTypeView == .TwoStreamer {
                //configure 2 players
                playerView.frame = guestVideoPreview.bounds;
                guestVideoPreview.addSubview(playerView);
                playerView.addSubview(rightActivityIndicator);
                
                player.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX;
                player.videoDecoderMode = .Hardware;
                player.setTimeout(Constants.PLAYER_PREPARE_TIMEOUT, readTimeout: Constants.PLAYER_READ_TIMEOUT);
                player.setVolume(Constants.PLAYER_LEFT_VOLUME, rigthVolume: Constants.PLAYER_RIGHT_VOLUME);
                
                player.prepareToPlay()
                player.play();
                canTryReconnectRightPlayer = true
                setupRightPlayerReconnectTimer()
            }
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.view.setNeedsUpdateConstraints();
            }
        }
    }
    
    private func disconnectPlayer(player: DisconnectPlayer) {
        canTryReconnectRightPlayer = false
        stopRightPlayer();
        streamTypeView = .LeftStreamer;
        rightActivityIndicator.stopAnimating();
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.view.setNeedsUpdateConstraints();
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if streamTypeView == .LeftStreamer {
            addAnotherStreamerIcon.snp_remakeConstraints { make in
                make.width.height.equalTo(40)
                make.right.equalTo(videoPreviewHolder).offset(-5)
                make.top.equalTo(videoPreviewHolder).offset(5)
            }
        } else  {
            addAnotherStreamerIcon.snp_remakeConstraints { make in
                make.top.right.width.height.equalTo(0);
            }
        }
    }
    
    override func stopSession() {
        super.stopSession();
        stopPlayers(.All);
        if wsTalkViewModel != nil {
            wsTalkViewModel = nil;
        }
    }
    
    deinit {
        stopSession();
        print("DEINIT: \(self)");
    }
}
