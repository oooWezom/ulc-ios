//
//  WSTalkChatMessageEntity.swift
//  ULC
//
//  Created by Vitya on 9/2/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class WSTalkChatMessageEntity: WSBaseTypeEntity, WSChatMessageEntity {
    
    var text    = ""
    var sender  = WSSenderEntity()
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map);
        text    <- map[MapperKey.text]
        sender  <- map[MapperKey.sender]
    }
    
    static func createWSTalkChatEntity(text: String, sender: TalkSessionsResponseEntity) -> WSTalkChatMessageEntity {
        guard let streamer = sender.streamer else {
            return WSTalkChatMessageEntity()
        }
        
        let talkChatMessage     = WSTalkChatMessageEntity()
        
        talkChatMessage.text    = text
        talkChatMessage.sender  = WSSenderEntity.getWSSenderEntity(streamer)
        
        return talkChatMessage
    }
    
    static func createWSTalkChatEntity(text: String, sender: UserEntity) -> WSTalkChatMessageEntity {
        
        let talkChatMessage     = WSTalkChatMessageEntity()
        let senderEntity        = WSSenderEntity()
        
        talkChatMessage.text    = text
        senderEntity.name       = sender.name
        senderEntity.id         = 0
        senderEntity.avatar     = sender.avatar
        senderEntity.level      = sender.level
        
        talkChatMessage.sender  = senderEntity
        
        return talkChatMessage
    }
}
