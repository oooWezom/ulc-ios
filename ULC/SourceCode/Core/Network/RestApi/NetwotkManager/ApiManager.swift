//
//  ApiManager.swift
//  ULC
//
//  Created by Alex on 6/4/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup
private func JSONResponseDataFormatter(data: NSData) -> NSData {
    do {
        let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        let prettyData = try NSJSONSerialization.dataWithJSONObject(dataAsJSON, options: .PrettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it cant be serialized
    }
}

// MARK: - Provider support
private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public enum ApiManager {
    case Login(String, String)
    case Registration(String, String, String, String, Int, [Int])
    case LanguagesList()
    case Profile(Int)
    case RestorePassword(String)
    case SelfEvents(Int, Int)
    case UpdateAllProfile(String, Int, String, [Int], Bool, Bool, Bool)
    case UpdateProfile(String, String)
    case NewsFeed(Int, Int, Int)
    case Following(Int, String, Int)
    case Followers(Int, String, Int)
    case Conversations
    case ActiveGameSessions()
    case TalkCategory()
    case Messages(Int, Int)
    case MessagesSince(Int, Int)
    case BlackList(Int)
    case RemoveFromBlacklist(Int)
    case LogOut()
    case AddToBlackList(Int)
    case ReportUser(Int)
    case ProfilesSearch();
    case ProfilesParamsSearch(String);
    case TwoPlayPreview(String);
    case ActiveTalkSession(Int)
    case Counters()
    case ApiVersion
    case CheckApiVersion(Int)
    case UpdatePassword(String, String)
    case TalkByGroup(Int, Int)
	case EventsByID(Int)
	case ConfirmRestorePassword(String, String)
	case ConfirmNewAccount(String)
}

extension ApiManager: TargetType {
    
    public var baseURL: NSURL {return NSURL(string:Constants.BASE_URL)!}
    
    public var method: Moya.Method {
        switch self {
            
        case .Login, .Registration, .RestorePassword, .LogOut, .AddToBlackList, .ReportUser, .ConfirmRestorePassword, .ConfirmNewAccount:
            return .POST
            
        case .UpdateProfile, UpdateAllProfile, UpdatePassword:
            return .PUT
            
        case .RemoveFromBlacklist:
            return .DELETE
            
        default :
            return .GET
        }
    }
    
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/api/auth/login"
        case .Registration(_, _, _, _, _, _):
            return "/api/auth/register"
        case .LanguagesList(_):
            return "api/database/languages"
        case .Profile(let userId):
            return "/api/profiles/" + String(userId)
        case .RestorePassword(_):
            return "/api/auth/restore/password"
        case .SelfEvents(let userId, _):
            return "/api/events/\(String(userId))/self";
        case .UpdateProfile:
            return "/api/profiles";
        case .NewsFeed(let userID, _, _):
            return "/api/events/\(String(userID))/self";
        case .Followers(let userID, _, _):
            return "/api/followers/\(String(userID))"
        case .Following(let userID, _, _):
            return "/api/following/\(String(userID))"
        case .ActiveGameSessions(_):
            return "api/games/active"
        case .TalkCategory():
            return "/api/database/categories/talk"
        case .Conversations:
            return "/api/conversations"
        case .Messages(_, _):
            return "/api/messages";
        case .MessagesSince(let messageID, _):
            return "/api/messages/since/\(String(messageID))";
        case .BlackList(_):
            return "/api/blacklist"
        case .RemoveFromBlacklist(let userID):
            return "/api/blacklist/\(String(userID))"
        case .LogOut(_):
            return "/api/auth/logout"
        case .AddToBlackList(let userID):
            return "/api/blacklist/\(String(userID))"
        case .UpdateAllProfile(_):
            return "/api/profiles";
        case .ReportUser(let userID):
            return "/api/reports/\(String(userID))"
        case .ProfilesSearch:
            return "/api/profiles";
        case .ProfilesParamsSearch(_):
            return "/api/profiles";
        case .TwoPlayPreview(let previewName):
            return "preview/" + previewName
        case .ActiveTalkSession(_):
            return "/api/talks/"
        case .Counters():
            return "/api/counters/"
        case .UpdatePassword(_, _):
            return "/api/auth/password/update"
        case .ApiVersion:
            return "/api/version"
        case .CheckApiVersion(let version):
            return "/api/version/\(String(version))";
		case .EventsByID(let id):
			return "/api/events/\(id)"

        case .TalkByGroup(let groupId, _):
            return "/api/talks/\(String(groupId))";

		case .ConfirmRestorePassword(_, _):
			return "/api/auth/confirm/restore/password"

		case .ConfirmNewAccount(_):
			return "/api/auth/confirm/account"
			
        }
    }
    
    public var sampleData: NSData {
        switch self {
        default:
            return NSData()
        }
    }
    
    public var parameters: [String:AnyObject]? {
        
        switch self {
            
        case .Login(let userName, let userPassword):
            let value = [ApiManagerKey.login: userName, ApiManagerKey.password: userPassword];
            return value;
            
        case .Registration(let login, let userName, let userPassword, let dateOfBirth, let sex, let languages):
            let value = [ApiManagerKey.login: login, ApiManagerKey.username: userName, ApiManagerKey.password: userPassword, ApiManagerKey.dateOfBirth: dateOfBirth, ApiManagerKey.sex: sex, ApiManagerKey.languages: languages];
            return value as? [String:AnyObject];
            
        case .SelfEvents(_, let offset):
            let value = [ApiManagerKey.offset: offset]
            return value
            
        case .RestorePassword(let email):
            let value = [ApiManagerKey.email: email]
            return value;
            
        case .UpdateAllProfile(let userName, let sex, let about, let languages, let blockMessages, let blockAccount, let privateData):
            let value = [ApiManagerKey.username: userName, ApiManagerKey.sex: sex, ApiManagerKey.about: about, ApiManagerKey.languages: languages, ApiManagerKey.blockMessages: blockMessages, ApiManagerKey.disabled: blockAccount, ApiManagerKey.privateMode: privateData]
            return value as? [String:AnyObject];
            
        case .UpdateProfile(let avatarURLData, let backgroundURLData):
            var value = [String: AnyObject]();
            if !avatarURLData.isEmpty {
                value[ApiManagerKey.avatar] = "data:image/png;base64," + avatarURLData;
            }
            if !backgroundURLData.isEmpty {
                value[ApiManagerKey.background] = "data:image/png;base64," + backgroundURLData;
            }
            return value;
            
        case .NewsFeed(_, let offset, let filters):
            let value = [ApiManagerKey.offset: offset, ApiManagerKey.filters: filters]
            return value
            
        case .Following(_, let query, let offset):
            let value = [ApiManagerKey.query: query, ApiManagerKey.offset: offset]
            return value as? [String : AnyObject];
            
        case .Followers(_, let query, let offset):
            let value = [ApiManagerKey.query: query, ApiManagerKey.offset: offset]
            return value as? [String : AnyObject];
            
        case .Messages(let userId, let offset):
            let value = [ApiManagerKey.id: userId, ApiManagerKey.offset: offset, ApiManagerKey.count: 100];
            return value
            
        case .MessagesSince(let userId, let offset):
            let value = [ApiManagerKey.id: userId, ApiManagerKey.offset: offset, ApiManagerKey.count: 100];
            return value
            
        case .BlackList(let offset):
            let value = [ApiManagerKey.offset: offset, ApiManagerKey.count: 100]
            return value
            
        case .ProfilesParamsSearch(let params):
            let value = [ApiManagerKey.query : params];
            return value;
            
        case .UpdatePassword(let password, let newPassword):
			let value = [ApiManagerKey.password: password, ApiManagerKey.newPassword:newPassword]
            return value
            
        case .ActiveTalkSession(let offset):
            let value = [ApiManagerKey.count: 100, ApiManagerKey.offset: offset];
            return value

        case .TalkByGroup(_, let offset):
            let value = [ApiManagerKey.count: 100, ApiManagerKey.offset: offset];
            return value

		case .ConfirmRestorePassword(let key, let password):
			let value = [ApiManagerKey.key: key, ApiManagerKey.password: password]
			return value

		case .ConfirmNewAccount(let key):
			let value = [ApiManagerKey.key: key]
			return value

        default:
            return nil
        }
    }
}

#if DEBUG
    let plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]
    let networkProvider = MoyaProvider<ApiManager>(plugins: plugins, endpointClosure: endpointClosure);
#else
    let networkProvider = MoyaProvider<ApiManager>(plugins: [], endpointClosure: endpointClosure);
#endif

