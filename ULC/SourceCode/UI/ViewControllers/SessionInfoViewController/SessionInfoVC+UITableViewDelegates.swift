//
//  SessionInfoVC+UITableViewDelegates.swift
//  ULC
//
//  Created by Cruel Ultron on 3/28/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

extension SessionInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if event.typeId == EventType.TalkSession.rawValue && event.partners.first == nil {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: SessionInfoCell = tableView.dequeueReusableCell(forIndexPath: indexPath);
		cell.selectionStyle = .None
        cell.delegate = self;
        
        if event.typeId == EventType.GameSession.rawValue {
            if indexPath.row == 0 {
                if let owner = event?.owner {
                    cell.updateViewWithModel(owner);
                }
            } else {
                if let opponent = event?.opponent {
                    cell.updateViewWithModel(opponent);
                }
            }
        } else if event.typeId == EventType.TalkSession.rawValue {
            if indexPath.row == 0 {
                if let owner = event?.owner {
                    cell.updateViewWithModel(owner);
                }
            } else {
                if let partner = event?.partners.first {
                    cell.updateViewWithModel(partner);
                }
            }
        } else if event.typeId == EventType.StartFollow.rawValue {
            if indexPath.row == 0 {
                if let owner = event?.owner {
                    cell.updateViewWithModel(owner);
                }
            } else {
                if let follower = event?.following {
                    cell.updateViewWithModel(follower);
                }
            }
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var entity:EventBaseEntity?;
        
        if indexPath.row == 0 {
            if let owner = event.owner  {
                entity = owner;
            }
        } else {
            if event.typeId == EventType.StartFollow.rawValue {
                if let followEntity = event.following {
                    entity = followEntity;
                }
            } else if event.typeId == EventType.GameSession.rawValue {
                if let opponent = event.opponent {
                    entity = opponent;
                }
            } else {
                if let partner = event.partners.first {
                    entity = partner;
                }
            }
        }
        if let entity = entity {
            if entity.id == 0 || entity.id == messagesViewModel.currentId {
                messagesViewModel.openCurrentUserProfileVCFromMenu(entity.id);
            } else {
                messagesViewModel.openUserProfileVC(entity.id);
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if event.typeId == EventType.StartFollow.rawValue {
            return 0;
        } else {
            if UIDevice.currentDevice().orientation == .LandscapeRight || UIDevice.currentDevice().orientation == .LandscapeLeft {
                return view.height + heightEventDescription;
            } else {
                return view.width * 0.75 + heightEventDescription;
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch event.typeId {
        case EventType.GameSession.rawValue:
            return headerContentView
        case EventType.TalkSession.rawValue:
            return headerContentView;
        default:
            return nil;
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView();
    }
}
