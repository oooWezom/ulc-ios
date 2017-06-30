//
//  Presenter.swift
//  ULC
//
//  Created by Alex on 6/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit


protocol Presenter {

    func openContainerVC();
    func presentContainerVC();
    func openConfirmRegisterVC();
    func openLoginVC();
    func openRegisterVC();
    func openLanguageVC();
    func backToPreviousVC();

    func openUserProfileVC(userProfileID: Int);
    func openUserProfileVCFromMenu(userProfileID: Int);
    func openCurrentUserProfileVCFromMenu(userProfileID: Int);
    func openNewsFeedVC(userProfileID: Int);
    func openNewsFeedFilter(viewModel: NewsFeedFilterViewModel);

    func openFollowsVC(userProfileID: Int);
    func openFollowingVC(userProfileID: Int);
    func open2Play();
    func openChooseGameVC();
    func openConversationsVC();
    func openMessagesVC(parther: EventBaseEntity);
    func openMessagesVC(partherId: Int);
    func openBlackListVC();
    func openSettingsVC();
    func openChangeLoginVC();
    func openChangePasswordVC();
    func openMakeTwoTalkSessionVC();
    func openTwoTalkVC();
	func openAgreementVC();
    
    func presentLoginVC();
    func openAlertViewController(alertViewController: UIAlertController);
    
    func openGamesFeedVC(userProfileID: Int);
    func openTalksFeedVC(userProfileID: Int);
    
    func openSelfSessionInfoVC(event: SelfEvent);
    func openSpectatorTalkSessionVC(message: TalkSessionsResponseEntity, let viewControllerType:ViewTypeController);
    func openSpectatorGameSessionVC(model:GameSessionsEntity, let viewControllerType:ViewTypeController);
    func openStreamerGameSessionVC(model:WSGameCreateEntity);
    func openTalkContainerVC(sessionId: Int, message: TalkSessionsResponseEntity)
    
    func openMainAnonymousVC();

	func openRestorePasswordVC(key:String)
    
    // MARK new game behavior
    
    func openGameViewController(model:WSGameCreateEntity)
    func openSpectatorViewController(model:GameSessionsEntity, let viewControllerType:ViewTypeController)
}
