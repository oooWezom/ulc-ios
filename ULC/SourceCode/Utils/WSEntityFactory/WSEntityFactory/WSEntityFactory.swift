//
//  WSProfileEntityFactory.swift
//  ULC
//
//  Created by Alex on 8/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

protocol EntityCreatable {
    func createEntity(dictionary: [String: AnyObject]) -> Mappable?;
}

class WSEntityFactory {
    
    let profileFactory = WSProfileEntityFactory();
    let sessionFactory = WSSessionEntityFactory();
    let talkFactory = WSTalkEntityFactory();

    func createEntity(dictinary: [String: AnyObject], channel: Channel) -> Mappable? {

        switch channel {
        case .Profile:
            return profileFactory.createEntity(dictinary);

        case .Session:
            return sessionFactory.createEntity(dictinary);

        case .Talk:
            return talkFactory.createEntity(dictinary)
        }
    }
}
