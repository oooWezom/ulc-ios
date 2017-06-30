//
//  WSGeneralViewModel.swift
//  ULC
//
//  Created by Alex on 8/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import Starscream
import ObjectMapper
import SwiftKeychainWrapper
import ReachabilitySwift

protocol WSViewModelTargetType: ViewModelTargetType {
    func pause();
    func resume();
    var reachibilityHandler: (Signal<String, ULCError>, Observer<String, ULCError>) { get };
}

enum StreamTypeView {
    case LeftStreamer
    case RightStreamer
    case TwoStreamer
}

class WSGeneralViewModel: WSViewModelTargetType, WebSocketDelegate, WebSocketPongDelegate {
    
    var socket:WebSocket!;
    var sessionID:Int!;
    let (signal, observer)  = Signal<Mappable, ULCError>.pipe()
    let entityFactory       = WSEntityFactory();
    let unityEntityFactory  = UnityEntityFactory();
    let unityManager        = UnityManager()
    
    // MARK Private properties
    private var channel: Channel!
    private var shouldNotify: Bool = true;
    
    var reachability: Reachability?;
    let reachibilityHandler = Signal<String, ULCError>.pipe();
    
    var pingTimer: NSTimer?
    
    init(){}
    
    init(channel: Channel, sessionId: Int?) {
        self.channel = channel;
        sessionID = sessionId;
        switch channel {
        case .Session:
            socket = WebSocket(url: NSURL(string: Constants.WEBSOCKET_SESSION_URL + String(sessionId!))!)
            break;
        case .Profile:
            socket = WebSocket(url: NSURL(string: Constants.WEBSOCKET_PROFILE_URL)!)
            break;
        default:
            socket = WebSocket(url: NSURL(string: Constants.WEBSOCKET_TALK_URL + String(sessionId!))!)
            break;
        }
        
        setupReachibility();
        socket.queue = GCD.serialQueue();
        socket.delegate = self;
        socket.pongDelegate = self;
        socket.voipEnabled = true
        
        bind();
    }
    
    func runPingTimer(){
        destroyPingTimer();
        pingTimer = NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: #selector(self.handlePing), userInfo: nil, repeats: true)
    }
    
