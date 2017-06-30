//
//  GameChatTableViewCell.swift
//  ULC
//
//  Created by Alexey on 7/20/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class GameChatTableViewCell: UITableViewCell, ReusableView, NibLoadableView {
  
  @IBOutlet weak var messageLabel: UILabel!
  
  var usernameColor = UIColor.blackColor()
  
  func updateWithModel(model: AnyObject, color:AnyObject){
    
    guard let tmpColors = color as? Dictionary<Int, UIColor> else {
      return
    }
    
    guard let model = model as? WSChatMessageEntity else {
      return
    }
    
    tmpColors.forEach { [unowned self] (id, name) in
      if id == model.sender.id {
        self.usernameColor = name
      }
    }
    
    let tmpString = model.sender.name + ": " + model.text
    
    let string = NSMutableAttributedString(string: tmpString)
    
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .ByWordWrapping
    
    let attributes: [String: AnyObject] = [
      NSFontAttributeName: messageLabel.font,
      NSParagraphStyleAttributeName: style
    ]
    
    string.addAttribute(NSForegroundColorAttributeName, value: usernameColor, range: NSRange(location: 0, length: model.sender.name.characters.count + 1))
    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSRange(location: model.sender.name.characters.count + 2, length: model.text.characters.count))
    let fullStringRange = (model.sender.name.characters.count + 2 + model.text.characters.count)
    string.addAttributes(attributes, range: NSRange(location: 0,length: fullStringRange))
    messageLabel.attributedText = string
    messageLabel.textAlignment = .Natural
    
  }
    
    override func updateConstraints() {
        super.updateConstraints()
        
    }
}
