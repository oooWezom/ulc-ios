//
//  CurrentUserProfileViewController.swift
//  ULC
//
//  Created by Alex on 6/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import RSKImageCropper
import ReactiveCocoa
import MBProgressHUD
import Result
import SnapKit
import REFrostedViewController

enum AvatarType: Int {
	case Circle
	case Background
}

class CurrentUserProfileViewController: GeneralUserProfileViewController {

    var avatarType						= AvatarType.Circle;
    var maskRect						= CGRectZero;
    private let imagePicker				= UIImagePickerController();
	lazy private var unityManager		= UnityManager()

	override func viewDidLoad() {
		super.viewDidLoad();
		configureViews();
        checkApiVersion();
        observeSessionState();
	}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        if let vc = UIApplication.containerViewController() as? REFrostedViewController {
            vc.panGestureEnabled = true;
        }
    }

	func changeAvatarPhoto() {
		avatarType = .Circle;
        openAvatarMenuDialog();
	}

	func changeBackgroundPhoto() {
		avatarType = .Background;
		openAvatarMenuDialog();
	}

	override func configureViews() {
		super.configureViews();
        
        imagePicker.delegate = self;

		circleAvatarView.changePhotoButton.addTarget(self, action: #selector(changeAvatarPhoto), forControlEvents: .TouchUpInside);
		userHeaderView.photoButton.addTarget(self, action: #selector(changeBackgroundPhoto), forControlEvents: .TouchUpInside);

		addRefreshControll();
	}
    
    override func refresh() {
        loadEvents(false);
    }
    
    private func openImageSource() {
        imagePicker.allowsEditing = false;
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func openAvatarMenuDialog() {
        
        let alertController = UIAlertController(title: avatarType == .Circle ? R.string.localizable.change_avatar_photo() : R.string.localizable.change_background_photo() , message: nil, preferredStyle: .ActionSheet);
        alertController.view.tintColor = UIColor(named: .LoginButtonNormal);
        
        let cameraAction = UIAlertAction(title: R.string.localizable.camera(), style: .Default, handler: {[unowned self] (action: UIAlertAction!) in
            self.imagePicker.sourceType = .Camera;
            self.openImageSource();
        });
        
        let galleryAction = UIAlertAction(title: R.string.localizable.gallery(), style: .Default, handler: { [unowned self]  (action: UIAlertAction!) in
            self.imagePicker.sourceType = .PhotoLibrary;
            self.openImageSource();
        });
        
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .Destructive, handler: nil);
        
        alertController.addAction(cameraAction);
        alertController.addAction(galleryAction);
        alertController.addAction(cancelAction);
        
        userProfileViewModel.showAlertController(alertController);
    }
    
    override func openFollowers() {
        userProfileViewModel.openFollows(0);
    }
    
    override func openFollowing() {
        userProfileViewModel.openFollowing(0);
    }
    
    override func openGames() {
        userProfileViewModel.openGames(0);
    }
    
    override func openStreams() {
        userProfileViewModel.openStreams(0);
    }
    
    private func checkApiVersion() {
        wsProfileViewModel.getCurrentApiVersion()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] signal, _ in
                signal.observeResult{ result in
                    guard let value = result.value else {
                        return;
                    }
                    switch value {
                    case .OLD_VERSION:
                        self?.showUpdateAlert();
                        break;
                    default:
                        break;
                    }
                }
        }
    }
    
    private func observeSessionState() {
        userProfileViewModel.userEntity
            .producer
            .takeUntilViewControllerDisappears(self)
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (user: UserEntity?) in
                guard let user = user, let status = UserStatus(rawValue: user.status) else {
                    return;
                }
                if status != .Playing && status != .Talking {
                    return;
                }
                
                if let talk = user.talk where status == .Talking {
                    self?.showAlertMessage("", message: R.string.localizable.current_talk(), completitionHandler: { _ in
                        self?.openUnclosedTalkSession(talk);
                    })
                }
                if let game = user.game where status == .Playing {
                    self?.showAlertMessage("", message: R.string.localizable.current_game(), completitionHandler: { _ in
                        self?.openUnclosedGameSession(game);
                    })
                }
        }
    }
    
    private func openUnclosedTalkSession(talk: TalkSessionsResponseEntity) {
        if talk.streamer?.id == userProfileViewModel.currentId {
            //MARK:- reconnect to own session as streamer, left position
            userProfileViewModel.openTalkContainerVC(talk.id, message: talk);
        } else if let linked = talk.linked?.first where linked.streamer?.id == userProfileViewModel.currentId {
            //MARK:- reconnect to own session as streamer, right position
            wsProfileViewModel.createTwoTalk(1, name: "")
        }
    }
    
    private func openUnclosedGameSession(gameSession: GameSessionsEntity) {
        let wsEntity = WSGameEntity.create(gameSession);
        let entity = WSGameCreateEntity.create(wsEntity);
		unityManager.initialUnity(wsEntity, ownerID: userProfileViewModel.currentId)
        userProfileViewModel.openGameViewController(entity)
        //userProfileViewModel.openStreamerGameSessionVC(entity);
    }
}
