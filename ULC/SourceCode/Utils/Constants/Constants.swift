//
//  Constants.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

enum Sex: Int, CustomStringConvertible {

    case All
    case Female
    case Male

    var description: String {

        switch self {

        case .All:
            return R.string.localizable.all();
        case .Female:
            return R.string.localizable.female();
        case .Male:
            return R.string.localizable.male();
        }
    }
}

enum LinkType: String {
	case Event = "event"
	case NewAccount = "new-account"
	case RestorePassword = "restore-password"
}

enum DataSourceType {
    case MenuItems
    case UsersProfile
}

enum AccountStatus: Int {
    case Normal = 1
    case Private
}

enum ScreanScale: CGFloat {
    case TwoX = 2.0
    case TreeX = 3.0
}

enum FollowingStatus: Int {
    case Unfollowed
    case Followed
}

enum UserStatus: Int, CustomStringConvertible {
    case All
    case Offline    // User is offline
    case Online     // User is online: connected to profile page
    case Searching  // User is queued to play a game
    case Watching   // User is watching a game
    case Playing    // User is playing a game
    case Talking    // User is talking

    var description: String {

        switch self {

        case .All:
            return R.string.localizable.all();
        case .Offline:
            return R.string.localizable.offline();
        case .Online:
            return R.string.localizable.online();
        case .Searching:
            return R.string.localizable.searching();
        case .Watching:
            return R.string.localizable.watching();
        case .Playing:
            return R.string.localizable.playing();
        case .Talking:
            return R.string.localizable.talking();
        }
    }
}

enum Constants {
#if DEBUG
    static var BASE_URL = ""
    static var WS_BASE_URL = ""
    static var VIDEOSTREAM_URL = "";
#else
    static var BASE_URL = "https://ulc.tv"
    static var WS_BASE_URL = "wss://ulc.tv/ws/"
    static var VIDEOSTREAM_URL = "rtmp://ulc.tv/live/";
#endif

    static let WEBSOCKET_PROFILE_URL = WS_BASE_URL+"profile"
    static let WEBSOCKET_TALK_URL = WS_BASE_URL+"talk/"
    static let WEBSOCKET_SESSION_URL = WS_BASE_URL+"session/"

    static let GAMES_IMAGES_URL = "\(Constants.BASE_URL)/images/games/common/"

    /*
    #if DEBUG
    //static let BASE_URL = "http://dev.ulc.tv"
    //static let WS_BASE_URL = "ws://dev.ulc.tv/ws/"

	// MARK change to let
    static var BASE_URL = "http://dev.ulc.tv"
    static var WS_BASE_URL = "ws://dev.ulc.tv/ws/"
    #else
	// MARK change to let
    static var BASE_URL = "https://ulc.tv"
    static var WS_BASE_URL = "wss://ulc.tv/ws/"
    #endif
*/
    static let firstStart = "firstStart";

    //to know if first start after delete application
    static let runAfterDelete = "RunAfterDelete";

    static let userTalkPreviewUrl                   = "\(Constants.BASE_URL)/preview/t_"
    static let userGamePreviewUrl                   = "\(Constants.BASE_URL)/preview/s_"
    static let userContentUrl                       = "\(Constants.BASE_URL)/user_content/"
    static let eventUrl                             = "\(Constants.BASE_URL)/event/"
    static let keyChainValue                        = "keyChainValue";
    static let currentUserId                        = "id"
    static let localNotificationKey                 = "localNotification";
    static let isPresentedVC                        = "isPresentedVC"

    static let smallTalkCategoryIconUrl				= "\(Constants.BASE_URL)/images/mobile/talk_categories_color/2x-s/"
    static let bigTalkCategoryIconUrl				= "\(Constants.BASE_URL)/images/mobile/talk_categories_color/2x/"
    static let threeXsmallTalkCategoryIconUrl		= "\(Constants.BASE_URL)/images/mobile/talk_categories_color/3x-s/"
    static let threeXbigTalkCategoryIconUrl			= "\(Constants.BASE_URL)/images/mobile/talk_categories_color/3x/"

    static let whiteSmallTalkCategoryIconUrl		= "\(Constants.BASE_URL)/images/mobile/talk_categories_white/2x-s/"
    static let whiteBigTalkCategoryIconUrl			= "\(Constants.BASE_URL)/images/mobile/talk_categories_white/2x/"
    static let whiteThreeXsmallTalkCategoryIconUrl	= "\(Constants.BASE_URL)/images/mobile/talk_categories_white/3x-s/"
    static let whiteThreeXbigTalkCategoryIconUrl	= "\(Constants.BASE_URL)/images/mobile/talk_categories_white/3x/"

    static let playFilter                           = "2PlayFilter";
    static let talkFilter                           = "2TalkFilter";
    static let followingFilter                      = "2FollowingFilter";

