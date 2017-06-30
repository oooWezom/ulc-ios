//
//  Router.swift
//  ULC
//
//  Created by Alex on 6/7/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

typealias RouterHandler = () -> ()

protocol Router: class {
    
    weak var rootController: ULCNavigationViewController? { get }
    
    func present(controller: UIViewController?)
    func present(controller: UIViewController?, animated: Bool)
    func present(controller: UIViewController?, animated: Bool, completition: RouterHandler)
    
    func push(controller: UIViewController?)
    func push(controller: UIViewController?, animated: Bool)
    
    func popController()
    func popController(animated: Bool)
    
    func dismissController()
    func dismissController(animated: Bool)
    func dismissController(animated: Bool, completition: RouterHandler)
    
    func openOnMenu(controller: UIViewController?)
    
    func changeRootViewController(controller: UIViewController);
    func openAlertViewController(alertViewController: UIAlertController);
}
