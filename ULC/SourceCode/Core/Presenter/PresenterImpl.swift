//
//  PresenterImpl.swift
//  ULC
//
//  Created by Alex on 6/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

final class PresenterImpl: Presenter {
    
    private let storyboard = R.storyboard.main();
    private let router: Router

    
    init() {
        guard let topController = UIApplication.topNavigationViewController() else {
            fatalError("Couldn't init view stack")
        }
        router = RouterImpl(rootController: topController as! ULCNavigationViewController);
    }
    
    func openContainerVC() {
        if let nav = UIApplication.topNavigationViewController() as?  ULCNavigationViewController {
            if let first = nav.viewControllers.first {
                first.popViewController();
                nav.viewControllers.removeAtIndex(0);
            }
            presentContainerVC();
        }
    }
    
    func presentContainerVC() {
        if let vc = R.storyboard.main.containerViewController() {
            router.present(vc, animated: true)
        }
    }
    
    func openTalkContainerVC(sessionId: Int, message: TalkSessionsResponseEntity) {
        if let vc = R.storyboard.main.talkContainerViewController() {
            vc.wsTalkSessionInfo = message
            router.present(vc, animated: true)
        }
    }
    
    func openLoginVC() {
        if let vc = R.storyboard.main.loginViewController(){
            router.push(vc, animated: true);
        }
    }
    
    func openRegisterVC() {
        if let vc = R.storyboard.main.registerViewController() {
            router.present(vc, animated: true)
        }
    }
    