    func destroyPingTimer(){
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    @objc func handlePing(){
        let string = "Hello from IOS!!"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        if let data = data {
            socket.writePing(data);
        }
    }
    
    func websocketDidReceivePong(socket: WebSocket) {
        Swift.debugPrint("RECEIVE PONG")
    }
    
    func configureSignals() {}
    
    func pause() {
        shouldNotify = false;
    }
    
    func resume() {
        shouldNotify = true;
    }
    
    func bind() {
        if !socket.isConnected {
            socket.connect();
        }
    }
    
    func unbind() {
        if socket != nil && socket.isConnected {
            socket.disconnect(forceTimeout: 0.5);
        }
    }
    
    func websocketDidConnect(socket: WebSocket) {
        authorization();
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        observer.sendCompleted();
    }
    
    //var gameInitChachedState = ""
    //var gameInitChachedStateObject:GameInitMessage?
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Swift.debugPrint(text)
        if !shouldNotify {
            return;
        }
        
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                if let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject] {
                    
                    if let value = entityFactory.createEntity(dictionary, channel: channel) {
                        observer.sendNext(value);
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("SocketNotifiction", object: dictionary)
                    
                    if let value = unityEntityFactory.createEntity(dictionary) {
                        
                        
                        
                        print("****************** VALUE ******************")
                        print(value)
                        print("****************** VALUE ******************")
                        
                        if value is GameInitMessage {
                            let object = value as! GameInitMessage
                            GameStateSingleton.shared.gameInitChachedInitObject = object
                        }
                        
                        if value is GameStateMessage {
                            let object = value as! GameStateMessage
                            if object.type == 1000 {
                                GameStateSingleton.shared.gameInitChachedStateObject = object
                            }
                        }
                        
//                        if let json = value.toJSONString() {
//                            
//                             unityManager.sendMessage("RockSpockMessageRouter", method: "OnMessage", value: json)
//                            
//                            let gameType = GameStateSingleton.shared.gameInitChachedStateObject?.game_type
//                            let type = GameStateSingleton.shared.gameInitChachedStateObject?.type
//                            
//                            if gameType == 7 {
//                                unityManager.sendMessage("SpinTheDisksMessageRouter", method: "OnMessage", value: json)
//                            } else if gameType == 10 {
//                                unityManager.sendMessage("RockSpockMessageRouter", method: "OnMessage", value: json)
//                            }
//                        }
                        
                        
                    }
                    
                    
                }
            } catch {}
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        
    }
    
    private func authorization() {
        if let token = KeychainWrapper.stringForKey(Constants.keyChainValue) where !token.isEmpty {
            self.authorizationToWebSocket(1,
                                          stype:    WSProfileApiManagerKey.introduce,
                                          platform: Constants.PLATFORM,
                                          version:  Constants.API_VERSION,
                                          token:    token)
        } else {
            anonimousAuthorizationToWebSocket(1,
                                              stype: WSProfileApiManagerKey.introduce,
                                              platform: Constants.PLATFORM,
                                              version: Constants.API_VERSION)
        }
    }
    
    final func authorizationToWebSocket(type: Int, stype: String, platform: Int, version: Int, token: String)  {
        if let dictionaryParameters = WSProfielApiManager.Introduce(type, stype, platform, version, token).parameters {
            Swift.debugPrint(dictionaryParameters)
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    final func anonimousAuthorizationToWebSocket(type: Int, stype: String, platform: Int, version: Int) {
        if let dictionaryParameters = WSProfielApiManager.AnonymousIntroduce(type, stype, platform, version).parameters {
            Swift.debugPrint(dictionaryParameters)
            writeDataToSocket(dictionaryParameters);
        }
    }
    
    final func instantMessage(message: String, senderId: Int) {
        
        let rawJSON = WSProfielApiManager.InstantMessage(ProfileEvents.INSTANT_MESSAGE.rawValue, "message", senderId, message).parameters;
        guard let json = rawJSON where !json.isEmpty else {
            return;
        }
        writeDataToSocket(json);
    }
    
    final func writeDataToSocket(rawData: [String : AnyObject]) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(rawData, options: .PrettyPrinted)
            if let string = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                socket.writeString(string as String);
            }
        } catch let error as NSError {
            #if DEBUG
                fatalError(error.description)
            #else
                Swift.debugPrint("error: \(error.description)")
            #endif
        }
    }
    
    func setupReachibility() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            #if DEBUG
                fatalError("ERROR: Unable to create Reachability")
            #else
                Swift.debugPrint("ERROR: Unable to create Reachability")
            #endif
        }
        
        reachability?.whenReachable = { [weak self] innerReachability in
            
            guard let reachabilityObserver = self?.reachibilityHandler.1 else {
                return;
            }
            
            if innerReachability.isReachableViaWiFi() {
                reachabilityObserver.sendNext(innerReachability.currentReachabilityStatus.description);
            } else {
                reachabilityObserver.sendNext(innerReachability.currentReachabilityStatus.description);
            }
        }
        
        reachability?.whenUnreachable = { [weak self] innerReachability in
            
            guard let reachabilityObserver = self?.reachibilityHandler.1 else {
                return;
            }
            reachabilityObserver.sendNext(innerReachability.currentReachabilityStatus.description);
        }
        
        do {
            try reachability?.startNotifier()
        } catch ReachabilityError.UnableToSetCallback {
            #if DEBUG
                fatalError("Unable to start notifier")
            #else
                Swift.debugPrint("Unable to start notifier")
            #endif
        } catch {
            Swift.debugPrint("Unknown error")
        }
    }
    
    deinit {
        destroyPingTimer();
        unbind();
        reachability?.stopNotifier();
        observer.sendCompleted();
    }
}
