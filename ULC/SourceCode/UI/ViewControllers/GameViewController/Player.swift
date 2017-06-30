//
//  Player.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import KSYMediaPlayer

protocol Playable {
    func playing()
    func stopped()
}

final class ULCPlayer {
    
    private var player: KSYMoviePlayerController!
    private var path:String?
    var delegate:Playable?
    
    func getPlayerView(path:String) -> UIView {
        self.path = path
        let absolutePath = NSURL(string:path)
        player = KSYMoviePlayerController(contentURL: absolutePath)
        configurePlayer(player)
        player.prepareToPlay()
        return player.view
    }
    
    func getPlayer() -> KSYMoviePlayerController {
        return player
    }
    
    func release() {
        player.pause()
        player.reset(true)
        player.stop()
    }
    
    func destroy() {
        player = nil
    }
    
    func reconnectPlayer(withPath path:String) {
        
        switch player.playbackState {
            
        case .Interrupted:
            
            break
            
        case .Paused:
            
            break
            
        case .Playing:
            delegate?.playing()
            break
            
        case .Stopped:
            delegate?.stopped()
            let absolutePath = NSURL(string:path)
            player.setVolume(0.75, rigthVolume: 0.75)
            player.reload(absolutePath, flush: false, mode: .Accurate)
            player.prepareToPlay()
            
            break
            
        case .SeekingForward:
            
            break
            
        case .SeekingBackward:
            
            break
        }
    }
    
    private func configurePlayer(player: KSYMoviePlayerController) {
        player.shouldEnableVideoPostProcessing = true
        player.bufferTimeMax = Constants.PLAYER_BUFFER_TIME_MAX
        player.videoDecoderMode = .Hardware
        player.setTimeout(5, readTimeout: 10)
        player.setVolume(0.75, rigthVolume: 0.75)
    }
}