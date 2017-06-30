//
//  SettingCell.swift
//  ULC
//
//  Created by Vitya on 7/21/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell, ReusableView, NibLoadableView  {
    
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var settingParameterLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        settingNameLabel.text = ""
        settingParameterLabel.text = ""
    }
    
    func updateVeiwWithData(settingName: String, settingParameter: String?) {
        settingNameLabel.text = settingName
        settingParameterLabel.text = settingParameter
    }
    
    func updateLanguagesWithModel(model: [LanguageEntity]) {
        var languagesName = [String]()
        
        for language in model {
            languagesName.append(language.displayName)
        }
        
        let languagesString = languagesName.joinWithSeparator(", ")
        settingParameterLabel.text = languagesString
    }
}
