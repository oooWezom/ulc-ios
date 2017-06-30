// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#elseif os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#endif

// swiftlint:disable operator_usage_whitespace
extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}
// swiftlint:enable operator_usage_whitespace

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum ColorName {
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#717277"></span>
  /// Alpha: 100% <br/> (0x717277ff)
  case ActivitySessionColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#7772bd"></span>
  /// Alpha: 100% <br/> (0x7772bdff)
  case AvatarExpColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  case CellBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffbf71"></span>
  /// Alpha: 100% <br/> (0xffbf71ff)
  case DoneButtonDisable
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff8f00"></span>
  /// Alpha: 100% <br/> (0xff8f00ff)
  case DoneButtonEnable
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e1e1e6"></span>
  /// Alpha: 100% <br/> (0xe1e1e6ff)
  case EventCellBackgound
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#d3d3d7"></span>
  /// Alpha: 100% <br/> (0xd3d3d7ff)
  case EventSeparatorLine
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff8f00"></span>
  /// Alpha: 100% <br/> (0xff8f00ff)
  case ForgotPasswordButtonNormal
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffbf71"></span>
  /// Alpha: 100% <br/> (0xffbf71ff)
  case ForgotPasswordButtonSelected
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff8f00"></span>
  /// Alpha: 100% <br/> (0xff8f00ff)
  case LoginButtonNormal
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffbf71"></span>
  /// Alpha: 100% <br/> (0xffbf71ff)
  case LoginButtonSelected
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e9e7e5"></span>
  /// Alpha: 100% <br/> (0xe9e7e5ff)
  case LoginTextFiledColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffe9cc"></span>
  /// Alpha: 100% <br/> (0xffe9ccff)
  case MessageSelectedColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#4f528f"></span>
  /// Alpha: 100% <br/> (0x4f528fff)
  case MessageViewColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff8f00"></span>
  /// Alpha: 100% <br/> (0xff8f00ff)
  case NavigationBarColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ebecee"></span>
  /// Alpha: 100% <br/> (0xebeceeff)
  case NewsFeedBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ff8f00"></span>
  /// Alpha: 100% <br/> (0xff8f00ff)
  case OkButtonNormal
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffbf71"></span>
  /// Alpha: 100% <br/> (0xffbf71ff)
  case OkButtonSelected
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#232740"></span>
  /// Alpha: 100% <br/> (0x232740ff)
  case SessionChatBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#2b2f4e"></span>
  /// Alpha: 100% <br/> (0x2b2f4eff)
  case SessionChatFooterBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#edeef0"></span>
  /// Alpha: 100% <br/> (0xedeef0ff)
  case SessionInfoBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f0f0f0"></span>
  /// Alpha: 100% <br/> (0xf0f0f0ff)
  case SessionLightGreyColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#898ca5"></span>
  /// Alpha: 100% <br/> (0x898ca5ff)
  case SessionSendViewColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#efeff4"></span>
  /// Alpha: 100% <br/> (0xefeff4ff)
  case TalkViewBackgroundColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e6e5eb"></span>
  /// Alpha: 100% <br/> (0xe6e5ebff)
  case TwoPlaySessionsBackgroungColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#9194a5"></span>
  /// Alpha: 100% <br/> (0x9194a5ff)
  case UnityButtonNormalColor
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#151727"></span>
  /// Alpha: 100% <br/> (0x151727ff)
  case UnityViewBackground
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffe9cc"></span>
  /// Alpha: 100% <br/> (0xffe9ccff)
  case UnreadMessageBackgroundColor

  var rgbaValue: UInt32 {
    switch self {
    case .ActivitySessionColor:
      return 0x717277ff
    case .AvatarExpColor:
      return 0x7772bdff
    case .CellBackgroundColor:
      return 0xffffffff
    case .DoneButtonDisable:
      return 0xffbf71ff
    case .DoneButtonEnable:
      return 0xff8f00ff
    case .EventCellBackgound:
      return 0xe1e1e6ff
    case .EventSeparatorLine:
      return 0xd3d3d7ff
    case .ForgotPasswordButtonNormal:
      return 0xff8f00ff
    case .ForgotPasswordButtonSelected:
      return 0xffbf71ff
    case .LoginButtonNormal:
      return 0xff8f00ff
    case .LoginButtonSelected:
      return 0xffbf71ff
    case .LoginTextFiledColor:
      return 0xe9e7e5ff
    case .MessageSelectedColor:
      return 0xffe9ccff
    case .MessageViewColor:
      return 0x4f528fff
    case .NavigationBarColor:
      return 0xff8f00ff
    case .NewsFeedBackgroundColor:
      return 0xebeceeff
    case .OkButtonNormal:
      return 0xff8f00ff
    case .OkButtonSelected:
      return 0xffbf71ff
    case .SessionChatBackgroundColor:
      return 0x232740ff
    case .SessionChatFooterBackgroundColor:
      return 0x2b2f4eff
    case .SessionInfoBackgroundColor:
      return 0xedeef0ff
    case .SessionLightGreyColor:
      return 0xf0f0f0ff
    case .SessionSendViewColor:
      return 0x898ca5ff
    case .TalkViewBackgroundColor:
      return 0xefeff4ff
    case .TwoPlaySessionsBackgroungColor:
      return 0xe6e5ebff
    case .UnityButtonNormalColor:
      return 0x9194a5ff
    case .UnityViewBackground:
      return 0x151727ff
    case .UnreadMessageBackgroundColor:
      return 0xffe9ccff
    }
  }

  var color: Color {
    return Color(named: self)
  }
}
// swiftlint:enable type_body_length

extension Color {
  convenience init(named name: ColorName) {
    self.init(rgbaValue: name.rgbaValue)
  }
}
// swiftlint:enable file_length
// swiftlint:enable line_length

