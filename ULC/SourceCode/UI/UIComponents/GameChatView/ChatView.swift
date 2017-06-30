//
//  ChatView.swift
//  ULC
//
//  Created by Alexey on 7/21/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ChatView: UIView, NibLoadableView, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topPlaceholderView: UIView!
    @IBOutlet weak var chatTableViewFooter: UIView!
    @IBOutlet weak var spectatorsCount: UILabel!
    
	@IBOutlet weak var chatLabel: UILabel!
    //MARK:- private properties
    private var keyboardHeight          = CGFloat(0)
    private let gradientView            = UIView();
    private var messagesArray           = [WSChatMessageEntity]()
    let font                            = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
    var isKeyboardShow = false
    
    var tmpColors = Dictionary<Int, UIColor>()
    var isFirstElement = false
    var lastCount = 0
    
    var usernameColor = UIColor.blackColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(GameChatTableViewCell.self)
        tableView.separatorStyle = .SingleLine
        tableView.delegate = self
        tableView.dataSource = self
        topPlaceholderView.backgroundColor      = UIColor(named: .SessionLightGreyColor)
		configureViews()
    }

	func configureViews(){
		chatLabel.text = R.string.localizable.chat().uppercaseString
	}
    
    //MARK:- scrolling to tableView bottom
    func addNewMessage(message: WSChatMessageEntity) {
        messagesArray.append(message)
        tableView.reloadData()
        
        generateRandomColorWithId(message.sender.id)
        scrollToBottom();
    }
    
    func scrollToBottom(){
        if !self.messagesArray.isEmpty {
            let lastIndex = NSIndexPath(forRow: self.messagesArray.count - 1, inSection: 0)
            tableView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    func generateRandomColorWithId(id:Int) {
        var ids = [Int]()
        
        messagesArray.forEach { message in
            ids.append(message.sender.id)
        }
        
        if  Set(ids).count > 1 && Set(ids).count > lastCount {
            tmpColors[ids.last!] = UIColor().randomColor()
        } else if Set(ids).count == 1 {
            if !isFirstElement {
                tmpColors[ids.first!] = UIColor().randomColor()
            }
            isFirstElement = true
        }
        
        lastCount = Set(ids).count;
    }
    
    func refreshChatView() {
        messagesArray.removeAll()
        tableView.reloadData()
    }
    
    //MARK:- getting keyboard height
    func keyboardWillShow(notification: NSNotification) {
        isKeyboardShow = true
        
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        
        if keyboardHeight == 0 {
            keyboardHeight = keyboardRectangle.height + 45
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        isKeyboardShow = false
    }
    
    //MARK:- UITextViewDelegate methodes
    func textViewDidBeginEditing(textView: UITextView) {
        //  chatTableViewFooter.animateViewMoving(true, moveValue: keyboardHeight)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        //   chatTableViewFooter.animateViewMoving(false, moveValue: keyboardHeight)
    }
    
    func textViewDidChange(textView: UITextView) {
        // sendButton.enabled = !textView.text.isEmpty
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: GameChatTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.updateWithModel(messagesArray[indexPath.row], color: tmpColors)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messagesArray[indexPath.row]
        let height = message.text.heightWithConstrainedWidth(self.width - 20, font: font!)
        return height + 40 //40 - Optimal value for stable row height, someone's crutch
    }
}
