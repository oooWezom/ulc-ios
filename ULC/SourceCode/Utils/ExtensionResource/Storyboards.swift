// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return storyboard().instantiateInitialViewController()!
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewControllerWithIdentifier(self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func performSegue<S: StoryboardSegueType where S.RawValue == String>(segue: S, sender: AnyObject? = nil) {
    performSegueWithIdentifier(segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    case ConfirmRegistrationViewControllerScene = "ConfirmRegistrationViewController"
    static func instantiateConfirmRegistrationViewController() -> ConfirmRegistrationViewController {
      return StoryboardScene.Main.ConfirmRegistrationViewControllerScene.viewController() as! ConfirmRegistrationViewController
    }

    case ContainerViewControllerScene = "ContainerViewController"
    static func instantiateContainerViewController() -> ContainerViewController {
      return StoryboardScene.Main.ContainerViewControllerScene.viewController() as! ContainerViewController
    }

    case ForgotPasswordViewControlerScene = "ForgotPasswordViewControler"
    static func instantiateForgotPasswordViewControler() -> ForgotPasswordViewControler {
      return StoryboardScene.Main.ForgotPasswordViewControlerScene.viewController() as! ForgotPasswordViewControler
    }

    case LanguageViewControllerScene = "LanguageViewController"
    static func instantiateLanguageViewController() -> LanguageViewController {
      return StoryboardScene.Main.LanguageViewControllerScene.viewController() as! LanguageViewController
    }

    case LoginViewControllerScene = "LoginViewController"
    static func instantiateLoginViewController() -> LoginViewController {
      return StoryboardScene.Main.LoginViewControllerScene.viewController() as! LoginViewController
    }

    case MenuViewControllerScene = "MenuViewController"
    static func instantiateMenuViewController() -> MenuViewController {
      return StoryboardScene.Main.MenuViewControllerScene.viewController() as! MenuViewController
    }

    case RegisterViewControllerScene = "RegisterViewController"
    static func instantiateRegisterViewController() -> RegisterViewController {
      return StoryboardScene.Main.RegisterViewControllerScene.viewController() as! RegisterViewController
    }
  }
}

struct StoryboardSegue {
}

