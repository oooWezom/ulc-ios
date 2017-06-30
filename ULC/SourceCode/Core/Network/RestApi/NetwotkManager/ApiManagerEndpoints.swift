//
//  ApiManagerEndpoints.swift
//  ULC
//
//  Created by Alex on 6/4/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import Moya
import SwiftKeychainWrapper

let endpointClosure = {(target: ApiManager) -> Endpoint<ApiManager> in
    
    var token = ""
    if let ulcToken = KeychainWrapper.stringForKey(Constants.keyChainValue) {
        token = ulcToken;
    }
    
    
    var httpFields = [String: String]()
    httpFields["Content-Type"] = "application/json";
    
    switch(target) {
        
    case .Profile,
         .SelfEvents,
         .UpdateProfile,
         .NewsFeed,
         .Following,
         .Followers,
         .Conversations,
         .Messages,
         .MessagesSince,
         .BlackList,
         .RemoveFromBlacklist,
         .LogOut,
         .AddToBlackList,
         .UpdateAllProfile,
         .ReportUser,
         .ProfilesSearch,
         .ProfilesParamsSearch,
         .Counters,
         .UpdatePassword,
         .EventsByID:
        
        httpFields[ApiManagerKey.token] = token;
        break;
        
    default:
        break;
        
    }
    
    let endpoint: Endpoint<ApiManager> = Endpoint<ApiManager>(URL: target.baseURL.URLByAppendingPathComponent(target.path).absoluteString,
                                                              sampleResponseClosure: {.NetworkResponse(200, target.sampleData)},
                                                              method: target.method,
                                                              parameters: target.parameters,
                                                              httpHeaderFields: httpFields)
    
    switch target.method {
    case .POST, .PUT:
        return endpoint.endpointByAddingParameterEncoding(.JSON);
    default:
        return endpoint;
    }
}

enum ApiManagerKey {

	static let email = "email";
	static let login = "login";
	static let password = "password";
	static let newPassword = "new_password";
	static let username = "username";
	static let token = "X-ULC-Token";
	static let sex = "sex";
	static let languages = "languages";
	static let dateOfBirth = "date_of_birth";
	static let offset = "offset";
	static let about = "about";
	static let blockMessages = "block_messages";
	static let disabled = "disabled";
	static let privateMode = "private";
	static let avatar = "avatar";
	static let removeAvatar = "remove_avatar";
	static let background = "background";
	static let removeBackground = "remove_background";
	static let filters = "filters";
	static let query = "query";
	static let response = "response";
	static let result = "result";
	static let id = "id";
	static let count = "count";
	static let key = "key";
}
