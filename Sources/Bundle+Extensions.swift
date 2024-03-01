//
//  File.swift
//  
//
//  Created by Leo Tsuchiya on 6/6/21.
//

import Foundation

extension Bundle {

    /// Returns a package manager appropriate `Bundle`.
    static var resolvedBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: LifetimeTracker.self)
        #endif
    }
    static var stringBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let mainBundle = Bundle(for: LifetimeTracker.self)
        if let podBundlePath = mainBundle.path(forResource: "LifetimeTracker", ofType: "bundle") {
            return Bundle(path: podBundlePath) ?? mainBundle
        }
        return mainBundle
        #endif
    }
}
