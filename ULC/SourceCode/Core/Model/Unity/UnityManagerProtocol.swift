//
//  UnityManagerProtocol.swift
//  ULC
//
//  Created by Alexey Shtanko on 6/8/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

protocol UnityManagerProtocol {
    func onMessage(message: String)
}

extension UnityManagerProtocol {
    var unityRouterName: String { return "" }
}
