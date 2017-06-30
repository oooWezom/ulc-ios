//
//  WSTalkApiManager.swift
//  ULC
//
//  Created by Vitya on 9/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

public enum WSTalkApiManager {
    
    case SendMessage(String)
    case LeaveTalk()
    case SendDonateMessage(String)
    case DetachTalk()
    case SwitchTalk(Int)
    case UpdateTalkData(String)
    case TalkLikes(Int)
    case TalkLikesOpponent(Int, Int)
    case FindTalk(Int, Int?)
    case FindTalkPartner()
    case CancelFindTalkPartner()
    case InviteTalkPartner(Int, Int)
    case InviteToTalkResponseAccept(Int)
    case InviteToTalkResponseDeny(Int)
    case InviteResponseNotDisturb(Int, Int)
    case ReportUserBehavior(Int, Int?, Int, String?)
    case GetTalkState()
}

extension WSTalkApiManager {
    
    var parameters: [String: AnyObject]? {
        
        switch self {
            
        case .SendMessage(let text):
            return [WSTalkApiManagerKey.type: TalkEvents.TALK_MESSAGE.rawValue,
                    WSTalkApiManagerKey.text: text];
            
        case .LeaveTalk():
            return[WSTalkApiManagerKey.type: TalkEvents.LEAVE_TALK.rawValue];
            
        case .SendDonateMessage(let text):
            return [WSTalkApiManagerKey.type: TalkEvents.SEND_DONATE_MESSAGE.rawValue,
                    WSTalkApiManagerKey.text: text];
            
        case .DetachTalk():
            return [WSTalkApiManagerKey.type: TalkEvents.DETACH_TALK.rawValue];
            
        case .SwitchTalk(let nextSessionID):
            return [WSTalkApiManagerKey.type: TalkEvents.SWITCH_TALK.rawValue,
                    WSTalkApiManagerKey.to: nextSessionID];
            
        case .UpdateTalkData(let newTalkName):
            return [WSTalkApiManagerKey.type: TalkEvents.UPDATE_TALK_DATA.rawValue,
                    WSTalkApiManagerKey.name: newTalkName];
            
        case .TalkLikes(let likesCount):
            return [WSTalkApiManagerKey.type: TalkEvents.TALK_LIKES.rawValue,
                    WSTalkApiManagerKey.likes: likesCount];
            
        case .FindTalk(let catefory, let except):
            
            if let except = except {
                return [WSTalkApiManagerKey.type: TalkEvents.FIND_TALK.rawValue,
                       // WSTalkApiManagerKey.category: catefory,
                        WSTalkApiManagerKey.except: except];
            } else {
                return [WSTalkApiManagerKey.type: TalkEvents.FIND_TALK.rawValue,
                        WSTalkApiManagerKey.category: catefory];
            }
            
        case .FindTalkPartner():
            return [WSTalkApiManagerKey.type: TalkEvents.FIND_TALK_PARTNER.rawValue]
            
        case .CancelFindTalkPartner():
            return [WSTalkApiManagerKey.type: TalkEvents.CANCEL_FIND_TALK_PARTNER.rawValue]
            
        case .InviteTalkPartner(let recipient, let category):
            return [WSTalkApiManagerKey.type: TalkEvents.INVITE_TO_TALK.rawValue,
                    WSTalkApiManagerKey.recipient: recipient,
                    WSTalkApiManagerKey.category: category]
            
        case .InviteToTalkResponseAccept(let sender):
            return [WSTalkApiManagerKey.type: TalkEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                    WSTalkApiManagerKey.result: WebSocketInviteResultKey.accept,
                    WSTalkApiManagerKey.sender: sender]
            
        case .InviteToTalkResponseDeny(let sender):
            return [WSTalkApiManagerKey.type: TalkEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                    WSTalkApiManagerKey.result: WebSocketInviteResultKey.deny,
                    WSTalkApiManagerKey.sender: sender]
            
            
        case .InviteResponseNotDisturb(let time, let sender):
            return [WSTalkApiManagerKey.type: TalkEvents.INVITE_TO_TALK_RESPONSE.rawValue,
                    WSTalkApiManagerKey.result: WebSocketInviteResultKey.do_Not_Disturb,
                    WSTalkApiManagerKey.time: time,
                    WSTalkApiManagerKey.sender: sender]
            
        case .ReportUserBehavior(let sessionId, let userId, let categoryId, let comment):
            
            if let userId = userId, let comment = comment {
                return [WSTalkApiManagerKey.type: TalkEvents.REPORT_USER_BEHAVIOR.rawValue,
                        WSTalkApiManagerKey.session: sessionId,
                        WSTalkApiManagerKey.user: userId,
                        WSTalkApiManagerKey.category: categoryId,
                        WSTalkApiManagerKey.comment: comment]
            } else {
                return [WSTalkApiManagerKey.type: TalkEvents.REPORT_USER_BEHAVIOR.rawValue,
                        WSTalkApiManagerKey.session: sessionId,
                        WSTalkApiManagerKey.category: categoryId]
            }
            
        case .GetTalkState():
            return [WSTalkApiManagerKey.type: TalkEvents.TALK_STATE.rawValue]
            
        case .TalkLikesOpponent(let talkID, let likesCount):
            return [WSTalkApiManagerKey.type : TalkEvents.TALK_LIKES.rawValue, WSTalkApiManagerKey.likes : likesCount, WSTalkApiManagerKey.talk_id : talkID]
        }
    }
}

enum WSTalkApiManagerKey {
    
    static let token               = "token";
    static let introduce           = "introduce";
    static let type                = "type";
    static let stype               = "stype";
    static let recipient           = "recipient";
    static let recipient_id        = "recipient_id";
    static let text                = "text";
    static let platform            = "platform";
    static let version             = "version";
    static let category            = "category";
    static let result              = "result";
    static let sender              = "sender";
    static let time                = "time";
    static let name                = "name";
    static let follow_id           = "follow_id";
    static let unfollow_id         = "unfollow_id";
    static let messages            = "messages";
    static let followers           = "followers";
    static let to                  = "to";
    static let except              = "except";
    static let session             = "session";
    static let user                = "user";
    static let comment             = "comment";
    static let likes               = "likes";
    static let talk_id             = "talk";
}
