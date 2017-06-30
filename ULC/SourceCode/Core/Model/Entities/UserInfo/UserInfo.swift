//
//  UserInfo.swift
//  ULC
//
//  Created by Vitya on 7/27/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation

class UserInfo {
    var allLanguagesName = ""
    var languagesId = [Int]()
    var login = ""
    var privateAccount = false
    var sex = 0
    var accountStatusID = 0
    
    func updateDataWithModel(user: UserEntity) {
        login = user.login
        privateAccount = user.privateData
        sex = user.sex
        accountStatusID = user.accountStatusID
        
        languagesId = user.languages.map { $0.value }
    }
}
