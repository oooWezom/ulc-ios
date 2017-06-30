//
//  ApiCheckProtocol.swift
//  ULC
//
//  Created by Cruel Ultron on 2/23/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol VersionApiCheckable {
    func getCurrentApiVersion() -> SignalProducer<ULCApiValue, ULCError>;
    func checkApiVersion(let currentVersion: Int) -> SignalProducer<ULCApiValue, ULCError>;
}

extension VersionApiCheckable {
    func getCurrentApiVersion() -> SignalProducer<ULCApiValue, ULCError> {
        return SignalProducer { observer, disposable in
            networkProvider.request(.ApiVersion, completion: { result in
                switch (result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            if  let status = json[MapperKey.result] as? String where status == "ok",
                                let version = json[MapperKey.version] as? Int {
                                if version != Constants.CURRENT_API_VERSION {
                                    observer.sendNext(.OLD_VERSION);
                                } else {
                                    observer.sendNext(.CURRENT_VERSION);
                                }
                            }
                        }
                    } catch {
                        observer.sendFailed(ULCError.ERROR_DATA);
                    }
                    break;
                case .Failure(_):
                    observer.sendFailed(ULCError.ERROR_DATA);
                    break;
                }
            });
        }
    }
    
    func checkApiVersion(let currentVersion: Int) -> SignalProducer<ULCApiValue, ULCError> {
        return SignalProducer { observer, disposable in
            networkProvider.request(.CheckApiVersion(currentVersion), completion: { result in
                switch (result) {
                case let .Success(response):
                    do {
                        if let json: [String:AnyObject] = try response.mapJSON() as? [String:AnyObject] {
                            if  let status = json[MapperKey.result] as? String where status == "ok",
                                let _ = json[MapperKey.version] as? Int {
                                let _ = NSUserDefaults.standardUserDefaults().integerForKey(MapperKey.version);
                            }
                        }
                    } catch {}
                    break;
                case .Failure(_):
                    break;
                }
            });
        }
    }
}
