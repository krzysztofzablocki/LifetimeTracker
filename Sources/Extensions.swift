//
//  Extensions.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 23.10.17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

internal extension String {

    var lt_localized: String {
        let bundle = Bundle(for: LifetimeTracker.self)
        let resourcePath = bundle.path(forResource: "LifetimeTracker", ofType: "bundle")!
        let resourceBundle = Bundle(path: resourcePath)!
        return NSLocalizedString(self, bundle: resourceBundle, comment: self)
    }
}
