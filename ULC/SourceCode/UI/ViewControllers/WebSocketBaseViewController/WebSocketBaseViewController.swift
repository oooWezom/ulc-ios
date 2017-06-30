//
//  WebSocketBaseViewController.swift
//  ULC
//
//  Created by Alexey on 6/29/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import Starscream
import Foundation

protocol WebSocketProtocol {
	func connect(url: String)
}

class WebSocketBaseViewController: UIViewController, WebSocketDelegate {

	var isConnected = false
	private var socket: WebSocket = WebSocket(url: NSURL(string: Constants.WEBSOCKET_PROFILE_URL)!)
	private var shouldReconnect = false
	private var url = ""
	private var webSocketProtocol = WebSocketProtocol.self

	override func viewDidLoad() {
		super.viewDidLoad()
		socket.delegate = self
	}

	func websocketDidConnect(ws: WebSocket) {
		isConnected = ws.isConnected
	}

	func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
		isConnected = ws.isConnected
		if (shouldReconnect) {
			connectInner(url)
		}
	}

	func websocketDidReceiveMessage(ws: WebSocket, text: String) {

	}

	func websocketDidReceiveData(ws: WebSocket, data: NSData) {

	}

	func disconnect() {
		shouldReconnect = false
		socket.disconnect()
	}

//	func connect(url: String) {
//		connectInner(url)
//	}

	func sendMessage(data: NSData) {
		socket.writeData(data)
	}

	func connectionState() -> Bool {
		return isConnected
	}

	private func connectInner(url: String) {
		self.url = url
		WebSocket.init(url: NSURL(string: url)!).connect()
	}

}
