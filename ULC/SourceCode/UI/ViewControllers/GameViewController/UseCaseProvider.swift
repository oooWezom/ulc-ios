//
//  UseCaseProvider.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation

protocol UseCaseProvider {
    func makeGamePlayerUseCase(delegate:Playable) -> PlayerUseCase
}