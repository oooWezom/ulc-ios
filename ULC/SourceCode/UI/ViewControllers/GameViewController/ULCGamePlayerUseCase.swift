//
//  ULCGamePlayerUseCase.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

final class ULCGamePlayerUseCase: PlayerUseCase {
    private let player: ULCGamePlayer
    
    init(player:ULCGamePlayer) {
        self.player = player
    }
       
    func view(path:String) -> UIView {
        return player.getView(path)
    }
    
    func reconnectPlayer(withPath path: String) {
        player.reconnectPlayer(path)
    }
    
    func releasePlayer() {
        player.release()
    }
    
    func destroy() {
        player.destroy()
    }
}