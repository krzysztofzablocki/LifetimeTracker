//
//  Extensions.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 09.11.17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import UIKit

internal extension UIViewController {

    class var lt_bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: self)
        #endif
    }
}

internal extension UIView {
    
    class var lt_nibInOwnBundle: UINib {
        #if SWIFT_PACKAGE
        return UINib(nibName: String(describing: self), bundle: Bundle.module)
        #else
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
        #endif
    }
}
