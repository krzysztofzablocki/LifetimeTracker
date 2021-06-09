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
}
