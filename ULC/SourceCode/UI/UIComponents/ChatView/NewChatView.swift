//
//  NewChatView.swift
//  ULC
//
//  Created by Alexey on 11/24/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class NewChatView: UIView {
  
  var topPlaceholderView  = UIView()
  var spectatorCountLabel = UILabel()
  var usersCountImageView = UIImageView()
  var chatTitleLabel      = UILabel()
  var topSeparatorView    = UIView()
  var tableView           = UITableView()
  var chatFooterView      = UIView()

  override func awakeFromNib() {
    super.awakeFromNib()
    configureViews()
    needsUpdateConstraints()
  }
  
  func configureViews(){
    addSubview(topPlaceholderView)
    topPlaceholderView.addSubview(spectatorCountLabel)
    topPlaceholderView.addSubview(usersCountImageView)
    topPlaceholderView.addSubview(chatTitleLabel)
    addSubview(topSeparatorView)
    addSubview(tableView)
    addSubview(chatFooterView)
    
    topPlaceholderView.backgroundColor      = UIColor(named: .SessionLightGreyColor)
    chatTitleLabel.textColor = .blackColor()
  }
  
  override func updateConstraints() {
    super.updateConstraints()
    
    let topPlaceholderWidth = self.width * 0.1
    
    topPlaceholderView.snp_remakeConstraints{
      (make) in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.width.equalTo(topPlaceholderWidth)
    }
    
    usersCountImageView.snp_remakeConstraints{
      (make) in
      make.right.equalToSuperview()
      make.height.equalTo(20)
      make.width.equalTo(15)
      make.centerY.equalToSuperview()
    }
    
    spectatorCountLabel.snp_remakeConstraints{
      (make) in
      make.right.equalTo(usersCountImageView.snp_left).offset(-5)
      make.centerY.equalTo(usersCountImageView)
    }
    
    chatTitleLabel.snp_remakeConstraints{
      (make) in
      make.left.equalToSuperview().offset(5)
      make.centerY.equalToSuperview()
    }
    
    topSeparatorView.snp_remakeConstraints{
      (make) in
      make.top.equalTo(topPlaceholderView.snp_bottom)
      make.height.equalTo(2)
      make.left.right.equalToSuperview()
    }
    
    chatFooterView.snp_remakeConstraints{
      (make) in
      make.height.equalTo(40)
      make.bottom.left.right.equalToSuperview()
    }
    
    tableView.snp_remakeConstraints{
      (make) in
      make.top.equalTo(topSeparatorView.snp_bottom)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(chatFooterView)
    }
  }
}