    func openLanguageVC() {
        if let vc = R.storyboard.main.languageViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func backToPreviousVC() {
        router.popController(true)
    }
    
    func openConfirmRegisterVC() {
        if let vc = R.storyboard.main.confirmRegistrationViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func open2Play() {
        if let vc = R.storyboard.main.twoPlayViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func openChooseGameVC() {
        if let vc = R.storyboard.main.chooseGameTableViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func pushWithViewController(vc: UIViewController) {
        router.push(vc)
    }
    
    func getLanguageController() -> LanguageViewController? {
        if let vc = R.storyboard.main.languageViewController() {
            return vc;
        }
        return nil;
    }
    
    func getRegistrationControlller() -> RegisterViewController{
        
        return R.storyboard.main.registerViewController()! as RegisterViewController
    }
    
    func openUserProfileVC(userProfileID: Int) {
        
        //if current user
        if userProfileID == 0 {
            if let vc = R.storyboard.main.currentUserProfileViewController() {
                vc.userProfileID = userProfileID;
                router.openOnMenu(vc);
            }
        } else {
            if let vc = R.storyboard.main.userProfileViewController() {
                vc.userProfileID = userProfileID;
                router.push(vc);
            }
        }
    }
    
    func openNewsFeedVC(userProfileID: Int) {
        let vc = storyboard.instantiateViewControllerWithIdentifier(NewsFeedViewController.typeName) as! NewsFeedViewController;
        vc.userProfileID = 0;
        router.openOnMenu(vc);
    }
    
    func openNewsFeedFilter(viewModel: NewsFeedFilterViewModel) {
        if let vc = R.storyboard.main.newsFeedFilterViewController() {
            vc.viewModel = viewModel;
            router.push(vc);
        }
    }
    
    func openFollowsVC(userProfileID: Int) {
        if let vc = R.storyboard.main.followersViewController() {
            vc.userProfileID = userProfileID;
            if userProfileID == 0 {
                router.openOnMenu(vc);
            } else {
                router.push(vc, animated: true);
            }
        }
    }
    
    func openConversationsVC() {
        if let vc = R.storyboard.main.conversationsViewController() {
            router.openOnMenu(vc);
        }
    }
    
    func openMessagesVC(parther: EventBaseEntity) {
        if let vc = R.storyboard.main.messagesViewController() {
            vc.parther = parther;
            router.push(vc, animated: true);
        }
    }
    
    func openMessagesVC(partherId: Int) {
        if let vc = R.storyboard.main.messagesViewController() {
            vc.partnerId = partherId
            router.push(vc, animated: true);
        }
    }
    
    func openBlackListVC() {
        if let vc = R.storyboard.main.blackListViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func openSettingsVC() {
        if let vc = R.storyboard.main.settingsViewController() {
            vc.userProfileID = 0;
            router.openOnMenu(vc)
        }
    }
    
    func presentLoginVC() {
        if let vc = R.storyboard.main.loginViewController() {
            router.changeRootViewController(vc);
        }
    }
    
    func openChangeLoginVC() {
        if let vc = R.storyboard.main.changeLoginViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func openChangePasswordVC() {
        if let vc = R.storyboard.main.changePasswordViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func openMakeTwoTalkSessionVC() {
        if let vc = R.storyboard.main.makeTwoTalkSessionViewController() {
            router.push(vc, animated: true)
        }
    }
    
    func openUserProfileVCFromMenu(userProfileID: Int) {
        
        if let vc = R.storyboard.main.userProfileViewController() {
            vc.userProfileID = userProfileID;
            vc.shouldShowMenuButton = true;
            router.openOnMenu(vc);
        }
    }
    
    func openCurrentUserProfileVCFromMenu(userProfileID: Int) {
        
        if let vc = R.storyboard.main.currentUserProfileViewController() {
            vc.userProfileID = userProfileID;
            vc.shouldShowMenuButton = true;
            router.openOnMenu(vc);
        }
    }
    
    func openAlertViewController(alertViewController: UIAlertController) {
        router.openAlertViewController(alertViewController);
    }
    
    func openFollowingVC(userProfileID: Int) {
        
        if let vc = R.storyboard.main.followersViewController() {
            vc.userProfileID = userProfileID;
            vc.shouldOpenFollowing = true;
            
            if userProfileID == 0 {
                router.openOnMenu(vc);
            } else {
                router.push(vc, animated: true);
            }
        }
    }
    
    func openTwoTalkVC() {
        if let vc = R.storyboard.main.twoTalkViewController() {
            router.present(vc, animated: true)
        }
    }
    
    func openGamesFeedVC(userProfileID: Int) {
        if let vc = R.storyboard.main.newsFeedViewController() {
            vc.userProfileID = userProfileID;
            vc.feedType = FeedType.Games;
            if userProfileID == 0 {
                router.openOnMenu(vc);
            } else {
                router.push(vc, animated: true);
            }
        }
    }
    
    func openTalksFeedVC(userProfileID: Int) {
        guard let vc = R.storyboard.main.newsFeedViewController() else {
            return;
        }
        vc.userProfileID = userProfileID;
        vc.feedType = FeedType.Talk;
        if userProfileID == 0 {
            router.openOnMenu(vc);
        } else {
            router.push(vc, animated: true);
        }
    }
    
    func openSelfSessionInfoVC(event: SelfEvent) {
        
        guard let vc = R.storyboard.main.sessionInfoViewController() else {
            return;
        }
        vc.event = event;
        let currentUserID = Int(KeychainWrapper.stringForKey(Constants.currentUserId) ?? "0");
        
        if event.owner?.id == currentUserID || event.owner?.id == 0 {
            vc.sessionType = SessionViewType.OnePlayerSession;
        } else {
            vc.sessionType = SessionViewType.TwoPlayerSession;
        }
        router.push(vc, animated: true);
    }
    
    func openSpectatorTalkSessionVC(message: TalkSessionsResponseEntity, let viewControllerType:ViewTypeController) {
        if let vc = R.storyboard.main.spectatorTalkSessionViewController() {
            vc.viewControllerType = viewControllerType;
            vc.wsTalkViewModel = WSTalkViewModel(sessionId: message.id)
            vc.wsSessionInfo = message
            if let _ = message.linked?.first {
                vc.streamTypeView = StreamTypeView.TwoStreamer;
            }
            router.present(vc, animated: true)
        }
    }
    
    func openSpectatorGameSessionVC(model:GameSessionsEntity, let viewControllerType:ViewTypeController) {
        if let vc = R.storyboard.main.twoPlaySpectactorViewController() {
            vc.viewTypeController = viewControllerType;
            vc.viewModel.initSessionViewModel(model.id)
            vc.gameEntity = model
            router.present(vc, animated: true)
        }
    }
    
    func openStreamerGameSessionVC(model: WSGameCreateEntity) {
        if let vc = R.storyboard.main.twoPlayStreamerViewController(){
            if let game = model.game {
                vc.viewModel.initSessionViewModel(game.id)
                vc.viewModel.initData(model)
                router.present(vc, animated: true)
            }
        }
    }
    
    func openMainAnonymousVC() {
        if let vc = R.storyboard.anonymous.containerAnonymousViewController() {
            router.push(vc, animated: true);
        }
    }

	func openAgreementVC() {
		if let vc = R.storyboard.main.agreementViewController() {
			router.push(vc, animated: true);
		}
	}

	func openRestorePasswordVC(key: String) {
		if let vc = R.storyboard.main.restorePasswordViewController() {
			vc.key = key
			router.push(vc)
		}
	}
    
    // MARK new game behavior
    
    func openGameViewController(model:WSGameCreateEntity) {
        if let vc = R.storyboard.game.gameViewController() {
            vc.model = model
            router.present(vc)
        }
    }
    
    func openSpectatorViewController(model:GameSessionsEntity, let viewControllerType:ViewTypeController) {
        if let vc = R.storyboard.game.spectatorViewController() {
            vc.viewTypeController = viewControllerType
            vc.model = model
            router.present(vc)
        }
    }
    
}
