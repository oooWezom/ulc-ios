//
//  MessagesViewController.swift
//  ULC
//
//  Created by Alex on 7/12/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MBProgressHUD
import ReactiveCocoa
import Kingfisher

class MessagesViewController: JSQMessagesViewController {
    
    var parther: EventBaseEntity?;
    var partnerId = 0;
    
    var messages = [JSQMessageEntity]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    private let viewModel               = MessagesViewModel();
    private let userProfileViewModel    = UserProfileViewModel();
    private let wsProfileViewModel      = WSProfileViewModel();
    
    private let refresher = UIRefreshControl()
    private var cellsCount = 0;
    
    private let checkSendImage = R.image.check_send_icon();
    private let checkReadImage = R.image.check_read_icon();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        configurePartnerObject();
        attachSignals();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        wsProfileViewModel.resume();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        wsProfileViewModel.pause();
    }
    
    func refresh() {
        cellsCount = messages.count;
        loadMessages(true);
    }
    
    func openProfile() {
        if let parther = parther {
            viewModel.openUserProfileVC(parther.id)
        }
    }
    
    private func configurePartnerObject() {
        
        if parther != nil {
            self.configureMessagesView();
            self.setupBubbles()
            self.loadMessages();
            
        } else {
            
            userProfileViewModel.userID = partnerId
            self.senderId = String(partnerId)
            senderDisplayName = ""
            
            self.userProfileViewModel
                .loadUserDataProfile(partnerId)
                .takeUntil(self.rac_willDeallocSignalProducer())
                .producer
                .startWithSignal { (signal, disposable) in
                    signal.observeFailed({ (error: ULCError) in
                        Swift.debugPrint(error)
                })
            }
            
            userProfileViewModel.userEntity
                .producer
                .observeOn(UIScheduler())
                .startWithNext { [weak self] (user: UserEntity?) in
                    
                guard let currentPartner = user else {
                    return;
                }
                    
                self?.parther = Partner.partherFromUser(currentPartner)
                
                self?.configureMessagesView();
                self?.setupBubbles()
                self?.loadMessages();
            }
        }
    }
    
    private func attachSignals() {
        
        wsProfileViewModel.instantMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard   let newMessage = observer.value?.message,
                        let sender = newMessage.sender, let strongSelf = self else {
                        return;
                }
                
                if sender.id != Int(strongSelf.senderId) {
                    return;
                }
                
                let jsqMessage = JSQMessageEntity.init(
                    senderId: String(sender.id),
                    senderDisplayName: "",
                    date: NSDate(timeIntervalSince1970: NSTimeInterval(newMessage.postedTimestamp)),
                    text: newMessage.text,
                    messageId: newMessage.id,
                    delivered_timestamp: 0);
                strongSelf.addNewMessageToMessages(jsqMessage);
        }
        
        let newInstantMessageSignal = wsProfileViewModel.newInstantMessageHadler.0;
        
        newInstantMessageSignal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard   let newMessage = observer.value?.message,
                    let sender = newMessage.sender else {
                        return;
                }
                guard let myParther = self?.parther where myParther.id == sender.id else {
                    return;
                }
                
                let jsqMessage = JSQMessageEntity.init(senderId: String(myParther.id),
                    senderDisplayName: "",
                    date: NSDate(timeIntervalSince1970: NSTimeInterval(newMessage.postedTimestamp)),
                    text: newMessage.text);
                self?.addNewMessageToMessages(jsqMessage);
                
                // MARK:- reading current message
                if let messageEntity = observer.value?.message {
                    let messageArray = [messageEntity.id]
                    self?.wsProfileViewModel.readInstantMessage(messageArray)
                }
        }
        
        wsProfileViewModel.readInstantMessageHandler.signal
            .observeOn(UIScheduler())
            .observeResult { [weak self] observer in
                guard   let message = observer.value,
                        let strongSelf = self else {
                    return
                }
                
                for messageOnject in strongSelf.messages {
                    if let id = messageOnject.messageId where message.messages.contains(id) {
                        messageOnject.delivered_timestamp = 1
                    }
                }
                strongSelf.collectionView.reloadData()
        }
    }
    
    private func addNewMessageToMessages(message: JSQMessageEntity) {
        messages.append(message);
        finishSendingMessageAnimated(true);
    }
    
    private func configureMessagesView() {
        
        if let parther = parther {
            
            senderId = String(viewModel.currentId);
            senderDisplayName = "";
            self.title = parther.name
            
            KingfisherManager.sharedManager.retrieveImageWithURL(
                NSURL(string: Constants.userContentUrl + parther.avatar)!,
                optionsInfo: [.BackgroundDecode],
                progressBlock: nil,
                completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                    if image != nil {
                        self?.configureRightBarButton(image!)
                    } else {
                        if let defaultAvatar = R.image.default_small_avatar() {
                            self?.configureRightBarButton(defaultAvatar);
                        }
                    }
                })
        }
        
        refresher.attributedTitle = NSAttributedString(string: R.string.localizable.pull_to_refresh());
        refresher.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged);
        collectionView.addSubview(refresher);
        
        self.inputToolbar.contentView.leftBarButtonItem = nil;
        
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator = false;
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: .LoginButtonNormal);
    }
    
    private func configureRightBarButton(image: UIImage) {
        
        let rightImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal);
        
        let rightButton = UIButton(type: .Custom);
        rightButton.setTitle("", forState: .Normal);
        rightButton.setImage(rightImage, forState: .Normal);
        rightButton.setImage(rightImage, forState: .Selected);
        rightButton.setImage(rightImage, forState: .Highlighted);
        rightButton.addTarget(self, action: #selector(openProfile), forControlEvents: .TouchUpInside);
        
        rightButton.width = 40;
        rightButton.height = 40;
        rightButton.roundedView(true, borderColor: UIColor(named: .LoginButtonNormal), borderWidth: 2.0, cornerRadius: 20);
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton);
    }
    
    private func loadMessages(update: Bool = false) {
        
        if let tmpParther = parther {
            
            MBProgressHUD.showHUDAddedTo(self.view, animated: true);
            
            viewModel.loadMessages(tmpParther.id)
                .producer
                .takeUntil(self.rac_willDeallocSignalProducer())
                .observeOn(UIScheduler())
                .startWithSignal({ [weak self] (observer, disposable) -> () in
                    
                    observer.observeResult { observer in
                        
                        guard let values = observer.value,
                              let strongSelf = self else {
                            return
                        }
                        
                        if !strongSelf.messages.isEmpty {
                            strongSelf.messages.removeAll();
                        }
                        strongSelf.messages = values;
                        strongSelf.collectionView.reloadData();
                        
                        // MARK:- messages reading via sockets
                        var messagesId = [Int]()
                        for message in values {
                            if let messageId = message.messageId where message.senderId != String(strongSelf.viewModel.currentId) {
                                messagesId.append(messageId)
                            }
                        }
                        strongSelf.wsProfileViewModel.readInstantMessage(messagesId)
                        }
                    
                    observer.observeCompleted({
                        guard let strongSelf = self else {
                            return
                        }
                        if update {
                            let indexPath = NSIndexPath(forRow: strongSelf.cellsCount - 1, inSection: 0)
                            strongSelf.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
                        } else {
                            strongSelf.scrollToBottomAnimated(false);
                        }
                        strongSelf.collectionView.collectionViewLayout.invalidateLayout();
                        
                        strongSelf.refresher.endRefreshing();
                        MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    })
                    
                    observer.observeFailed({ (let error) in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.refresher.endRefreshing();
                        MBProgressHUD.hideAllHUDsForView(strongSelf.view, animated: true)
                    })
                })
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            
            if message.delivered_timestamp == 0 {
                cell.setSelectedIcon(checkSendImage);
            } else {
                cell.setSelectedIcon(checkReadImage);
            }
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let jsqmessage = messages[indexPath.row];
        return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(jsqmessage.date);
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapCellAtIndexPath indexPath: NSIndexPath, touchLocation: CGPoint) {
        self.view!.endEditing(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath) {
        self.view!.endEditing(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.row % 3 == 0 {
            return 20.0;
        } else {
            return 0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil;
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text.isEmpty {
            return;
        }
        
        guard let senderID = Int(senderId) where senderID > 0 else {
            return
        }
        
        if let parther = parther {
            wsProfileViewModel.instantMessage(text, senderId: parther.id);
        }
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor(named: .LoginButtonNormal))
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
}
