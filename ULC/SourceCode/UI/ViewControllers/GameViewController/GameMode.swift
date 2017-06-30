//
//  GameMode.swift
//  ULC
//
//  Created by Alexey Shtanko on 4/13/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

enum GameMode {
    case GAME, WISH, STREAMER, SPECTATOR, DONE, END, FINISH, START, NOT_SUPPORTED
}

enum WinnerMode {
    case NONE, LEFT, RIGHT
}

enum Players: Int {
    case LEFT_PLAYER = 1
    case RIGHT_PLAYER
}

enum GameViewOrientations {
    case LANDSCAPE, PORTRAIT, ALL
}

enum PlayState:Int {
    case READY = 1
    case PLAYING
    case END
}

enum ViewTypeController: Int {
    case Normal
    case Anonymous
}