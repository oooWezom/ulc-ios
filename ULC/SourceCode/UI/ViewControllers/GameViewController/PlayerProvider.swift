//
//  PlayerProvider.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

final class PlayerProvider {
    
    func makeGamePlayer(delegate:Playable) -> ULCGamePlayer {
        let player = ULCPlayer()
        player.delegate = delegate
        return ULCGamePlayer(player: player)
    }
}