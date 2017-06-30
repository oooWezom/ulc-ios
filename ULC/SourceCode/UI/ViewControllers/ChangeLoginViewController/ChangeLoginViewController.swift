//
//  ChangeLoginViewController.swift
//  ULC
//
//  Created by Vitya on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class ChangeLoginViewController: UIViewController {

    @IBOutlet weak var newLoginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var changeLoginLabel: UILabel!
	@IBOutlet weak var newLoginLabel: UILabel!
	@IBOutlet weak var passwordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    func configureView() {
        self.title = R.string.localizable.login() //#MARK localized

        let rightButton = UIBarButtonItem(title: R.string.localizable.done(), style: .Plain, target: self, action: #selector(doneButtonTouch)); //#MARK localized
        rightButton.tintColor = UIColor(named: .DoneButtonEnable)
        
        self.navigationItem.rightBarButtonItem = rightButton;
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.Plain, target:nil, action:nil)
        self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)

		changeLoginLabel.text = R.string.localizable.change_login().uppercaseString
		newLoginLabel.text = R.string.localizable.new_login()
		passwordLabel.text = R.string.localizable.password()

    }
    
    func doneButtonTouch() {
        
    }

}
