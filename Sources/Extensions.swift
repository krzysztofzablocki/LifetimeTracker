//
//  Extensions.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 23.10.17.
//

import Foundation

internal extension UIView {

	class var lt_nibInOwnBundle: UINib {
		return UINib(nibName: "\(self)", bundle: Bundle(for: self))
	}
}

internal extension String {

	var lt_localized: String {
		guard let path = Bundle(for: DashboardViewController.self).path(forResource: "", ofType: "bundle"), let bundle = Bundle(path: path) else {
			return self
		}
		return NSLocalizedString(self, bundle: bundle, comment: self)
	}
}
