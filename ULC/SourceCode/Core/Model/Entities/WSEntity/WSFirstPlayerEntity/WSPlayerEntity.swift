//
//  WSPlayerEntity.swift
//  ULC
//
import Foundation
import ObjectMapper

class WSPlayerEntity: WSBaseEntity {
    
    var name = ""
    var level = 0
    var exp = 0
    var avatar = ""
    var state = 0
    var state_desc = ""
    var games = [Int]()
    var languages = [Int]()
    var closed_session = false

    required init?(_ map: Map) { }
    
    override func mapping(map: Map) {
        super.mapping(map);
        name                <- map[MapperKey.name]
        level               <- map[MapperKey.level]
        exp                 <- map[MapperKey.exp]
        avatar              <- map[MapperKey.avatar]
        state               <- map[MapperKey.state]
        state_desc          <- map[MapperKey.state_desc]
        games               <- map[MapperKey.games]
        languages           <- map[MapperKey.languages]
        closed_session      <- map[MapperKey.closed_session]
    }
}
