//
//  TalkSessionsResponse.swift
//  ULC
//
//  Created by Vitya on 8/22/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class TalkSessionsResponseEntity: WSBaseEntity {
    
    var category = 0
    var state = 0
    var state_desc = ""
    var likes = 0
    var spectators = 0
    var name = ""
    var videoUrl = ""

    var streamer: WSStreamerEntity?
    var linked: [LinkedEntity]?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        category        <- map[MapperKey.category]
        state           <- map[MapperKey.state]
        state_desc      <- map[MapperKey.state_desc]
        likes           <- map[MapperKey.likes]
        spectators      <- map[MapperKey.spectators]
        name            <- map[MapperKey.name]
        videoUrl        <- map[MapperKey.videoUrl]
        streamer        <- map[MapperKey.streamer]
        linked          <- map[MapperKey.linked]
    }
    
    static func createTalkSessionsResponseEntity(model: WSNotifyTalkEntity) -> TalkSessionsResponseEntity {
        
        let sessionResponse             = TalkSessionsResponseEntity()
        
        sessionResponse.streamer        = model.talk?.streamer
        sessionResponse.linked          = model.talk?.linked
        
        if let talk = model.talk {
            sessionResponse.id          = talk.id
            sessionResponse.category    = talk.category
            sessionResponse.state       = talk.state
            sessionResponse.state_desc  = talk.state_desc
            sessionResponse.likes       = talk.likes
            sessionResponse.spectators  = talk.spectators
            sessionResponse.videoUrl    = talk.videoUrl;
        }
        return sessionResponse
    }
    
    func addNewLinkedEntity(model: TalkSessionsResponseEntity) {
        
        let linkedEntity = LinkedEntity()
        linkedEntity.id         = model.id
        linkedEntity.category   = model.category
        linkedEntity.state      = model.state
        linkedEntity.likes      = model.likes
        linkedEntity.spectators = model.spectators
        linkedEntity.streamer   = model.streamer
        
        self.linked?.removeAll()
        self.linked?.append(linkedEntity)
    }
}
