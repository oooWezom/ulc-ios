//
//  WSEventTypes.swift
//  ULC
//
//  Created by Alex on 8/1/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

enum Channel {
	case Profile
	case Session
	case Talk
}

enum ProfileEvents: Int {
	case INTRODUCE = 1
	case ERROR
	case LOOKING_FOR_GAME = 10
	case LOOKING_FOR_GAME_RESULT
	case GAME_CREATED
	case CANCEL_GAME_SEARCH
	case LF_GAME_TO_WATCH
	case GAME_FOUND
	case INSTANT_MESSAGE = 101
	case INSTANT_MESSAGE_SELF_ECHO
	case INSTANT_MESSAGE_NEW
	case INSTANT_MESSAGE_MARK_READ
	case FOLLOW_USER
	case UNFOLLOW_USER
	case NEW_FOLLOWER
	case FOLLOWER_REMOVES
	case FOLLOWER_ACKNOWLEDGED
	case CREATE_TALK = 201
	case FIND_TALK = 213
	case INVITE_TO_TALK = 220
	case INVITE_TO_TALK_REQUEST
	case INVITE_TO_TALK_RESPONSE
	case NOTIFY_GAME_STARTED = 301
	case NOTIFY_TALK_STARTED = 302
}

enum SessionEvents: Int {
	case INTRODUCE = 1
	case ERROR
	case LF_GAME_TO_WATCH = 14
	case GAME_FOUND
	case SESSION_MESSAGE = 22
	case END_SESSION = 29
	case INSTANT_MESSAGE = 101
	case INSTANT_MESSAGE_SELF_ECHO
	case INSTANT_MESSAGE_NEW
	case INSTANT_MESSAGE_MARK_READ
	case FOLLOW_USER
  case UNFOLLOW_USER
	case NEW_FOLLOWER
	case FOLLOWER_REMOVES
	case FOLLOWER_ACKNOWLEDGED
	case PLAYER_CONNECTED_TO_SESSION = 123
	case PLAYER_RECONNECTED_TO_SESSION
	case SPECTATOR_CONNECTED_TO_SESSION
	case SESSION_USER_DISCONNECTED = 126
	case SESSION_STATE = 500
	case BEGIN_EXECUTION
	case LOSER_DONE_HIS_PERFORMANCE
	case GAME_RESULTS
	case VOTE_PLUS
	case VOTE_MINUS
	case GAME_STATE = 1000
	case PLAYER_READY
  case ROUND_START
  case GAME_RESULT = 1005
}

enum UnityEvents: Int {
    case INIT_GAME
    case INIT_GAME_STATE = 1000
    case PLAYER_READY
    case ROUND_START
    case MOVE
    case GAME_RESULT = 1005
}

enum TalkEvents: Int {
    
    case INTRODUCE = 1
    case ERROR
    case REPORT_USER_BEHAVIOR = 130
    case STREAM_CLOSED_BY_REPORTS
    case TALK_STATE = 200
    case LEAVE_TALK = 202
    case TALK_MESSAGE
    case FIND_TALK_PARTNER
    case CANCEL_FIND_TALK_PARTNER
    case TALK_ADDED
    case TALK_REMOVED
    case TALK_CLOSED
    case DETACH_TALK
    case SWITCH_TALK
    case UPDATE_TALK_DATA
    case TALK_LIKES
    case FIND_TALK
    case SEND_DONATE_MESSAGE
    case DONATE_MESSAGE
    case INVITE_TO_TALK = 220
    case INVITE_TO_TALK_REQUEST
    case INVITE_TO_TALK_RESPONSE
    case TALK_STREAMER_CONNECTED = 231
    case TALK_STREAMER_RECONNECTED
    case TALK_STREAMER_DISCONNECTED
    case TALK_SPECTATOR_CONNECTED
    case TALK_SPECTATOR_DISCONNECTED
}

enum WSInviteToTalkResponseResult: Int {
	case SendedInvite
	case AccepInvite
	case DenyInvite
	case DoNotDisturb
}

enum WSInviteToTalkResult: Int {
    case OK = 1
    case WRONG_TALK_STATE
    case MAX_PARTNERS
    case USER_NOT_READY
    case INVITATION_EXISTS
    case DO_NOT_DISTURB
}

enum WSReportUserBehavior: Int {
    case None = 0
    case Nudity = 1
    case ViolenceOrHarm
    case Harassment
}
