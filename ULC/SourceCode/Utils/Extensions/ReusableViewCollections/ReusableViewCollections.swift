//
//  ReusableView.swift
//
//  Created by Alex on 4/6/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit

//  MARK App's cell Protocols
enum RadioButtonViewType: Int {
	case Unselected = 0
	case Selected
}

protocol RadioBehaviourProtocol {
	func updateRadioView(type: RadioButtonViewType)
}

protocol ReactiveBindViewProtocol: class {
	func updateViewWithModel(model: AnyObject?)
}

// MARK ReuseIdentifier
protocol ReusableView: class {
	static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
	static var defaultReuseIdentifier: String {
		return NSStringFromClass(self)
	}
}

//MARK NibLoadableView
protocol NibLoadableView: class {
	static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
	static var nibName: String {
		return NSStringFromClass(self).componentsSeparatedByString(".").last!
	}
}

//UICollectionView extension
extension UICollectionView {

	func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
		registerClass(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
	}

	func register<T: UICollectionViewCell where T: ReusableView, T: NibLoadableView>(_: T.Type) {
		let bundle = NSBundle(forClass: T.self)
		let nib = UINib(nibName: T.nibName, bundle: bundle)

		registerNib(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
	}

	func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView> (forIndexPath indexPath: NSIndexPath) -> T {
		guard let cell = dequeueReusableCellWithReuseIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
			fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
		}
		return cell
	}
}

//UICollectionView extension
extension UITableView {

	func register<C: UITableViewCell where C: ReusableView>(_: C.Type) {
		registerClass(C.self, forCellReuseIdentifier: C.defaultReuseIdentifier)
	}

	func register<C: UITableViewCell where C: ReusableView, C: NibLoadableView>(_: C.Type) {
		let bundle = NSBundle(forClass: C.self)
		let nib = UINib(nibName: C.nibName, bundle: bundle)
		registerNib(nib, forCellReuseIdentifier: C.defaultReuseIdentifier)
	}

	func dequeueReusableCell<C: UITableViewCell where C: ReusableView> (forIndexPath indexPath: NSIndexPath) -> C {
		guard let cell = dequeueReusableCellWithIdentifier(C.defaultReuseIdentifier, forIndexPath: indexPath) as? C else {
			fatalError("Could not dequeue cell with identifier: \(C.defaultReuseIdentifier)")
		}
		return cell
	}
}

protocol UIViewNibLoadable {}
extension UIView : UIViewNibLoadable {}

extension UIViewNibLoadable where Self : UIView {
    static func instanciateFromNib() -> Self {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil).first as! Self
    }
}
