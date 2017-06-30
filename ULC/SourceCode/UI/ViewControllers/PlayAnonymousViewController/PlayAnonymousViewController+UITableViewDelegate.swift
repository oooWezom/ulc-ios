//
//  PlayAnonymousViewController+UITableViewDelegate.swift
//  ULC
//
//  Created by Alex on 3/2/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

extension PlayAnonymousViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.games.value != nil ? viewModel.games.value!.count : 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newCell:TwoPlayViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        /*
        if let sessions = viewModel.games.value {
            placeholderText(sessions.count)
        }*/
		newCell.selectionStyle = .None
        if let items = viewModel.games.value {
            newCell.updateViewWithModel(items[indexPath.row])
        }
        return newCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = self.tableView.frame.height * 0.5
        return height + 20;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TwoPlayViewCell
        
        if let model = cell.gameEntity {
            
            if model.players.first?.id == viewModel.currentId || model.players.last?.id == viewModel.currentId {
                
                let game = WSGameEntity()
                game.game = model.game
                game.id = model.id
                game.state = model.state
                game.spectators = model.spectators
                game.players.appendContentsOf(model.players)
                game.videoUrl = model.videoUrl
                
                let wsGameCreateEntity = WSGameCreateEntity()
                wsGameCreateEntity.game = game
                
                unityManager.initialUnity(game, ownerID: viewModel.currentId)
                
                //viewModel.openStreamerGameSessionVC(wsGameCreateEntity)
                viewModel.openGameViewController(wsGameCreateEntity)
                
            }else {
                //viewModel.openSpectatorGameSessionVC(model, viewTypeController: viewTypeController);
                viewModel.openSpectatorViewController(model, viewControllerType: viewTypeController)
            }
        }
    }
}