    static let PLAYER_BUFFER_TIME_MAX               = 1.0;
    static let PLAYER_PREPARE_TIMEOUT:Int32         = 5;
    static let PLAYER_READ_TIMEOUT:Int32            = 6;
    static let PLAYER_LEFT_VOLUME:Float            = 0.75;
    static let PLAYER_RIGHT_VOLUME:Float           = 0.75;


    // MARK socket api
    /*
     Profile URL
     Example: ws://dev.ulc.network/ws/profile
     */
    /*
    #if DEBUG
    static let WEBSOCKET_PROFILE_URL = WS_BASE_URL+"profile"
    #else
    static let WEBSOCKET_PROFILE_URL = WS_BASE_URL+"profile"
    #endif
*/
    /*
     Session URL
     Example: ws://dev.ulc.network/ws/session/543
     */
    /*
    #if DEBUG
    static let WEBSOCKET_SESSION_URL = WS_BASE_URL+"session/"
    #else
    static let WEBSOCKET_SESSION_URL = WS_BASE_URL+"session/"
    #endif
*/
    /*
     Talk URL
     Example: ws://dev.ulc.network/ws/talk/42
     */
    /*
    #if DEBUG
    static let WEBSOCKET_TALK_URL = WS_BASE_URL+"talk/"
    #else
    static let WEBSOCKET_TALK_URL = WS_BASE_URL+"talk/"
    #endif
*/
    /*
     Videostream URL
     Example: rtmp://ulc.network/live/s_6231_132
     */
    /*
    #if DEBUG
    static let VIDEOSTREAM_URL = "rtmp://dev.ulc.tv/live/"
    #else
    static var VIDEOSTREAM_URL = "rtmp://ulc.tv/live/"
    #endif
*/
    /*
     API Versioning
     */
    static let API_VERSION = 1

    /*
     Platform
     */
    static let PLATFORM = 3

    /*
     Reconnect player period (sec)
     */

    static let RECONNECT_TIMER_PERIOD = 5.0
    static let PLATFORM_ANDROID = 2

    static let CONNECTION_MODE_CONNECT = 0
    static let CONNECTION_MODE_DISCONNECT = 1
    static let CONNECTION_MODE_RECONNECT = 2
    
    static let CURRENT_API_VERSION = 1
}

enum GameID: Int {
    case RANDOM, X_COWS, LAND_IT, MATH2, SPIN_THE_DISKS = 7, ROCK_SPOCK = 10
}

enum IntroduceEvent: Int {
    case INTRODUCE = 1
    case ERROR
}

enum GameEvents: Int {
    case LOOKING_FOR_GAME = 10, LOOKING_FOR_GAME_RESULT, GAME_CREATED, CANCEL_GAME_SEARCH, GAME_FOUND, LF_GAME_TO_WATCH
}

enum GameEventsResult: Int {
    case ADDED_TO_QUEUE = 1, WARNING_BAN, ALREADY_IN_QUEUE, ALREADY_IN_GAME, UNKNOWN_ERROR, PLAYER_DICONNECTED, GAME_NOT_SUPPORTED, TALK_EXIST
}

enum GameState: Int {
    case GAME_STATE = 1000, GAME_RESULT = 503
}

// WS
enum GameSessionState: Int {
    case STATE_GAME = 1
    case STATE_EXECUTION
    case STATE_RATING
    case STATE_CALCULATIONS
    case STATE_SESSION_END
}

enum PlayerState: Int {
    case SEARCHING = 1
    case GAME_FOUND
    case PLAYING
    case DISCONNECTED
    case SESSION_CLOSED
}

enum TalkState: Int {
    case NEW = 1
    case TALKING
    case SEARCHING
    case DISCONNECTED
    case INVITATION_SENT
    case CLOSING = 11
    case CLOSED
}

func videostreamNamePattern(sessionID: Int?, playerID: Int?) -> String { // Example: s_4482_10
    guard let sessionID = sessionID else { return "" }
    guard let playerID = playerID else { return "" }
    return "s_\(sessionID)_\(playerID)";
}

func videoPreviewPattern(sessionID: Int, playerID: Int)-> String { // Example: s_4482_10
    return "s_\(sessionID)_\(playerID).jpg";
}

enum ULCLocalNotificationCategory: String {
    case NewFollower
    case NewMessage
}

func videostreamURIPattern(sessionID: Int, playerID: Int) -> String { // Example: rtmp://ulc.network/live/s_4482_10
    return Constants.VIDEOSTREAM_URL + videostreamNamePattern(sessionID, playerID: playerID);
}

enum FindTalkPartnerResult: Int {
    case OK = 1
    case WRONG_TALK_STATE
    case MAX_PARTNERS
    case UNKNOWN_ERROR
}

enum CancekFindTalkPartnerResult: Int {
    case OK = 1
    case NOT_IN_QUEUE
}

public let UnityGameMessageNotification: String = "UnityGameMessageNotification"
