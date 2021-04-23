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
        let resourceBundle = bundle
            .path(forResource: "LifetimeTracker", ofType: "bundle")
            .map { Bundle(path: $0) ?? bundle } ?? bundle
        return NSLocalizedString(self, bundle: resourceBundle, comment: self)
    }
}
