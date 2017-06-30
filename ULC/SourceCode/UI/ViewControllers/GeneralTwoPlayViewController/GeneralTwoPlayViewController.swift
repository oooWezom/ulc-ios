//
//  GeneralTwoPlayViewController.swift
//  ULC
//
//  Created by Alexey on 10/5/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import ReactiveCocoa
import VideoCore
import ObjectMapper
import ReachabilitySwift
import KSYMediaPlayer

enum TwoPlayMode {
    case game, wish, streamer, spectator, done, end, finish, start, not_supported
}

enum Winner {
    case none, first, second
}

enum Player: Int {
    case firstPlayer = 1
    case secondPlayer
}

enum TwoPlayOrientation {
    case onlyLandscape, onlyPortrait, allOrientations
}

class GeneralTwoPlayViewController: UIViewController {
    
    let newUnityView                    = UnityView()
    private var leftTimer               = NSTimer();
    private var rightTimer              = NSTimer();
    private var leftLikesBuffer         = 0;
    private var rightLikesBuffer        = 0;
    let leftHeartView                   = HeartLikeView.instanciateFromNib();
    let rightHeartView                  = HeartLikeView.instanciateFromNib();
    var leftLikeViewPlaceHolder         = UIView()
    var rightLikeViewPlaceHolder        = UIView()
    var leftLikesButton                 = UIButton()
    var rightLikesButton                = UIButton()
    var leftLikes                       = 0;
    var rightLikes                      = 0;
    let animDuration                    = 0.5;
    let animDelay                       = 0.0;
    var isPresented                     = TwoPlayOrientation.allOrientations;
    var leftPlayerID                    = 0;
    var rightPlayerID                   = 0;
    let leftPlaybackView                = UIView();
    let rightPlaybackView               = UIView();
    let videoStreamPreview              = UIView();
    
    lazy var leftPlayerSurfaceView      = UIView();
    lazy var rightPlayerSurfaceView     = UIView();
    
    var leftPlayerXPLabel               = UILabel();
    var rightPlayerXPLabel              = UILabel();
    
    var leftPlayerInfoView              = PlayerInfoView(position: .Left);
    var rightPlayerInfoView             = PlayerInfoView(position: .Right);
    
    var chatView                        = ChatView.instanciateFromNib();
    
    let bottomView                      = TwoPlayGamingBottomView.instanciateFromNib();
    let messageView                     = SendMessageView()
    var unityView                       = UnityGetGLView();
    let wishView                        = WishView()
    var keyboardIsShowing               = false
    var viewModel                       = TwoPlaySpectactorViewModel();
    var spectatorsCount                 = 0;
    var keyboardHeight                  = CGFloat(0);
    var blockAnimation                  = false
    var videoBaseURL                    = ""
    var lastPlaybackTime                = 0.0
    var _sessionID                      = 0
    var _playerID                       = 0
    var lastLeftPlayerPlaybackTime      = 0.0;
	var isGameSupported					= true
    var globalLPlayerTimer: NSTimer?
    var globalRPlayerTimer: NSTimer?
    var state: TwoPlayMode?
    var winner: Winner?
    var streamingSession: VCSimpleSession!;
    var burstTimer: NSTimer?
    var timer: NSTimer?
    var leftRTMPPlayer: KSYMoviePlayerController!;
    var rightRTMPPlayer: KSYMoviePlayerController!;
	var viewTypeController:ViewTypeController = .Normal;
    var signAlertViewController: UIAlertController!;
    var tmpArr = [Int]()

