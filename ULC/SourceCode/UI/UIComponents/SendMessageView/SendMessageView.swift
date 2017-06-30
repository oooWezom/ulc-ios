//
//  SendMessageView.swift
//  ULC
//
//  Created by Alexey on 10/18/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import SnapKit
import UIKit

protocol MessageDelegate{
    
}

class SendMessageView:UIView, UITextViewDelegate {
    
    var messageTextView = UITextView()
    var sendMessageButton = UIButton()
    var sendMessagePlaceholderView = UIView()
    
    init() {
        super.init(frame: CGRectZero)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func addCustomView() {
        self.backgroundColor = UIColor.whiteColor()
        addSubview(sendMessagePlaceholderView)
        sendMessagePlaceholderView.addSubview(messageTextView)
        sendMessagePlaceholderView.addSubview(sendMessageButton)
        messageTextView.delegate = self
        
        messageTextView.backgroundColor = UIColor(named: .SessionSendViewColor)
        
        sendMessageButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        sendMessageButton.enabled = false
        
        sendMessageButton.setTitle(R.string.localizable.send(), forState: .Normal)
        
        
        sendMessageButton.titleLabel?.font = UIFont.systemFontOfSize(13.0)
        messageTextView.textColor = UIColor.whiteColor()
        
        sendMessagePlaceholderView.backgroundColor  = UIColor(named: .SessionSendViewColor) //SessionSendViewColor
    }
    
    func textViewDidChange(textView: UITextView) {
        sendMessageButton.enabled = !textView.text.isEmpty
        sendMessageButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        
        sendMessagePlaceholderView.snp_remakeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(5).priority(250)
            make.left.equalTo(self).offset(5).priority(250)
            make.right.equalTo(self).offset(-5).priority(250)
            make.bottom.equalTo(self).offset(-5).priority(250)
        }
        
        sendMessageButton.snp_remakeConstraints{
            (make)->Void in
            make.right.equalTo(sendMessagePlaceholderView).offset(-5).priority(250)
            make.centerY.equalTo(sendMessagePlaceholderView)
        }
        
        messageTextView.snp_remakeConstraints{
            (make)->Void in
            make.top.equalTo(sendMessagePlaceholderView)
            make.left.equalTo(sendMessagePlaceholderView)
            make.bottom.equalTo(sendMessagePlaceholderView)
            make.right.equalTo(sendMessageButton.snp_left).offset(-5).priority(250)
        }
    }
    
    func resetConstraints(){
        sendMessagePlaceholderView.snp_remakeConstraints{
            (make)->Void in
             make.top.left.width.height.equalTo(0)
        }
        
        sendMessageButton.snp_remakeConstraints{
            (make)->Void in
             make.top.left.width.height.equalTo(0)
        }
        
        messageTextView.snp_remakeConstraints{
            (make)->Void in
            make.top.left.width.height.equalTo(0)
        }
    }
}
