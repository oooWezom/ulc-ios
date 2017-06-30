//
//  SpectatorViewController+Extentions.swift
//  ULC
//
//  Created by Alexey Shtanko on 5/4/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

extension SpectatorViewController : RateCircleViewDelegate{
    
    func rateTimeIsOver(player: Players) {
        self.unbindRateView()
        
        guard let model = model as? GameSessionsEntity else { return }
        
        if player == .LEFT_PLAYER {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.ratePlayer(.RIGHT_PLAYER, playerModels: model.players)
            }
        }
    }
    
    func like(player: Players) {
        
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
            return
        }
        
        guard let wsViewModel = wsViewModel,
            let viewModel = viewModel, let model = model as? GameSessionsEntity else { return }
        
        self.unbindRateView()
        
        if player == .LEFT_PLAYER {
            wsViewModel.votePlus(viewModel.leftPlayerModel.value?.id)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.ratePlayer(.RIGHT_PLAYER, playerModels: model.players)
            }
        }
        
        if player == .RIGHT_PLAYER {
            wsViewModel.votePlus(viewModel.rightPlayerModel.value?.id)
        }
    }
    
    func dislike(player: Players) {
        
        if viewTypeController == .Anonymous {
            self.presentViewController(signAlertViewController, animated: true, completion: nil);
            return
        }
        
        guard let wsViewModel = wsViewModel,
            let viewModel = viewModel, let model = model as? GameSessionsEntity else { return }
        
        self.unbindRateView()
        
        if player == .LEFT_PLAYER {
            wsViewModel.voteMinus(viewModel.leftPlayerModel.value?.id)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                self?.ratePlayer(.RIGHT_PLAYER, playerModels: model.players)
            }
        }
        
        if player == .RIGHT_PLAYER {
            wsViewModel.voteMinus(viewModel.rightPlayerModel.value?.id)
        }
    }
    
}