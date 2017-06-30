//
//  BaseStreamViewController.swift
//  ULC
//
//  Created by Vitya on 9/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ObjectMapper
import Kingfisher
import ReactiveCocoa
import QuartzCore
import AVFoundation
import VideoCore
import KSYMediaPlayer
import ReachabilitySwift

struct HeartAttributes {
    static let heartSize: CGFloat = 20
    static let burstDelay: NSTimeInterval = 0.1
}

enum UserType {
    case Streamer
    case Spectator
}

class GeneralStreamViewController: UIViewController {
    
    let customAlertMessageController = CustomMessageAlertController()
    
    var streamingVideoSession:VCSimpleSession!;
    var leftRTMPPlayer:  KSYMoviePlayerController!
    var rightRTMPPlayer: KSYMoviePlayerController!
    var streamTypeView              = StreamTypeView.LeftStreamer;
    var preferedStreamer            = PreferredStreamer.LeftStreamer
    var switchStreamerFlag          = false
    var lastLeftPlayerPlaybackTime  = 0.0;
    var lastRightPlayerPlaybackTime = 0.0;
    
    // MARK:- information about users
    let firstSreamerAvatarView  = FirstSreamerAvatarView.instanciateFromNib()
    let secondSreamerAvatarView = SecondStreamerAvatarView.instanciateFromNib()
    var isInterfaceShowing      = false
    var currentSpectators       = 0;
    
    let chatPlaceholderView         = UIView()
    let reportUserBehaviorAlertView = ReportUserBehaviorAlertView()
    
    //MARK Video View PlaceHolders
    let videoPreviewHolder  = UIView(frame: CGRectZero);
    let ownerVideoPreview   = UIView(frame: CGRectZero)
    let guestVideoPreview   = UIView(frame: CGRectZero);
    
    var wsTalkViewModel: WSTalkViewModel!
    var wsSessionInfo: TalkSessionsResponseEntity!;
    
    // MARK bottom gradient
    var bottomView          = SessionBottomView.instanciateFromNib()
    
    // MARK chat
    let chatView            = ChatView.instanciateFromNib()
    let messageView         = SendMessageView()
    var isKeyboardShow      = false
    
    var canTryReconnectRightPlayer      = false
    var canTryReconnectLeftPlayer       = false
    
    var videoBaseURL =                  ""
    
    var globalLPlayerTimer: NSTimer?
    var globalRPlayerTimer: NSTimer?
    
