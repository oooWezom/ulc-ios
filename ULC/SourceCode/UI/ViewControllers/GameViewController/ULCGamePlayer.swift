//
//  ULCGamePlayer.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit

final class ULCGamePlayer {
    private let player: ULCPlayer
    
    init(player:ULCPlayer) {
        self.player = player
    }
    
    func getView(path:String) -> UIView {
        return player.getPlayerView(path)
    }
    
    func reconnectPlayer(path:String) {
        player.reconnectPlayer(withPath: path)
    }
    
    func release() {
        player.release()
    }
    
    func destroy() {
        player.destroy()
    }
    
    func setDelegate(delegate:Playable) {
        player.delegate = delegate
    }
}