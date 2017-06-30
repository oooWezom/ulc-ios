//
//  JSONError.swift
//  ULC
//
//  Created by Alex on 6/14/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

enum ULCError: ErrorType, CustomStringConvertible {
    case ERROR_DATA
    case ERROR_UNKNOWN
    case ERROR_AUTH_FAILED
    case ERROR_INVALID_PARAMETER
    case ERROR_WRONG_LOGIN_OR_PASSWORD
    case ERROR_LOGIN_EXISTS
    case ERROR_WRONG_EMAIL
    case ERROR_SEND_EMAIL
    case ERROR_INVALID_KEY(key: String)
    case ERROR_DUPLICATE_ENTRY
    case ERROR_USER_NOT_FOUND
    case ERROR_ACCOUNT_DISABLED
    case ERROR_ACCOUNT_PRIVATE
    case ERROR_BLACKLISTED
    case ERROR_DATA_CORRUPTION
    case ERROR_API_COMPATIBILITY
    
    var description: String {
        
        switch self {
            
        case .ERROR_UNKNOWN:
            return "Unknown error";
        case .ERROR_AUTH_FAILED:
            return "Authentication failure";
        case .ERROR_INVALID_PARAMETER:
            return "Invalid parameters";
        case .ERROR_WRONG_LOGIN_OR_PASSWORD:
            return "Wrong login or password"
        case .ERROR_LOGIN_EXISTS:
            return "Login exists";
        case .ERROR_WRONG_EMAIL:
            return "Wrong email";
        case .ERROR_SEND_EMAIL:
            return "Failure send email";
        case .ERROR_INVALID_KEY (let key):
            return "Invalid key: \(key)";
        case .ERROR_DUPLICATE_ENTRY:
            return "Duplicate entry";
        case .ERROR_USER_NOT_FOUND:
            return "User doesn't exist";
        case .ERROR_ACCOUNT_DISABLED:
            return "Account was disabled";
        case .ERROR_ACCOUNT_PRIVATE:
            return "Account is private";
        case .ERROR_BLACKLISTED:
            return "You are in blacklist";
        case .ERROR_DATA_CORRUPTION:
            return "Data is corrupted";
        case .ERROR_API_COMPATIBILITY:
            return "API version not supported, consider updating your client";
            
        default:
            return "Error fetch data from server.";
        }
    }
    
    static func error(errorCode: Int, key: String = "") -> ULCError {
        switch errorCode {
        case 0:
            return ERROR_DATA;
        case 2:
            return ERROR_AUTH_FAILED;
        case 3:
            return ERROR_INVALID_PARAMETER;
        case 4:
            return ERROR_WRONG_LOGIN_OR_PASSWORD;
        case 5:
            return ERROR_LOGIN_EXISTS;
        case 6:
            return ERROR_WRONG_EMAIL;
        case 7:
            return ERROR_SEND_EMAIL;
        case 8:
            return ERROR_INVALID_KEY(key: key);
        case 9:
            return ERROR_DUPLICATE_ENTRY;
        case 10:
            return ERROR_USER_NOT_FOUND;
        case 11:
            return ERROR_ACCOUNT_DISABLED;
        case 12:
            return ERROR_ACCOUNT_PRIVATE;
        case 13:
            return ERROR_BLACKLISTED;
        case 14:
            return ERROR_DATA_CORRUPTION;
        case 15:
            return ERROR_API_COMPATIBILITY;
        default:
            return ERROR_UNKNOWN;
        }
    }
}
