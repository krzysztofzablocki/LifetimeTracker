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
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: LifetimeTracker.self)
        #endif
        return NSLocalizedString(self, bundle: bundle, comment: self)
    }
}
