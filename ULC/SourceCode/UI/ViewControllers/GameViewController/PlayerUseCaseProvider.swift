//
//  PlayerUseCaseProvider.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

final class PlayerUseCaseProvider: UseCaseProvider {
    private let playerProvider: PlayerProvider
    
    init() {
        playerProvider = PlayerProvider()
    }
    
    func makeGamePlayerUseCase(delegate:Playable) -> PlayerUseCase {
        return ULCGamePlayerUseCase(player: playerProvider.makeGamePlayer(delegate))
    }
}