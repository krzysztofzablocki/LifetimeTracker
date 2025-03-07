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
        Bundle.stringBundle.localizedString(forKey: self, value: self, table: nil)
    }
}
