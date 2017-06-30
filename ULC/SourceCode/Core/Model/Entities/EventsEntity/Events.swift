//
//  Events.swift
//  ULC
//
//  Created by Alexey Shtanko on 2/28/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ObjectMapper

class Events: WSBaseEntity {

	var type = 0
	var typeDescription = ""
	var createdTimestamp = 0
	var createdDate = ""
	var owner:Owner?
	var talk = 0
	var category = 0
	var spectators = 0
	var likes = 0
	var exp = 0
	var parthers = [Partner]()

	required convenience init?(_ map: Map) {
		self.init()
	}

	override func mapping(map: Map) {
		super.mapping(map)
		type				<- map[MapperKey.type]
		typeDescription		<- map[MapperKey.type_desc]
		createdTimestamp	<- map[MapperKey.created_timestamp]
		createdDate			<- map[MapperKey.created_date]
		owner				<- map[MapperKey.owner]
		talk				<- map[MapperKey.talk]
		category			<- map[MapperKey.category]
		spectators			<- map[MapperKey.spectators]
		likes				<- map[MapperKey.likes]
		exp					<- map[MapperKey.exp]
		parthers			<- map[MapperKey.partners]
	}
}