//
//  WSGameChatMessageEntity.swift
//  ULC
//
//  Created by Alexey on 8/11/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

protocol WSChatMessageEntity: AnyObject {
    var text: String {get set}
    var sender: WSSenderEntity {get set}
}

class WSGameChatMessageEntity: WSBaseTypeEntity, WSChatMessageEntity {
    
    var text    = ""
    var sender  = WSSenderEntity()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        text    <- map[MapperKey.text]
        sender  <- map[MapperKey.user]
    }

    static func createWSGameChatEntity(text: String, sender: UserEntity) -> WSGameChatMessageEntity {

        let gameChatMessage     = WSGameChatMessageEntity()
        let senderEntity        = WSSenderEntity()

        gameChatMessage.text    = text
        senderEntity.name       = sender.name
        senderEntity.id         = 0

        gameChatMessage.sender  = senderEntity

        return gameChatMessage
    }
}