    lazy var leftActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView();
        indicator.hidesWhenStopped = true;
        indicator.activityIndicatorViewStyle = .WhiteLarge;
        indicator.startAnimating()
        return indicator
    }();
    
    lazy var rightActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView();
        indicator.hidesWhenStopped = true;
        indicator.activityIndicatorViewStyle = .WhiteLarge;
        indicator.startAnimating()
        return indicator
    }();

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
		isPresented = .onlyPortrait
        self.stopPlayers(.All)
        self.viewModel.wsSessionViewModel?.destroyPingTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.wsSessionViewModel?.runPingTimer()
        viewModel.wsSessionViewModel?.reachibilityHandler.0.observeResult { observer in
            guard let value = observer.value else {
                return;
            }
            switch value {
            case Reachability.NetworkStatus.ReachableViaWiFi.description:
                Swift.debugPrint(value)
                break;
                
            case Reachability.NetworkStatus.ReachableViaWWAN.description:
                Swift.debugPrint(value)
                break;
                
            case Reachability.NetworkStatus.NotReachable.description:
                Swift.debugPrint(value)
                break;
                
            default:
                break;
            }
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            [weak self] in
            if UIApplication.sharedApplication().statusBarOrientation.isLandscape {
                self?.view.y = 0
            } else {
                self?.view.y = 20
            }
        }
        NSNotificationCenter.defaultCenter()
            .rac_addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil)
            .takeUntil(self.rac_willDeallocSignal())
            .subscribeNext { [weak self](_) in
                self?.isPresented = .onlyPortrait
                
                if self?.leftPlaybackView.superview == nil{
                    if self?.rightRTMPPlayer != nil{
                        self?.stopRightPlayer()
                    }
                } else {
                    self?.stopRightPlayer()
                    self?.stopLeftPlayer()
                }
                
                if let streamingVideoSession = self?.streamingSession {
                    streamingVideoSession.endRtmpSession()
                }
                if let presentingVC = self?.presentingViewController {
                    presentingVC.dismissViewControllerAnimated(true, completion: nil);
                }
        }
        
        if viewTypeController == .Anonymous {
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
    
    func doneClicked() {
        messageView.endEditing(true)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        var newHeight = (self.view.frame.size.width * 0.5) * 0.75
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isLandscape{
            chatView.hidden = true
        }else {
            chatView.hidden = false
        }
        
        if let state = state{
            switch state {

			case .not_supported:
				remakeCommonConstraints(newHeight, orientation: orientation)
				break

            case .streamer, .spectator:
                remakeCommonConstraints(newHeight, orientation: orientation)
                break;
                
            case .done:
                remakeCommonConstraints(newHeight, orientation: orientation)
                break;
                
            case .game:
                break;
                
            case .wish:
                newHeight = (self.view.frame.size.width * 0.66) * 0.75
                wishView.updateConstraints()
                if orientation.isPortrait {
                    
                    unityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view).offset(newHeight)
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(self.view).multipliedBy(0.1)
                    }
                    
                    newUnityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view).offset(newHeight)
                        make.left.right.equalTo(self.view)
                        make.height.equalTo(self.view).multipliedBy(0.1)
                    }
                    
                    chatView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(unityView.snp_bottom).priorityLow()
                        make.left.right.equalTo(self.view).priorityLow()
                        make.bottom.equalTo(self.view).offset(-20).priorityLow()
                    }
                    
                    messageView.snp_remakeConstraints {
                        (make) -> Void in
                        make.left.right.equalTo(view)
                        make.bottom.equalTo(view).offset(-20)
                        make.height.equalTo(40)
                    }
                    
                } else {
                    
                    unityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view).offset(newHeight)
                        make.left.right.bottom.equalTo(self.view)
                    }
                    
                    newUnityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view).offset(newHeight)
                        make.left.right.bottom.equalTo(self.view)
                    }
                    
                    newUnityView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.left.right.bottom.equalTo(unityView)
                    }
                    
                    chatView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.left.width.height.equalTo(0).priorityLow()
                    }
                    
                    messageView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.left.width.height.equalTo(0)
                    }
                    doneClicked() //Close keyboard when orientation is Landscape
                }
                
                if winner == .first {
                    
                    wishView.hidden = false
                    wishView.descriptionLabel.text = ""
                    
                    leftPlayerSurfaceView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.34)
                        make.height.equalTo(newHeight * 0.5)
                    }
                    
                    rightPlayerSurfaceView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.right.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.66)
                        make.height.equalTo(newHeight)
                    }
                    
                    rightPlaybackView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.right.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.66)
                        make.height.equalTo(newHeight)
                    }
                    
                    wishView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(leftPlayerSurfaceView.snp_bottom)
                        make.left.right.equalTo(leftPlayerSurfaceView)
                        make.bottom.equalTo(rightPlayerSurfaceView)
                    }
                    if blockAnimation == false{
                        leftPlayerSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        rightPlayerSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        rightPlaybackView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        wishView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                    }
                    blockAnimation = true
                    
                    
                } else if winner == .second {
                    
                    leftPlayerSurfaceView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.left.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.66)
                        make.height.equalTo(newHeight)
                    }
                    
                    rightPlayerSurfaceView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.right.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.34)
                        make.height.equalTo(newHeight * 0.5)
                    }
                    
                    rightPlaybackView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(self.view)
                        make.right.equalTo(self.view)
                        make.width.equalTo(self.view).multipliedBy(0.34)
                        make.height.equalTo(newHeight * 0.5)
                    }
                    
                    wishView.snp_remakeConstraints {
                        (make) -> Void in
                        make.top.equalTo(rightPlayerSurfaceView.snp_bottom)
                        make.left.right.equalTo(rightPlayerSurfaceView)
                        make.bottom.equalTo(leftPlayerSurfaceView)
                    }
                    if blockAnimation == false{
                        leftPlayerSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        rightPlayerSurfaceView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        rightPlaybackView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                        wishView.animateConstraintWithDuration(animDuration, delay: animDelay, options: .AllowAnimatedContent)
                    }
                    blockAnimation = true
                }
                break;
                
            case .finish:
                remakeCommonConstraints(newHeight, orientation: orientation)
                break;
                
            default:
                break;
            }
        }
    }

    func tryToReconnectLeftPlayer() {
        
        Swift.debugPrint("")
        Swift.debugPrint("+---|>---+ LEFT PLAYER STATE +---<|---+")
        Swift.debugPrint("")
        Swift.debugPrint("IS PLAYING: \(leftRTMPPlayer.isPlaying())")
        Swift.debugPrint("PLAYBACK STATE: \(leftRTMPPlayer.playbackState.rawValue)")
        Swift.debugPrint("LOAD STATE: \(leftRTMPPlayer.loadState.rawValue)")
        Swift.debugPrint("BUFFER EMPTY COUNT: \(leftRTMPPlayer.bufferEmptyCount)")
        Swift.debugPrint("BUFFER TIME MAX: \(leftRTMPPlayer.bufferTimeMax)")
        Swift.debugPrint("CURRENT PLAYBACK TIME: \(leftRTMPPlayer.currentPlaybackTime)")
        Swift.debugPrint("DURATION: \(leftRTMPPlayer.duration)")
        Swift.debugPrint("NATURAL SIZE: \(leftRTMPPlayer.naturalSize)")
        Swift.debugPrint("PLAYABLE DURATION: \(leftRTMPPlayer.playableDuration)")
        Swift.debugPrint("")
        
        if !leftRTMPPlayer.isPlaying() && (leftRTMPPlayer.playbackState != .SeekingForward || leftRTMPPlayer.playbackState == .SeekingBackward) {
            reconnectLeftPlayer();
        }else {
            
            if leftRTMPPlayer.naturalSize == CGSize(width: 0, height: 0) {
                reconnectLeftPlayer();
            } else {
                
                if (Int(lastLeftPlayerPlaybackTime) == Int(leftRTMPPlayer.currentPlaybackTime)) {
                   reconnectLeftPlayer();
                } else {
                    lastLeftPlayerPlaybackTime = leftRTMPPlayer.currentPlaybackTime
                    if leftActivityIndicator.isAnimating() {
                        leftActivityIndicator.stopAnimating()
                    }
                }
                if leftActivityIndicator.isAnimating(){
                    leftActivityIndicator.stopAnimating()
                }
            }
            if leftActivityIndicator.isAnimating(){
                leftActivityIndicator.stopAnimating()
            }
        }
    }
    
    private func reconnectLeftPlayer(){
        if leftRTMPPlayer != nil {
            leftRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
            leftRTMPPlayer.reload(leftRTMPPlayer.contentURL, flush: false, mode: .Accurate);
            leftRTMPPlayer.prepareToPlay()
            //leftRTMPPlayer.play()
            leftActivityIndicator.startAnimating()
        }
    }
    
    private func reconnectRightPlayer(){
        if rightRTMPPlayer != nil {
            rightRTMPPlayer.setVolume(0.75, rigthVolume: 0.75);
            rightRTMPPlayer.reload(rightRTMPPlayer.contentURL, flush: false, mode: .Accurate);//NSURL(string:"\(self.videoBaseURL)/" + videostreamNamePattern(_sessionID, playerID: _playerID))
            rightRTMPPlayer.prepareToPlay()
            //rightRTMPPlayer.play()
            rightActivityIndicator.startAnimating()
        }
    }

    func tryToReconnectRightPlayer() {
        Swift.debugPrint("")
        Swift.debugPrint("+---|>---+ RIGHT PLAYER STATE +---<|---+")
        Swift.debugPrint("")
        Swift.debugPrint("IS PLAYING: \(rightRTMPPlayer.isPlaying())")
        Swift.debugPrint("PLAYBACK STATE: \(rightRTMPPlayer.playbackState.rawValue)")
        Swift.debugPrint("LOAD STATE: \(rightRTMPPlayer.loadState.rawValue)")
        Swift.debugPrint("BUFFER EMPTY COUNT: \(rightRTMPPlayer.bufferEmptyCount)")
        Swift.debugPrint("BUFFER TIME MAX: \(rightRTMPPlayer.bufferTimeMax)")
        Swift.debugPrint("CURRENT PLAYBACK TIME: \(rightRTMPPlayer.currentPlaybackTime)")
        Swift.debugPrint("DURATION: \(rightRTMPPlayer.duration)")
        Swift.debugPrint("NATURAL SIZE: \(rightRTMPPlayer.naturalSize)")
        Swift.debugPrint("PLAYABLE DURATION: \(rightRTMPPlayer.playableDuration)")
        Swift.debugPrint("")

        if !rightRTMPPlayer.isPlaying() && (rightRTMPPlayer.playbackState != .SeekingForward || rightRTMPPlayer.playbackState == .SeekingBackward) {
            reconnectRightPlayer();
        } else {
            if rightRTMPPlayer.naturalSize == CGSize(width: 0,height: 0){
                reconnectRightPlayer();
            } else {
                if (Int(lastPlaybackTime) == Int(rightRTMPPlayer.currentPlaybackTime)){
                    reconnectRightPlayer();
                } else {
                    lastPlaybackTime = rightRTMPPlayer.currentPlaybackTime
                    if rightActivityIndicator.isAnimating(){
                        rightActivityIndicator.stopAnimating()
                    }
                }
                if rightActivityIndicator.isAnimating(){
                    rightActivityIndicator.stopAnimating()
                }
            }
            if rightActivityIndicator.isAnimating(){
                rightActivityIndicator.stopAnimating()
            }
        }
    }
    
    func setupLeftPlayerReconnectTimer() {
        if self.globalLPlayerTimer == nil{
            self.globalLPlayerTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD, target: self, selector: #selector(self.tryToReconnectLeftPlayer), userInfo: nil, repeats: true)
        }
    }
    
    func setupRightPlayerReconnectTimer() {
        if self.globalRPlayerTimer == nil{
            self.globalRPlayerTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.RECONNECT_TIMER_PERIOD, target: self, selector: #selector(self.tryToReconnectRightPlayer), userInfo: nil, repeats: true)
        }
    }
    
    func remakeCommonConstraints(height:CGFloat, orientation:UIInterfaceOrientation){
        
        leftLikeViewPlaceHolder.snp_remakeConstraints{
            (make) -> Void in
            make.left.equalTo(leftPlayerSurfaceView)
            make.top.equalTo(leftPlayerInfoView.snp_bottom)
            make.bottom.equalTo(leftPlayerSurfaceView)
            make.width.equalTo(leftPlayerSurfaceView).multipliedBy(0.25)
        }
        
        leftHeartView.snp_remakeConstraints{
            (make) -> Void in
            make.left.equalTo(leftLikeViewPlaceHolder).offset(10)
            make.bottom.equalTo(leftLikeViewPlaceHolder).offset(-10)
            make.height.equalTo(25)
            make.width.equalTo(28)
        }
        
        rightLikeViewPlaceHolder.snp_remakeConstraints{
            (make) -> Void in
            make.right.equalTo(rightPlayerInfoView)
            make.top.equalTo(rightPlayerSurfaceView.snp_bottom)
            make.bottom.equalTo(rightPlayerSurfaceView)
            make.width.equalTo(rightPlayerSurfaceView).multipliedBy(0.25)
        }
        
        rightHeartView.snp_remakeConstraints{
            (make) -> Void in
            make.right.equalTo(rightLikeViewPlaceHolder).offset(-10)
            make.bottom.equalTo(rightLikeViewPlaceHolder).offset(-10)
            make.height.equalTo(25)
            make.width.equalTo(28)
        }
        
        leftLikesButton.snp_remakeConstraints{
            (make) -> Void in
            make.left.right.top.bottom.equalTo(leftLikeViewPlaceHolder)
        }
        
        rightLikesButton.snp_remakeConstraints{
            (make) -> Void in
            make.left.right.top.bottom.equalTo(rightLikeViewPlaceHolder)
        }
        
        leftPlayerSurfaceView.snp_remakeConstraints {
            (make) -> Void in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.5)
            make.height.equalTo(height)
        }
        
        rightPlayerSurfaceView.snp_remakeConstraints {
            (make) -> Void in
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
            make.width.equalTo(self.view).multipliedBy(0.5)
            make.height.equalTo(height)
        }
                
        leftPlayerInfoView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.right.equalTo(leftPlayerSurfaceView)
            make.height.equalTo(leftPlayerSurfaceView)
        }
        
        rightPlayerInfoView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.right.equalTo(rightPlayerSurfaceView)
            make.height.equalTo(rightPlayerSurfaceView)
        }
        
        rightPlaybackView.snp_remakeConstraints {
            (make) -> Void in
            make.top.left.right.bottom.equalTo(rightPlayerSurfaceView)
        }
        
        leftPlayerXPLabel.snp_remakeConstraints {
            (make) -> Void in
            make.top.equalTo(leftPlayerSurfaceView).offset(30)
            make.right.equalTo(leftPlayerSurfaceView).offset(-30)
            make.left.equalTo(leftPlayerSurfaceView)
        }
        
        rightPlayerXPLabel.snp_remakeConstraints {
            (make) -> Void in
            make.top.equalTo(rightPlayerSurfaceView).offset(30)
            make.left.equalTo(rightPlayerSurfaceView).offset(30)
            make.right.equalTo(rightPlayerSurfaceView)
        }
        
        if orientation.isPortrait {
            unityView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(leftPlayerSurfaceView.snp_bottom)
                make.left.right.equalTo(view)
                make.height.equalTo(view).multipliedBy(0.25)
            }
            
            newUnityView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(leftPlayerSurfaceView.snp_bottom)
                make.left.right.equalTo(view)
                make.height.equalTo(view).multipliedBy(0.25)
            }
            
            chatView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(unityView.snp_bottom).priorityLow()
                make.left.right.equalTo(view).priorityLow()
                make.bottom.equalTo(view).offset(-20).priorityLow()
            }
            bottomView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.bottom.equalTo(unityView)
                make.height.equalTo(30)
            }
            
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view).offset(-20)
                make.height.equalTo(40)
            }
            messageView.updateConstraints()
        } else {
            
            doneClicked() //Close keyboard when orientation is Landscape
            
            unityView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(leftPlayerSurfaceView.snp_bottom)
                make.left.right.bottom.equalTo(view)
            }
            
            newUnityView.snp_remakeConstraints {
                (make) -> Void in
                make.top.equalTo(leftPlayerSurfaceView.snp_bottom)
                make.left.right.bottom.equalTo(view)
            }
            
            chatView.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.width.height.equalTo(0).priorityLow()
            }
            
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.width.height.equalTo(0)
            }
            
            bottomView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.bottom.equalTo(unityView)
                make.height.equalTo(30)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrameNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func setLeftLikes(count: Int?) {
        if let count = count {
            leftLikes = count
            leftHeartView.likesLabel.text = count.roundValueAsString()
        }
    }
    
    func setRightLikes(count: Int?) {
        if let count = count {
            rightLikes = count
            rightHeartView.likesLabel.text = count.roundValueAsString()
        }
    }
    
    func addRightLikes(count: Int) {
        rightLikes += count;
        rightHeartView.likesLabel.text = leftLikes.roundValueAsString()
        startDispersionHearts(min(count, 25), heart: rightHeartView);
    }
    
    func addLeftLikes(count: Int) {
        leftLikes += count;
        leftHeartView.likesLabel.text = leftLikes.roundValueAsString()
        startDispersionHearts(min(count, 25), heart: leftHeartView);
    }
    
    func showLeftHeartAnimation() {
    }
    
    func showRightHeartAnimation() {
    }
    
    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        keyboardIsShowing = true
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardFrame: NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        
        messageView.snp_remakeConstraints {
            (make) -> Void in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(-(keyboardRectangle.size.height + 20))
            make.height.equalTo(40)
        }
    }
    
    func leaveAction(title: String, description: String) {
        leaveAlert(title, description: description)
    }

	func leaveActionSpectator() {
		doLeave()
	}
    
    func fillCurrentPlayerRoundIndicators(ids: [Int]) {
        leftPlayerInfoView.updateIndicators(ids)
    }
    
    func fillOpponentPlayerRoundIndicators(ids: [Int]) {
        rightPlayerInfoView.updateIndicators(ids)
    }
    
    func handleRoundIndicators(ids: [Int]?) {
        var firstIds = [Int]()
        var secondIds = [Int]()
        
        if let ids = ids {
            if !ids.isEmpty {
                ids.forEach {
                    it in
                    if it == leftPlayerID {
                        firstIds.append(it)
                    } else {
                        secondIds.append(it)
                    }
                }
            }
        }
        fillCurrentPlayerRoundIndicators(firstIds);
        fillOpponentPlayerRoundIndicators(secondIds);
    }
    
    func configureCommonSignals() {
        viewModel.gameStateSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard let message = observer.value else {
                    return
                }
                message.data?.playersData.forEach {
                    it in
                    if it.id == self?.leftPlayerID {
                        self?.leftPlayerInfoView.updateIndicatorsFromState(it.wins)
                        if it.wins > 0 {
                            for _ in 1 ... it.wins {
                                self?.tmpArr.append(it.id)
                            }
                        }
                    } else {
                        self?.rightPlayerInfoView.updateIndicatorsFromState(it.wins)
                        
                        if it.wins > 0 {
                            for _ in 1 ... it.wins {
                                self?.tmpArr.append(it.id)
                            }
                        }
                    }
                }
                if let strongSelf = self {
                    strongSelf.viewModel.tmpArr.appendContentsOf(strongSelf.tmpArr)
                }
        }
        viewModel.gameMessageSignal.observeOn(UIScheduler()).observeResult {
            [weak self] observer in
            guard let message = observer.value else {
                return
            }
            self?.chatView.addNewMessage(message)
        }
        
        viewModel.spectatorConnectedSignal
            .observeOn(UIScheduler())
            .observeResult {
                [weak self] observer in
                if let strongSelf = self {
                    strongSelf.spectatorsCount = strongSelf.spectatorsCount + 1
                    strongSelf.chatView.spectatorsCount.text = "\(strongSelf.spectatorsCount)"
                }
        }
    }
    
    func handleSpectatorsCount(count:Int?) {
        guard let count = count else { return }
        spectatorsCount = count
        chatView.spectatorsCount.text = "\(spectatorsCount)"
    }
    
    func hideLeftOptionsAction() {
        if leftPlayerInfoView.placeholderView.hidden {
            leftPlayerInfoView.placeholderView.hidden = false
        } else {
            leftPlayerInfoView.placeholderView.hidden = true
        }
    }
    
    func hideRightOptionsAction() {
        if rightPlayerInfoView.placeholderView.hidden {
            rightPlayerInfoView.placeholderView.hidden = false
        } else {
            rightPlayerInfoView.placeholderView.hidden = true
        }
    }
    
    func addCurrentPlayerXp(count: Int) {
        leftPlayerInfoView.hideIndicators(true)
        leftPlayerXPLabel.hidden = false
        leftPlayerXPLabel.text = count > 0 ? "+ \(count) \(R.string.localizable.xp())" : "\(count) \(R.string.localizable.xp())"
    }
    
    func addOpponentPlayerXp(count: Int) {
        rightPlayerInfoView.hideIndicators(true)
        rightPlayerXPLabel.hidden = false
        rightPlayerXPLabel.text = count > 0 ? "+ \(count) \(R.string.localizable.xp())" : "\(count) \(R.string.localizable.xp())"
    }
    
    func sendMessageAction() {
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
        } else {
            let text = messageView.messageTextView.text;
            let spacesCount = text.characters.filter { $0 == " " }.count
            let charctersCount = text.characters.count
            if spacesCount == charctersCount {
                messageView.messageTextView.text = ""
                messageView.sendMessageButton.enabled = false
            } else {
                self.viewModel.sendGameMessage(text)
                messageView.messageTextView.text = ""
                messageView.sendMessageButton.enabled = false
                chatView.addNewMessage(WSGameChatMessageEntity.createWSGameChatEntity(text, sender: viewModel.getSelfUser()!))
            }
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        keyboardIsShowing = false
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isPortrait {
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.left.right.equalTo(view)
                make.bottom.equalTo(view).offset(-20)
                make.height.equalTo(40)
            }
        } else {
            messageView.snp_remakeConstraints {
                (make) -> Void in
                make.top.left.width.height.equalTo(0)
            }
        }
    }
    
    func addFirstPlayerGestureRecognizer() {
        let firstPlayerSurfaceViewGesture = UITapGestureRecognizer(target: self, action: #selector(surfaceViewAction))
        leftPlayerSurfaceView.addGestureRecognizer(firstPlayerSurfaceViewGesture)
    }
    
    func addSecondPlayerGestureRecognizer() {
        let secondPlayerSurfaceViewGesture = UITapGestureRecognizer(target: self, action: #selector(surfaceViewAction))
        rightPlayerSurfaceView.addGestureRecognizer(secondPlayerSurfaceViewGesture)
    }
    
    func leftLikeAction() {
		if viewTypeController == .Anonymous {
			self.presentViewController(signAlertViewController, animated: true, completion: nil);
		}
    }

    func rightLikeAction() {
		if viewTypeController == .Anonymous {
			self.presentViewController(signAlertViewController, animated: true, completion: nil);
		}
    }

    func addUnityViewGestureRecognizer() {
        let unityViewGestureRecognizer          = UITapGestureRecognizer(target: self, action: #selector(surfaceViewAction))
        let leftNewUnityViewGestureRecognizer   = UITapGestureRecognizer(target: self, action: #selector(surfaceViewAction))
        let rightNewUnityViewGestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(surfaceViewAction))
        let chatViewGestureRecognizer           = UITapGestureRecognizer(target: self, action: #selector(hideChatAction))
        let wishViewGestureRecognizer           = UITapGestureRecognizer(target: self, action: #selector(hideChatAction))
        
        unityView.addGestureRecognizer(unityViewGestureRecognizer)
        newUnityView.leftPlayerView.addGestureRecognizer(leftNewUnityViewGestureRecognizer)
        newUnityView.rightPlayerView.addGestureRecognizer(rightNewUnityViewGestureRecognizer)
        chatView.addGestureRecognizer(chatViewGestureRecognizer)
        wishView.addGestureRecognizer(wishViewGestureRecognizer)
    }
    
    func configureCommonViews() {
        view.addSubview(leftPlayerSurfaceView)
        view.addSubview(rightPlayerSurfaceView)
#if DEBUG
        leftPlayerSurfaceView.backgroundColor = UIColor.greenColor()
        rightPlayerSurfaceView.backgroundColor = UIColor.redColor()
#endif
        leftPlayerSurfaceView.addSubview(leftPlayerInfoView)
        rightPlayerSurfaceView.addSubview(rightPlayerInfoView)
        leftPlayerSurfaceView.addSubview(leftPlayerXPLabel)
        rightPlayerSurfaceView.addSubview(rightPlayerXPLabel)
        view.addSubview(unityView)
        view.addSubview(newUnityView)
        view.addSubview(chatView)
        view.addSubview(bottomView)
        view.addSubview(wishView)
        view.addSubview(messageView)
        view.addSubview(leftLikeViewPlaceHolder)
        view.addSubview(rightLikeViewPlaceHolder)
        leftLikeViewPlaceHolder.addSubview(leftLikesButton)
        rightLikeViewPlaceHolder.addSubview(rightLikesButton)
        leftLikeViewPlaceHolder.addSubview(leftHeartView)
        rightLikeViewPlaceHolder.addSubview(rightHeartView)
        wishView.hidden = true
        unityView.hidden = false
        leftPlayerXPLabel.textColor = UIColor.whiteColor()
        rightPlayerXPLabel.textColor = UIColor.whiteColor()
        leftPlayerXPLabel.textAlignment = .Right
        rightPlayerXPLabel.textAlignment = .Left
        leftPlayerSurfaceView.backgroundColor = UIColor.clearColor()
        rightPlayerSurfaceView.backgroundColor = UIColor.clearColor()
        addFirstPlayerGestureRecognizer()
        addSecondPlayerGestureRecognizer()
        addUnityViewGestureRecognizer()
    }
    
    func hideChatAction(){
        doneClicked()
    }
    
    func surfaceViewAction() {
        if keyboardIsShowing == false {
            if state != .wish {
                if leftPlayerInfoView.hidden && rightPlayerInfoView.hidden && bottomView.hidden {
                    leftPlayerInfoView.hidden = false
                    rightPlayerInfoView.hidden = false
                    bottomView.hidden = false
                    
                    if state == .finish{
                        leftPlayerXPLabel.hidden = false
                        rightPlayerXPLabel.hidden = false
                    }
                } else {
                    leftPlayerInfoView.hidden = true
                    rightPlayerInfoView.hidden = true
                    bottomView.hidden = true
                    
                    if state == .finish{
                        leftPlayerXPLabel.hidden = true
                        rightPlayerXPLabel.hidden = true
                    }
                }
            }
        } else {
            doneClicked()
        }
    }
    
    func changeViewVisibility(orientation: UIInterfaceOrientation?) {
        if let orientation = orientation {
            if orientation.isPortrait {
                messageView.updateConstraints()
            } else {
                messageView.resetConstraints()
            }
        }
    }
    
    func resizeFont() {
        
        var usernameFontSize: CGFloat   = 17.0
        var levelFontSize: CGFloat      = 15.0
        var optionsFontSize: CGFloat    = 16.0
        var wishViewFontSize: CGFloat   = 15.0
        let orientation                 = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isPortrait {
            usernameFontSize  = 13.0
            levelFontSize     = 11.0
            wishViewFontSize  = 9.0
            optionsFontSize   = 12.0
        } else {
            usernameFontSize  = 17.0
            levelFontSize     = 15.0
            wishViewFontSize  = 15.0
            optionsFontSize   = 16.0
        }
        //leftPlayerInfoView.prefferLabel.font           = UIFont.systemFontOfSize(optionsFontSize)
        
        leftPlayerInfoView.followLabel.font             = UIFont.systemFontOfSize(optionsFontSize)
        leftPlayerInfoView.reportLabel.font             = UIFont.systemFontOfSize(optionsFontSize)
        
        //rightPlayerInfoView.prefferLabel.font          = UIFont.systemFontOfSize(optionsFontSize)
        
        rightPlayerInfoView.followLabel.font           = UIFont.systemFontOfSize(optionsFontSize)
        rightPlayerInfoView.reportLabel.font           = UIFont.systemFontOfSize(optionsFontSize)
        
        leftPlayerInfoView.usernameLabel.font          = UIFont.systemFontOfSize(usernameFontSize)
        leftPlayerInfoView.levelLabel.font             = UIFont.systemFontOfSize(levelFontSize)
        rightPlayerInfoView.usernameLabel.font         = UIFont.systemFontOfSize(usernameFontSize)
        rightPlayerInfoView.levelLabel.font            = UIFont.systemFontOfSize(levelFontSize)
        
        //
        leftPlayerXPLabel.font                         = UIFont(name: "HelveticaNeue-Medium", size: levelFontSize)
        rightPlayerXPLabel.font                        = UIFont(name: "HelveticaNeue-Medium", size: levelFontSize)
        //
        
        wishView.descriptionLabel.font                  = UIFont.systemFontOfSize(wishViewFontSize)
        wishView.finishButton.titleLabel?.font          = UIFont.systemFontOfSize(levelFontSize)
        newUnityView.leftPlayerButton.titleLabel?.font  = UIFont.systemFontOfSize(levelFontSize)
        newUnityView.rightPlayerButton.titleLabel?.font = UIFont.systemFontOfSize(levelFontSize)
    }
    
    func resizeWinnerFont(winner: Winner) {
        var usernameFontSize: CGFloat = 13.0
        var levelFontSize: CGFloat    = 11.0
        var optionsFontSize: CGFloat  = 12.0
        let orientation               = UIApplication.sharedApplication().statusBarOrientation
        
        if winner == .first {
            if orientation.isPortrait {
                usernameFontSize  = 11.0
                levelFontSize     = 9.0
                optionsFontSize   = 10.0
            } else {
                usernameFontSize  = 13.0
                levelFontSize     = 11.0
                optionsFontSize   = 12.0
            }
            
            leftPlayerInfoView.usernameLabel.font  = UIFont.systemFontOfSize(usernameFontSize)
            leftPlayerInfoView.levelLabel.font     = UIFont.systemFontOfSize(levelFontSize)
            //leftPlayerInfoView.prefferLabel.font   = UIFont.systemFontOfSize(optionsFontSize)
            leftPlayerInfoView.followLabel.font    = UIFont.systemFontOfSize(optionsFontSize)
            leftPlayerInfoView.reportLabel.font    = UIFont.systemFontOfSize(optionsFontSize)
        } else {
            
        }
    }
    
    func leaveAlert(title: String, description: String) {
		if state == .spectator{
			doLeave()
		}else {
			let alert = UIAlertController(title: title, message: description, preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: UIAlertActionStyle.Cancel, handler: nil))
			alert.addAction(UIAlertAction(title: R.string.localizable.ok().uppercaseString, style: UIAlertActionStyle.Default, handler: {
				[weak self] action in
				self?.doLeave()
				}))
			self.presentViewController(alert, animated: true, completion: nil)
			alert.view.tintColor = UIColor(named: .LoginButtonNormal)
		}

    }

    private func doLeave() {
        isPresented = .onlyPortrait
        
        stopRightPlayer();
        stopLeftPlayer();
        
        if let streamingVideoSession = streamingSession {
            streamingVideoSession.endRtmpSession()
        }
        
        viewModel.endSession()
        
        if let presentingVC = self.presentingViewController {
            presentingVC.dismissViewControllerAnimated(true, completion: nil);
        }
    }
    
    final func streamerLeftAlert() {
        pauseLeftPlayer();
        let action = UIAlertAction.init(title: R.string.localizable.ok(), style: .Default, handler: nil);
        let alertController = UIAlertController.init(title: nil, message: R.string.localizable.streamer_has_just_leaved_session(), preferredStyle: .Alert); 
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil);
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
        if leftRTMPPlayer != nil {
            globalLPlayerTimer?.invalidate()
            globalLPlayerTimer = nil
            leftRTMPPlayer.pause()
            leftRTMPPlayer.reset(true)
            leftRTMPPlayer.stop();
            leftRTMPPlayer.view.removeFromSuperview()
            leftRTMPPlayer = nil
            debugPrint("STOP LEFT PLAYER \(leftRTMPPlayer)")
        }
    }
    
    final func stopRightPlayer() {
        //stop right
        if rightRTMPPlayer != nil {
            globalRPlayerTimer?.invalidate()
            globalRPlayerTimer = nil
            rightRTMPPlayer.pause()
            rightRTMPPlayer.reset(true)
            rightRTMPPlayer.stop()
            rightRTMPPlayer.view.removeFromSuperview()
            rightRTMPPlayer = nil
            debugPrint("STOP RIGHT PLAYER \(rightRTMPPlayer)")
        }
    }
    
    final func pauseLeftPlayer() {
        if leftRTMPPlayer != nil {
            leftRTMPPlayer.pause();
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
    
    func startDispersionHearts(count:Int, heart:HeartLikeView) {
        for _ in 0..<count {
            let h = UIView();
            h.frame = CGRectMake(0, 0, 11, 11);
            let bezire = UIBezierPath();
            bezire.getHearts(h.bounds, scale: 1);
            let l = CAShapeLayer();
            l.path = bezire.CGPath;
            h.layer.mask = l;
            h.backgroundColor = UIColor.random();
            view.insertSubview(h, belowSubview: heart);
            h.centerWith(heart.likeButton);
            h.alpha = 0.33;
            
            UIView.animateWithDuration(1.5, animations: { [unowned self] in
                if heart == self.leftHeartView {
                    h.x = CGFloat(arc4random_uniform(UInt32(self.view.width * 0.25)) + 1);
                    h.y = CGFloat(arc4random_uniform(UInt32(self.view.width * 0.25)) + 1);
                    if arc4random_uniform(2) == 0 {
                        h.x *= -1;
                        h.y *= -1;
                    }
                } else {
                    let newX = CGFloat(arc4random_uniform(UInt32(self.view.width * 0.25)) + 1);
                    let newY = CGFloat(arc4random_uniform(UInt32(self.view.width * 0.3)) + 1);
                    let tmpX = (self.view.width * 0.7) + newX;
                    h.x = max(self.view.width * 0.75, tmpX);
                    h.y = min(newY, 22);
                    if arc4random_uniform(2) == 0 {
                        h.y *= -1;
                    }
                }
                let transformSize = CGFloat.random()
                h.transform = CGAffineTransformMakeScale(CGFloat(transformSize), CGFloat(transformSize));
                
                }, completion: { success in
                    h.removeFromSuperview();
            })
            UIView.animateWithDuration(1.5, animations: {
                h.alpha = 0;
            })
        }
        heart.launchPulseAnimation(Float(count));
    }


    
    deinit {
        viewModel.cleanUpUnityState()
        self.stopPlayers(.All)
    }
}

