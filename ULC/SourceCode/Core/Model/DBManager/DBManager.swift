//
//  DBManager.swift
//  ULC
//
//  Created by Alexey on 7/25/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import RealmSwift

class RealmResultsCache {

	let realm = try! Realm()
    
	func fetchObjects(type: Object.Type, query: String) -> Results<Object> {
		do {
			let predicate = NSPredicate(format: query)
			return realm.objects(type).filter(predicate)
		}
	}

	func updateWithKey<T: Object>(type: T.Type, value: [String: AnyObject], isUpdate: Bool) {
		do {
			try! realm.write {
				realm.create(type, value: value, update: isUpdate)
			}
		}
	}

	func updateOptionally<T: Object>(type: T.Type, value: AnyObject, key: String) {
		do {
			try! realm.write {
				let object = get(type)
				object.first?.setValue(value, forKey: key)
			}
		}
	}

	func deleteAll() {
		do {
			try! realm.write {
				realm.deleteAll()
			}
		}
	}

	func insert(obj: Object) {
		do {
			try! realm.write {
				realm.add(obj)
			}
		}
	}

	func delete(obj: Object) {
		do {
			try! realm.write {
				realm.delete(obj)
			}
		}
	}

	func update(obj: Object, isUpdate: Bool = true) {
		do {
			try! realm.write {
				realm.add(obj, update: isUpdate)
				// realm.cancelWrite()
			}

		}
	}

	func get<T: Object>(type: T.Type) -> Results<T> {
		do {
			return realm.objects(type)
		}
	}

	func getArray<T: Object>(type: T.Type) -> Array<T> {
		do {
			let realm = try! Realm()
			let array = Array(realm.objects(T))
			return array
		}
	}

}