    lazy var rightActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView();
        indicator.hidesWhenStopped = true;
        indicator.activityIndicatorViewStyle = .WhiteLarge;
        indicator.startAnimating();
        return indicator
    }();
    
    lazy var leftActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView();
        indicator.hidesWhenStopped = true;
        indicator.activityIndicatorViewStyle = .WhiteLarge;
        indicator.startAnimating();
        return indicator
    }();
    
    var alertController: UIAlertController?;
    var viewControllerType:ViewTypeController = .Normal;
    var signAlertViewController: UIAlertController!;
    var leaveAlertController: UIAlertController!
    
    var userType:UserType!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        configureViews()
        configureSignals()
        
        self.videoBaseURL = wsSessionInfo.videoUrl
    }
    
    final func switchCamera() {
        if streamingVideoSession == nil {
            return;
        }
        if streamingVideoSession.cameraState == .Front {
            streamingVideoSession.cameraState = .Back;
        } else {
            streamingVideoSession.cameraState = .Front;
        }
    }
    
    func stopSession() {
        if streamingVideoSession != nil {
            streamingVideoSession.endRtmpSession();
            streamingVideoSession = nil;
        }
    }
    
    deinit {
        Swift.debugPrint("DEINIT GENERAL STREAM")
        stopPlayers(.All);
        stopSession();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true;
        
        chatView.spectatorsCount.text = wsSessionInfo.spectators.roundValueAsString()
        
        if wsTalkViewModel != nil {
            wsTalkViewModel.resume();
            wsTalkViewModel.runPingTimer();
        }
        
        //MARK:- first device orientation
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        // MARK landscape orientation flag
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.isPresentedVC)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false;
        if wsTalkViewModel != nil {
            wsTalkViewModel.destroyPingTimer()
            wsTalkViewModel.pause()
        }
    }
    
    func configureViews() {
        configureChat()
        configureVideoPreview()
        configureBottomView()
        configureInterfaceIcons()
        configureGestureRecognizers()
        
        addChatPlaceholderView()
        addChat()
        
        if viewControllerType == .Anonymous {
            signAlertViewController = UIAlertController.init(title: R.string.localizable.please_sign(),
                                                             message: R.string.localizable.functionaly(),
                                                             preferredStyle: .Alert);
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
    
    private func configureChat() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        messageView.sendMessageButton.addTarget(self, action: #selector(sendButtonTouch), forControlEvents: .TouchUpInside)
        hideKeyboardWhenTappedAround()
    }
    
    func configureVideoPreview() {
        
        videoPreviewHolder.backgroundColor = UIColor.blackColor();
        view.addSubview(videoPreviewHolder);
        
        videoPreviewHolder.addSubview(ownerVideoPreview);
        videoPreviewHolder.addSubview(guestVideoPreview);
        #if DEBUG
            ownerVideoPreview.backgroundColor = UIColor.greenColor();
            guestVideoPreview.backgroundColor = UIColor.yellowColor();
        #else
            ownerVideoPreview.backgroundColor = UIColor.blackColor();
            guestVideoPreview.backgroundColor = UIColor.blackColor();
        #endif
    }
    
    func configureGestureRecognizers() {
        let reportRightUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(showRightUserReportAlertMessage))
        secondSreamerAvatarView.reportPlaceholderView.addGestureRecognizer(reportRightUserTapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        videoPreviewHolder.addGestureRecognizer(tapGesture)
        
        let firstSreamerTapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        firstSreamerAvatarView.addGestureRecognizer(firstSreamerTapGesture)
        
        let secondSreamerTapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        secondSreamerAvatarView.addGestureRecognizer(secondSreamerTapGesture)
        
        let bottomViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        bottomView.gestureView.addGestureRecognizer(bottomViewTapGesture)
        
        let leftLikeViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        bottomView.leftLikeViewPlaceHolder.addGestureRecognizer(leftLikeViewTapGesture)
        
        let rightLikeViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(interfaceShowing))
        bottomView.rightLikeViewPlaceHolder.addGestureRecognizer(rightLikeViewTapGesture)
    }
    
    private func addChatPlaceholderView() {
        view.addSubview(chatPlaceholderView)
    }
    
    func configureInterfaceIcons() {
        view.addSubview(firstSreamerAvatarView)
        view.addSubview(secondSreamerAvatarView)
        
        if let streamer = wsSessionInfo.streamer {
            firstSreamerAvatarView.updateViewWithModel(streamer);
        }
        
        bottomView.updateViewWithModel(wsSessionInfo)
    }
    
    func configureSignals() {
        //MARK:- WS signals
        wsTalkViewModel.streamClosedByReportHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.showFinishAlert(R.string.localizable.stream_closed_by_reports()) //#MARK localized
        }
        
        wsTalkViewModel.talkStateHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let strongSelf = self else { return; }
                if let talk = observer.value?.talk {
                    strongSelf.currentSpectators = talk.spectators;
                    strongSelf.chatView.spectatorsCount.text = talk.spectators.roundValueAsString()
                    strongSelf.wsSessionInfo = talk
                    strongSelf.bottomView.updateViewWithModel(talk)
                    // talk likes
                    if !strongSelf.switchStreamerFlag {
                        strongSelf.bottomView.setLeftLikes(talk.likes)
                        strongSelf.bottomView.setRightLikes(talk.linked?.first?.likes)
                    }
                }
        }
        
        wsTalkViewModel.talkMessageEchoHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if let message = observer.value {
                    self?.chatView.addNewMessage(message)
                }
        }
        
        wsTalkViewModel.errorMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                self?.showFinishAlert(R.string.localizable.streamer_has_just_leaved_session()) //#MARK localized
        }
        
        wsTalkViewModel.donateMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if let message = observer.value {
                    Swift.debugPrint(message.toJSON())
                    self?.bottomView.quaseonLabel.text = message.message.text
                }
        }
        
        wsTalkViewModel.spectatorConnectedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if self?.wsSessionInfo.id == observer.value?.talk {
                    self?.currentSpectators += 1;
                    self?.chatView.spectatorsCount.text = self?.currentSpectators.roundValueAsString()
                }
        }
        
        wsTalkViewModel.spectatorDisconnectedHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if self?.wsSessionInfo.id == observer.value?.talk && self?.currentSpectators > 0 {
                    self?.currentSpectators -= 1;
                    self?.chatView.spectatorsCount.text = self?.currentSpectators.roundValueAsString()
                }
                
        }
        
        wsTalkViewModel.updateTalkDataHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                if let message = observer.value where message.talk == self?.wsSessionInfo.id {
                    self?.bottomView.updateName(message.name)
                }
        }
        
        let reachabilitySignal = wsTalkViewModel.reachibilityHandler.0;
        reachabilitySignal.observeResult { observer in
            
            guard let value = observer.value else {
                return;
            }
            
            switch value {
                
            case Reachability.NetworkStatus.NotReachable.description:
                
                let lostInternetAlert = UIAlertController(title: R.string.localizable.error(), message: R.string.localizable.no_internet_connection(), preferredStyle: .Alert)
                lostInternetAlert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Default) { [weak self] action in
                    self?.doLeave()
                    })
                self.presentViewController(lostInternetAlert, animated: true, completion: nil)
                
                break;
                
            default:
                break;
            }
        }
    }
    
    func sendButtonTouch() {
        if viewControllerType == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            wsTalkViewModel.sendMessage(messageView.messageTextView.text)
        }
    }
    
    private func addChat() {
        view.addSubview(chatView)
        view.addSubview(messageView)
    }
    
    func interfaceShowing() {

            if isKeyboardShow {
                view.endEditing(true)
                
            } else {
                switch streamTypeView {
                case .LeftStreamer:
                    firstSreamerAvatarView.hidden = !isInterfaceShowing
                case .RightStreamer:
                    secondSreamerAvatarView.hidden = !isInterfaceShowing
                case .TwoStreamer:
                    firstSreamerAvatarView.hidden = !isInterfaceShowing
                    secondSreamerAvatarView.hidden = !isInterfaceShowing
                }
                
                bottomView.hideElements(!isInterfaceShowing)
                isInterfaceShowing = !isInterfaceShowing
            }
    }
    
    private func configureBottomView() {
        
        let leaveRecognizer = UITapGestureRecognizer(target: self, action: #selector(leaveAction))
        bottomView.leaveView.addGestureRecognizer(leaveRecognizer)
        
        view.addSubview(bottomView)
    }
    
    func leaveAction(sender: UITapGestureRecognizer) {
        leaveAlert()
    }
    
    func keyboardWillChange(notification: NSNotification) {
        isKeyboardShow = true
        
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isPortrait {
            messageView.snp_remakeConstraints{ make in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view).offset( -keyboardRectangle.size.height)
                make.height.equalTo(40)}
        } else {
            messageView.snp_remakeConstraints{ make in
                make.top.left.width.height.equalTo(0)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        isKeyboardShow = false
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isPortrait {
            messageView.snp_remakeConstraints{ make in
                make.left.right.bottom.equalTo(view)
                make.height.equalTo(40)
            }
        } else {
            messageView.snp_remakeConstraints{ make in
                make.top.left.width.height.equalTo(0)
            }
        }
    }
    
    private func leaveAlert() {
        if userType == .Spectator {
            doLeave();
        } else {
            leaveAlertController = UIAlertController(title: R.string.localizable.leave_session(), message: "\(R.string.localizable.leave_session_quastion())", preferredStyle: UIAlertControllerStyle.Alert)
            leaveAlertController.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .Cancel, handler: nil))
            leaveAlertController.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .Default) { [weak self] action in
                self?.doLeave()
            })
            self.presentViewController(leaveAlertController, animated: true, completion: nil)
            leaveAlertController.view.tintColor = UIColor(named: .LoginButtonNormal)
        }
    }
    
    private func doLeave() {
        stopPlayers(.All);
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.isPresentedVC)
        wsTalkViewModel.leaveTalk()
        
        if let presentingVC = self.presentingViewController {
            presentingVC.dismissViewControllerAnimated(true, completion: { [unowned self] in
                self.stopSession();
                self.wsTalkViewModel = nil;
                })
        }
    }
    
    func showRightUserReportAlertMessage() {}
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.chatView.scrollToBottom()
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == .Portrait {
            
            let newHeight = (self.view.width / 4) * 3;
            
            self.videoPreviewHolder.snp_remakeConstraints(closure: { (make) in
                make.top.equalTo(20);
                make.left.equalTo(0);
                make.width.equalTo(self.view);
                make.height.equalTo(newHeight);
            })
            
            //if left video playing
            if self.streamTypeView == .LeftStreamer {
                
                self.secondSreamerAvatarView.hidden = true;
                self.ownerVideoPreview.snp_remakeConstraints { make in
                    make.edges.equalTo(self.videoPreviewHolder);
                }
                self.guestVideoPreview.snp_remakeConstraints { make in
                    make.top.right.width.height.equalTo(0);
                }
                //if right video playing
            } else if self.streamTypeView == .RightStreamer {
                firstSreamerAvatarView.hidden = true;
                ownerVideoPreview.snp_remakeConstraints{ make in
                    make.top.left.width.height.equalTo(0);
                }
                guestVideoPreview.snp_remakeConstraints { make in
                    make.edges.equalTo(self.videoPreviewHolder);
                }
            } else {
                //if both videos playing
                self.updatePortrainStreamConstraints();
            }
            
            // MARK chat view
            self.chatView.snp_remakeConstraints { make in
                make.top.equalTo(self.videoPreviewHolder.snp_bottom)
                make.left.right.bottom.equalTo(self.view)
            }
            
            messageView.hidden = false
            messageView.snp_remakeConstraints{ make in
                make.left.right.bottom.equalTo(view)
                make.height.equalTo(40)
            }
            
            self.bottomView.snp_remakeConstraints { make in
                make.height.equalTo(videoPreviewHolder).multipliedBy(0.45);
                make.bottom.equalTo(self.videoPreviewHolder);
                make.right.left.equalTo(self.view);
            }
            
        } else {
            view.endEditing(true)
            
            let newWidht = (self.view.height / 3) * 4;
            
            videoPreviewHolder.snp_remakeConstraints { make in
                make.top.equalTo(0);
                make.width.equalTo(newWidht);
                make.height.centerX.equalTo(self.view);
            }
            
            if streamTypeView == .LeftStreamer {
                secondSreamerAvatarView.hidden = true;
                ownerVideoPreview.snp_remakeConstraints { make in
                    make.edges.equalTo(self.videoPreviewHolder);
                }
                guestVideoPreview.snp_remakeConstraints { make in
                    make.left.top.width.height.equalTo(0);
                }
            } else if streamTypeView == .RightStreamer {
                secondSreamerAvatarView.hidden = true;
                ownerVideoPreview.snp_remakeConstraints { make in
                    make.left.top.width.height.equalTo(0);
                }
                guestVideoPreview.snp_remakeConstraints { make in
                    make.edges.equalTo(self.videoPreviewHolder);
                }
            } else {
                videoPreviewHolder.snp_remakeConstraints { make in
                    make.top.bottom.left.right.equalTo(self.view);
                }
                
                self.updateLandscapeStreamConstraints();
            }
            
            // MARK chat view
            chatView.snp_remakeConstraints { make in
                make.top.left.height.width.equalTo(0)
            }
            
            messageView.hidden = true
            messageView.snp_remakeConstraints{ make in
                make.top.left.height.width.equalTo(0)
            }
            
            // MARK bottom view
            bottomView.snp_remakeConstraints { make in
                make.height.equalTo(120);
                make.bottom.equalTo(self.videoPreviewHolder);
                make.left.right.equalTo(view);
            }
        }
        
        updatePlayersContraints()
        bottomView.updateConstraintsIfNeeded()
        
        if streamTypeView == .LeftStreamer {
            bottomView.hideLeftHeartView(false)
            bottomView.hideRightHeartView(true)
        } else if streamTypeView == .RightStreamer {
            bottomView.hideLeftHeartView(true)
            bottomView.hideRightHeartView(false)
        } else {
            bottomView.hideLeftHeartView(false)
            bottomView.hideRightHeartView(false)
        }
        
        firstSreamerAvatarView.snp_remakeConstraints { make in
            make.width.equalTo(self.videoPreviewHolder).multipliedBy(0.5);
            make.height.equalTo(self.videoPreviewHolder).multipliedBy(0.6)
            make.left.top.equalTo(self.videoPreviewHolder)
        }
        
        secondSreamerAvatarView.snp_remakeConstraints { make in
            make.width.equalTo(self.videoPreviewHolder).multipliedBy(0.5);
            make.height.equalTo(self.videoPreviewHolder).multipliedBy(0.6)
            make.right.top.equalTo(self.videoPreviewHolder)
        }
    }
    
    private func updatePortrainStreamConstraints() {
        
        let height = (((view.width * 0.5) / 4) * 3)
        
        ownerVideoPreview.snp_remakeConstraints { make in
            make.left.equalTo(0);
            make.width.equalTo(view).multipliedBy(0.5);
            make.height.equalTo(height);
            make.centerY.equalTo(videoPreviewHolder);
        }
        guestVideoPreview.snp_remakeConstraints { make in
            make.left.equalTo(ownerVideoPreview.snp_right);
            make.width.equalTo(view).multipliedBy(0.5);
            make.height.equalTo(height);
            make.centerY.equalTo(videoPreviewHolder);
        }
    }
    
    private func updateLandscapeStreamConstraints() {
        
        let newWidht = view.width / 2
        let newHeight = (newWidht / 4) * 3;
        
        ownerVideoPreview.snp_remakeConstraints { make in
            make.left.equalTo(0);
            make.width.equalTo(newWidht);
            make.height.equalTo(newHeight);
            make.centerY.equalTo(videoPreviewHolder);
        }
        guestVideoPreview.snp_remakeConstraints { make in
            make.left.equalTo(ownerVideoPreview.snp_right);
            make.width.height.equalTo(newWidht);
            make.height.equalTo(newHeight);
            make.centerY.equalTo(videoPreviewHolder);
        }
    }
    
    final func streamerLeftAlert() {
        leftRTMPPlayer.pause();
        let action = UIAlertAction(title: R.string.localizable.ok(), style: .Default, handler: nil);
        alertController = UIAlertController(title: nil, message: R.string.localizable.streamer_left_session(), preferredStyle: .Alert);
        if let alertVC = alertController {
            alertVC.addAction(action)
            presentViewController(alertVC, animated: true, completion:nil);
        }
    }
    
    func setStreamerAsPreferred(preffer: PreferredStreamer) {


			if preffer == .LeftStreamer {
				preferedStreamer = .LeftStreamer
				firstSreamerAvatarView.prefferUser(true)
				secondSreamerAvatarView.prefferUser(false)
			} else {
				preferedStreamer = .RightStreamer
				firstSreamerAvatarView.prefferUser(false)
				secondSreamerAvatarView.prefferUser(true)
			}

    }

    func showFinishAlert(text: String) {

        stopPlayers(.All);
        
        let action = UIAlertAction(title: R.string.localizable.ok(), style: .Default) { [unowned self] action in
            self.dismissViewControllerAnimated(true, completion: {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: Constants.isPresentedVC)
            })
        }
        
        let alertController = UIAlertController.init(title: nil, message: text, preferredStyle: .Alert);
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion:nil);
        alertController.view.tintColor = UIColor(named: .LoginButtonNormal)
    }
    
    final func updatePlayersContraints() {
        if leftRTMPPlayer != nil {
            if let leftPlayerView = leftRTMPPlayer.view {
                if let view = leftPlayerView.superview {
                    leftPlayerView.snp_remakeConstraints { make in
                        make.edges.equalTo(view);
                    }
                }
                if let _ = leftActivityIndicator.superview {
                    leftActivityIndicator.snp_remakeConstraints { make in
                        make.centerX.centerY.equalTo(ownerVideoPreview)
                    }
                }
            }
        }
        if rightRTMPPlayer != nil {
            if let rightPlayerView = rightRTMPPlayer.view {
                if let view = rightPlayerView.superview {
                    rightPlayerView.snp_remakeConstraints { make in
                        make.edges.equalTo(view);
                    }
                }
                if let _ = rightActivityIndicator.superview {
                    rightActivityIndicator.snp_remakeConstraints { make in
                        make.centerX.centerY.equalTo(guestVideoPreview)
                    }
                }
            }
        }
    }
    
    final func stopPlayers(player: DisconnectPlayer) {
        if player == .Left {
            stopLeftPlayer();
        } else if player == .Right {
            stopRightPlayer();
        } else {
            //stop all
            stopLeftPlayer();
            stopRightPlayer();
        }
    }
    
    final func stopLeftPlayer() {
        //stop left
        leftActivityIndicator.stopAnimating();
        if leftRTMPPlayer != nil {
            
            globalLPlayerTimer?.invalidate()
            globalLPlayerTimer = nil
            
            leftRTMPPlayer.pause();
            leftRTMPPlayer.stop();
            leftRTMPPlayer.view.removeFromSuperview()
            leftRTMPPlayer = nil
        }
    }
    
    final func stopRightPlayer() {
        rightActivityIndicator.stopAnimating();
        //stop right
        if rightRTMPPlayer != nil {
            
            globalRPlayerTimer?.invalidate()
            globalRPlayerTimer = nil
            
            rightRTMPPlayer.pause();
            rightRTMPPlayer.stop()
            rightRTMPPlayer.view.removeFromSuperview()
            rightRTMPPlayer = nil
        }
    }
    
    final func pausePlayers() {
        if leftRTMPPlayer != nil {
            leftRTMPPlayer.pause();
        }
        if rightRTMPPlayer != nil {
            rightRTMPPlayer.pause();
        }
    }
    
    final func resumePlayers() {
        if leftRTMPPlayer != nil {
            leftRTMPPlayer.play();
        }
        if rightRTMPPlayer != nil {
            rightRTMPPlayer.play();
        }
    }
    
    private func reconnectLeftPlayer(){
        if leftRTMPPlayer != nil {
            leftActivityIndicator.startAnimating()
            leftRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
            leftRTMPPlayer.reload(leftRTMPPlayer.contentURL, flush: false, mode: .Accurate);
            leftRTMPPlayer.prepareToPlay()
        }
    }
    
    private func reconnectRightPlayer() {
        if rightRTMPPlayer != nil {
            rightActivityIndicator.startAnimating();
            rightRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
            rightRTMPPlayer.reload(rightRTMPPlayer.contentURL, flush: false, mode: .Accurate);
            rightRTMPPlayer.prepareToPlay()
        }
    }
    
    func tryToReconnectLeftPlayer() {
        /*
        Swift.debugPrint("")
        Swift.debugPrint("+---|>---+ LEFT PLAYER STATE +---<|---+")
        Swift.debugPrint("")
        Swift.debugPrint("IS PLAYING: \(leftRTMPPlayer.isPlaying())")
        Swift.debugPrint("PLAYBACK STATE: \(leftRTMPPlayer.playbackState.rawValue)")
        Swift.debugPrint("LOAD STATE: \(leftRTMPPlayer.loadState.rawValue)")
        Swift.debugPrint("CAN RECONNECT: \(canTryReconnectLeftPlayer)")
        Swift.debugPrint("BUFFER EMPTY COUNT: \(leftRTMPPlayer.bufferEmptyCount)")
        Swift.debugPrint("BUFFER TIME MAX: \(leftRTMPPlayer.bufferTimeMax)")
        Swift.debugPrint("CURRENT PLAYBACK TIME: \(leftRTMPPlayer.currentPlaybackTime)")
        Swift.debugPrint("DURATION: \(leftRTMPPlayer.duration)")
        Swift.debugPrint("NATURAL SIZE: \(leftRTMPPlayer.naturalSize)")
        Swift.debugPrint("")*/
        leftActivityIndicator.stopAnimating();
        if !leftRTMPPlayer.isPlaying() && (leftRTMPPlayer.playbackState != .SeekingForward || leftRTMPPlayer.playbackState == .SeekingBackward) {
            if let alertVC = alertController {
                alertVC.dismissViewControllerAnimated(false, completion: nil);
                alertController = nil;
            }
            reconnectLeftPlayer();
        } else {
            
            if (Int(lastLeftPlayerPlaybackTime) == Int(leftRTMPPlayer.currentPlaybackTime)) {
                reconnectLeftPlayer();
            } else {
                lastLeftPlayerPlaybackTime = leftRTMPPlayer.currentPlaybackTime
            }
        }
    }
    
    
    func tryToReconnectRightPlayer() {
        /*
        Swift.debugPrint("")
        Swift.debugPrint("+---|>---+ RIGHT PLAYER STATE +---<|---+")
        Swift.debugPrint("")
        Swift.debugPrint("IS PLAYING: \(rightRTMPPlayer.isPlaying())")
        Swift.debugPrint("PLAYBACK STATE: \(rightRTMPPlayer.playbackState.rawValue)")
        Swift.debugPrint("LOAD STATE: \(rightRTMPPlayer.loadState.rawValue)")
        Swift.debugPrint("CAN RECONNECT: \(canTryReconnectRightPlayer)")
        Swift.debugPrint("BUFFER EMPTY COUNT: \(rightRTMPPlayer.bufferEmptyCount)")
        Swift.debugPrint("BUFFER TIME MAX: \(rightRTMPPlayer.bufferTimeMax)")
        Swift.debugPrint("CURRENT PLAYBACK TIME: \(rightRTMPPlayer.currentPlaybackTime)")
        Swift.debugPrint("DURATION: \(rightRTMPPlayer.duration)")
        Swift.debugPrint("NATURAL SIZE: \(rightRTMPPlayer.naturalSize)")
        Swift.debugPrint("")*/
        
        rightActivityIndicator.stopAnimating();
        
        if !rightRTMPPlayer.isPlaying() && (rightRTMPPlayer.playbackState != .SeekingForward || rightRTMPPlayer.playbackState == .SeekingBackward) {
            reconnectRightPlayer();
        } else {
            if (Int(lastRightPlayerPlaybackTime) == Int(rightRTMPPlayer.currentPlaybackTime)){
                reconnectRightPlayer();
            }else {
                lastRightPlayerPlaybackTime = rightRTMPPlayer.currentPlaybackTime
            }
        }
    }
    
    func setupLeftPlayerReconnectTimer() {
        if self.globalLPlayerTimer == nil {
            self.globalLPlayerTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD,
                                                                             target: self,
                                                                             selector: #selector(self.tryToReconnectLeftPlayer),
                                                                             userInfo: nil,
                                                                             repeats: true)
        }
    }
    
    func setupRightPlayerReconnectTimer() {
        if self.globalRPlayerTimer == nil {
            self.globalRPlayerTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD,
                                                                             target: self,
                                                                             selector: #selector(self.tryToReconnectRightPlayer),
                                                                             userInfo: nil,
                                                                             repeats: true)
        }
    }
}

extension GeneralStreamViewController: VCSessionDelegate {
    //MARK - VCSessionDelegate
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
            if streamingVideoSession != nil {
                streamingVideoSession.endRtmpSession();
            }
            break;
        }
    }
}
