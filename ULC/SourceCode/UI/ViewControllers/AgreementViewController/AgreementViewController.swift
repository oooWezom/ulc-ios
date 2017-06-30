//
//  AgreementViewController.swift
//  ULC
//
//  Created by Alexey Shtanko on 3/1/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

class AgreementViewController: UIViewController {

	@IBOutlet weak var webView: UIWebView!

	
    override func viewDidLoad() {
        super.viewDidLoad()

		configureView()
		loadHTML()
    }

	func configureView(){

		self.title = R.string.localizable.agreement_settings_placeholder()

		self.navigationController?.navigationBar.tintColor = UIColor(named: .NavigationBarColor)
		self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
		let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView
		statusBar!.backgroundColor = UIColor.whiteColor()
	}

	func loadHTML() {

		let preferredLanguage = NSLocale.preferredLanguages()[0] as String
		var fileName:String?

		if preferredLanguage == "ru-UA" || preferredLanguage == "ru"  {
			fileName = "agreement_ru"
		} else {
			fileName = "agreement_eu"
		}

		if let data = NSBundle.mainBundle().pathForResource(fileName, ofType: "html", inDirectory: "html"){
			do{
				let fileHtml = try NSString(contentsOfFile: data, encoding: NSUTF8StringEncoding)
				webView.loadHTMLString(fileHtml as String, baseURL: nil)
			} catch {

			}
		}

	}
}
