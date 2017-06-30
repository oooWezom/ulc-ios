//
//  ChooseCategoryTableView.swift
//  ULC
//
//  Created by Vitya on 7/8/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol ChooseCategoryDelegate:class {
    func selectedCategory(categoryId: Int)
}

class ChooseCategoryTableView: UIView, NibLoadableView, UITableViewDataSource, UITableViewDelegate {
    
	@IBOutlet weak var choosenCategotyLabel: UILabel!
    @IBOutlet weak var categoryTableVeiw: UITableView!
    
    //Mark - Private properties
    private var talkCategory = [TalkCategory]()
    
    private let categoryViewModel = CategoryViewModel()
    
    weak var delegate: ChooseCategoryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    private func configure() {
        configureTableView();
        configureDataBase();
    }
    
    private func configureTableView() {
        self.roundedView(false, borderColor: nil, borderWidth: nil, cornerRadius: 10);
        
        categoryTableVeiw.register(CategoryTableViewCell.self)
        categoryTableVeiw.separatorStyle = .None
        categoryTableVeiw.delegate = self
        categoryTableVeiw.dataSource = self
		choosenCategotyLabel.text = R.string.localizable.choosen_category()
    }
    
    func configureDataBase() {
        if let category = categoryViewModel.fetchTalkCategoryFromDB() {
            talkCategory.removeAll();
            talkCategory = category
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talkCategory.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        cell.updateViewWithModel(talkCategory[indexPath.row]);
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let categoriId = self.talkCategory[indexPath.row].id
        delegate?.selectedCategory(categoriId)
    }
}
