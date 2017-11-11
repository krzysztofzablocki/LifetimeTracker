//
//  Extensions.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 09.11.17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import UIKit

internal extension UIView {

	class var lt_nibInOwnBundle: UINib {
		return UINib(nibName: "\(self)", bundle: Bundle(for: self))
	}
}
