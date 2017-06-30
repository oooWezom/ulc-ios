//
//  CoordinatorFactory.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

protocol CoordinatorFactory: class {
    
    func createUserCoordinator(navController navController: UINavigationController?) -> Coordinator
    func createUserCoordinator() -> Coordinator

}
