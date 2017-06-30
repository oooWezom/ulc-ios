//
//  PlayerUseCase.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/27/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

protocol PlayerUseCase {
    func view(path:String) -> UIView
    func reconnectPlayer(withPath path:String)
    func releasePlayer()
    func destroy()
}

