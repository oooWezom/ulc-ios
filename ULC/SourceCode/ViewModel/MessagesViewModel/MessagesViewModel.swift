//
//  MessagesViewModel.swift
//  ULC
//
//  Created by Alex on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import ReactiveCocoa
import Result
import ObjectMapper
import JSQMessagesViewController.JSQMessage
import SwiftDate

class JSQMessageEntity: JSQMessage {
    
    var messageId: Int?
    var delivered_timestamp: Int?
    
    convenience init!(senderId: String!, senderDisplayName: String!, date: NSDate!, text: String!, messageId: Int!, delivered_timestamp: Int!) {
        self.init(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messageId = messageId
        self.delivered_timestamp = delivered_timestamp
    }
}

class MessagesViewModel: GeneralViewModel {
    
    var conversations: AnyProperty<[ConversationEntity]?> { return AnyProperty(_conversations)}
    var messages: AnyProperty<[JSQMessageEntity]?> { return AnyProperty(_messages)}
    
    //MARK private properties
    private var _conversations = MutableProperty<[ConversationEntity]?>(nil);
    private var _messages = MutableProperty<[JSQMessageEntity]?>(nil);
    private var _rawMessages: [MessageEntity] = [];
    
    private let countMessages = 100;
    
    func fetchConversations() -> SignalProducer<[ConversationEntity], ULCError> {
        return SignalProducer { observer, disposable in
            
            networkProvider.request(.Conversations, completion: { [weak self] result in
                switch (result) {
                case let .Success(response):
                    do {
                        guard let json = try response.mapJSON() as? [String:AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                            return
                        }
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                            let items = Mapper<ConversationEntity>().mapArray(jsonString) else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                        }

                        self?._conversations.value = items;
                        observer.sendCompleted();
                    }
                    catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            })
        }
    }
    
    func loadMessages(userID: Int) -> SignalProducer<[JSQMessageEntity], ULCError> {
        let returnValue = fetchMessages(userID, offset: currentOffset);
        currentOffset += countMessages;
        return returnValue;
    }
    
    private func fetchMessages(userID: Int, offset: Int = 0) -> SignalProducer<[JSQMessageEntity], ULCError> {
        
        let returnValue = SignalProducer<[JSQMessageEntity], ULCError> { [weak self]
            observer, disposable in
            
            networkProvider.request(.Messages(userID, offset), completion: { result in
                switch(result) {
                    
                case let .Success(response):
                    
                    do {
                        guard let json = try response.mapJSON() as? [String:AnyObject] else {
                            observer.sendFailed(ULCError.ERROR_INVALID_KEY(key: MapperKey.result));
                            return
                        }
                        
                        guard let jsonString = json[ApiManagerKey.response] as? [AnyObject] where !jsonString.isEmpty,
                            let items = Mapper<MessageEntity>().mapArray(jsonString), let currentId = self?.currentId else {
                                observer.sendFailed(ULCError.ERROR_DATA);
                                return
                        }

                        let jsqmessages =  items.map{(value: MessageEntity) -> JSQMessageEntity in
                            
                            return JSQMessageEntity.init(
                                senderId: value.out == 0 ? String(userID) : String(currentId),
                                senderDisplayName: "",
                                date: NSDate(timeIntervalSince1970: NSTimeInterval(value.postedTimestamp)),
                                text: value.text,
                                messageId: value.id,
                                delivered_timestamp: value.delivered_timestamp);
                            }
                        
                        if self?._messages.value == nil {
                            self?._messages.value = jsqmessages
                        } else {
                            if let _ = self?._messages.value {
                                self?._messages.value!.appendContentsOf(jsqmessages);
                            }
                        }
                        
                        if let values = self?._messages.value where !values.isEmpty {
                            observer.sendNext(values.reverse());
                        }
                        observer.sendCompleted();
                        
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                    
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            })
        }
        return returnValue;
    }
    
    func openMessagesViewController(parther: EventBaseEntity) {
        presenter.openMessagesVC(parther);
    }
    
    deinit {
        _messages.value?.removeAll();
    }
}


