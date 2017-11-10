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
		guard let path = Bundle(for: LifetimeTracker.self).path(forResource: "", ofType: "bundle"), let bundle = Bundle(path: path) else {
			return self
		}
		return NSLocalizedString(self, bundle: bundle, comment: self)
	}
}
