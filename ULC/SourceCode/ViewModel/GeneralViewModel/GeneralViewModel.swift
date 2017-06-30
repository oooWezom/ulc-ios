//
//  GeneralViewModel.swift
//  ULC
//
//  Created by Alex on 6/6/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import RealmSwift
import Realm
import SwiftKeychainWrapper

protocol ViewModelTargetType {
    func configureSignals()
    var currentId: Int { get set }
}

extension ViewModelTargetType {
    
    var currentId: Int {
        
        get {
            guard let value = KeychainWrapper.stringForKey(Constants.currentUserId) else {
                return 0
            }
            guard let returnValue = Int(value) else {
                return 0
            }
            return returnValue;
        }
        
        set {
            self.currentId = newValue;
        }
    }
}

protocol NavigationStackProtocol {

    func openUserProfileVC(userProfileID: Int);
    func openCurrentUserProfileVCFromMenu(userProfileId: Int);
    func openFollows(userProfileID: Int);
    func openFollowing(userProfileID: Int);
    func openNewsFeed(userProfileID: Int);
    func openMessagesVC();
    func openMakeTwoTalkSessionVC();
    func openUserProfileVCFromMenu(userProfileID: Int);
    func showAlertController(alerController: UIAlertController);
    func openGames(userProfileID: Int);
    func openStreams(userProfileID: Int);
    func openSessionInfoViewController(event: SelfEvent);
    
    // MARK new game behavior
    func openGameViewController(model:AnyObject?)
    func openSpectatorViewController(model:AnyObject?, let viewControllerType:ViewTypeController)
}

class GeneralViewModel: ViewModelTargetType, NavigationStackProtocol {
    
    let count           = 100;
    var currentOffset   = 0;
    var userID          = 0;
    
    lazy var presenter: Presenter = PresenterImpl();
    
    lazy var db: RealmDefaultStorage = {
        var configuration = Realm.Configuration()
        configuration.fileURL = NSURL(fileURLWithPath: databasePath("ulc-realm"))
        let _storage = RealmDefaultStorage(configuration: configuration)
        return _storage
    }()
    
    init() {
        configureSignals()
    }
    
    func configureSignals(){}
    
    func getSelfUser() -> UserEntity? {
        do {
            let realm = try Realm()
            if let selfEntity = realm.objects(UserEntity.self).filter(NSPredicate(format: "id == %d", currentId)).first {
                return selfEntity;
            }
        } catch {
            return nil;
        }
        return nil;
    }

    func openUserProfileVC(userProfileID: Int) {
        presenter.openUserProfileVC(userProfileID);
    }

    func openFollows(userProfileID: Int) {
        presenter.openFollowsVC(userProfileID);
    }

    func openNewsFeed(userProfileID: Int) {
        presenter.openNewsFeedVC(userProfileID);
    }

    func openMessagesVC() {
        presenter.openConversationsVC();
    }

    func openSettingsVC() {
        presenter.openSettingsVC()
    }

    func openBlackListVC() {
        presenter.openBlackListVC()
    }

    func openChangeLoginVC() {
        presenter.openChangeLoginVC()
    }

    func openChangePasswordVC() {
        presenter.openChangePasswordVC()
    }

    func presentLoginVC() {
        presenter.presentLoginVC()
    }
    
    func openMakeTwoTalkSessionVC() {
        presenter.openMakeTwoTalkSessionVC()
    }
    
    func openUserProfileVCFromMenu(userProfileID: Int) {
        presenter.openUserProfileVCFromMenu(userProfileID);
    }
    
    func openCurrentUserProfileVCFromMenu(userProfileId: Int) {
        presenter.openCurrentUserProfileVCFromMenu(userProfileId)
    }
    
    func showAlertController(alerController: UIAlertController) {
        presenter.openAlertViewController(alerController);
    }
    
    func openFollowing(userProfileID: Int) {
        presenter.openFollowingVC(userProfileID);
    }
    
    func openGames(userProfileID: Int) {
        presenter.openGamesFeedVC(userProfileID);
    }
    
    func openStreams(userProfileID: Int) {
        presenter.openTalksFeedVC(userProfileID);
    }
    
    func openSessionInfoViewController(event: SelfEvent) {
        presenter.openSelfSessionInfoVC(event);
    }
    
    func openSpectatorTalkSessionVC(message: TalkSessionsResponseEntity, let viewControllerType:ViewTypeController) {
        presenter.openSpectatorTalkSessionVC(message, viewControllerType: viewControllerType);
    }

    func openSpectatorGameSessionVC(model:GameSessionsEntity, viewTypeController: ViewTypeController) {
        presenter.openSpectatorGameSessionVC(model, viewControllerType: viewTypeController)
    }

    func openTalkContainerVC(sessionId: Int, message: TalkSessionsResponseEntity) {
        presenter.openTalkContainerVC(sessionId, message: message)
    }

    func openStreamerGameSessionVC(model:WSGameCreateEntity){
        presenter.openStreamerGameSessionVC(model)
    }
    
    func openMainAnonymousVC() {
        presenter.openMainAnonymousVC();
    }

	func openAgreementVC() {
		presenter.openAgreementVC()
	}
    
    func openGameViewController(model: AnyObject?) {
        if let model = model as? WSGameCreateEntity {
            presenter.openGameViewController(model)
        }
    }
    
    func openSpectatorViewController(model: AnyObject?, viewControllerType: ViewTypeController) {
        if let model = model as? GameSessionsEntity {
            presenter.openSpectatorViewController(model, viewControllerType: viewControllerType)
        }
    }
}

struct  GCD {
    static func serialQueue() -> dispatch_queue_t {
        return dispatch_queue_create("com.wezom.ulc.background.queue", DISPATCH_QUEUE_SERIAL);
    }
}
