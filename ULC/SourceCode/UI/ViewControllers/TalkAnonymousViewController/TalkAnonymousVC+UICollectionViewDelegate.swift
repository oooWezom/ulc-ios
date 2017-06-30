//
//  TalkAnonymousVC+UICollectionViewDelegate.swift
//  ULC
//
//  Created by Alex on 2/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

extension TalkAnonymousViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            guard let items = categoryViewModel.categories.value else {
                return 0;
            }
            return items.count;
        } else {
            guard let items = talkViewModel.talksSession.value else {
                return 0;
            }
            return items.count;
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TalkCategoryIconCell
            if let values = categoryViewModel.categories.value {
                cell.updateViewWithModel(values[indexPath.row]);
            }
            cell.roundIconImageView.hidden = !cell.selected
            return cell
        } else {
            guard let talks = talkViewModel.talksSession.value else {
                fatalError("");
            }
            if let linked = talks[indexPath.row].linked where linked.isEmpty {
                let oneStreamerCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TwoTalkOneStreamerCell
                oneStreamerCell.updateViewWithModel(talks[indexPath.row])
                return oneStreamerCell
            } else {
                let twoStreamersCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as TwoTalkTwoStreamersCell
                twoStreamersCell.updateViewWithModel(talks[indexPath.row])
                return twoStreamersCell
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView.isEqual(categoriesCollectionView) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TalkCategoryIconCell {
                guard let selectedTalkCategory = categoryViewModel.categories.value?[indexPath.row] else {
                    return;
                }
                if selectedTalkCategory.id != groupId {
                    cell.roundIconImageView.hidden = false
                    groupId = selectedTalkCategory.id;
                } else {
                    cell.roundIconImageView.hidden = true;
                    groupId = 0;
                }
                talkViewModel.loadActiveSessions(groupId).start();
            }
        } else if collectionView == talksCollectionView {
            guard let value = talkViewModel.talksSession.value else {
                return;
            }
            let session = value[indexPath.row]
            if talkTypeController == .Normal {
                openNormalTalkViewController(session);
            } else if talkTypeController == .Anonymous {
                openAnonymousTalkSessionViewController(session);
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.isEqual(categoriesCollectionView) {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? TalkCategoryIconCell {
                cell.roundIconImageView.hidden = true
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView.isEqual(talksCollectionView) {
            let size = collectionView.width * 0.5 - 10;
            return CGSizeMake(size, size)
        } else {
            return CGSizeMake(60, 60)
        }
    }
    
    // MARK
    private func openNormalTalkViewController(let session: TalkSessionsResponseEntity) {
        if session.streamer?.id == wsProfileViewModel.currentId {
            //MARK:- reconnect to own session as streamer, left position
            if let router = talkViewModel as? GeneralViewModel {
                router.openTalkContainerVC(session.id, message: session)
            }
        } else if let linked = session.linked?.first where linked.streamer?.id == wsProfileViewModel.currentId {
            //MARK:- reconnect to own session as streamer, right position
            wsProfileViewModel.createTwoTalk(1, name: "")
        } else {
            //MARK:- open session as spectator
            if let router = talkViewModel as? GeneralViewModel {
                router.openSpectatorTalkSessionVC(session, viewControllerType: .Normal)
            }
        }
    }
    
    private func openAnonymousTalkSessionViewController(let session: TalkSessionsResponseEntity) {
        if let router = talkViewModel as? GeneralViewModel {
            router.openSpectatorTalkSessionVC(session, viewControllerType: .Anonymous)
        }
    }
}
