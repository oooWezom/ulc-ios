//
//  GameStateSingleton.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/15/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

// MARK: - Singleton

final class GameStateSingleton {
    
    private init() { }
    
    // MARK: Shared Instance
    static let shared = GameStateSingleton()
    
    // MARK: Local Variable
    var gameInitChachedInitObject:GameInitMessage?
    var gameInitChachedStateObject:GameStateMessage?
}