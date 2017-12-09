//
//  LifetimeTrackerObjc.swift
//  LifetimeTracker
//
//  Created by Jan Čislinský on 09. 12. 2017.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

@objc public protocol LifetimeTrackableTrack {
    /// Starts tracking lifetime, should be called in each initializer
    func trackLifetime()
}

@objc public protocol LifetimeTrackableConfigure {
    /// Configuration for lifetime tracking, contains identifier and leak classifier
    static var lifetimeConfigurationObjc: LifetimeConfigurationObjc { get }
}

@objc public protocol LifetimeTrackableObjc: NSObjectProtocol, LifetimeTrackableTrack, LifetimeTrackableConfigure {}

@objc extension NSObject: LifetimeTrackableTrack {
    public func trackLifetime() {
        if let configurable = self as? LifetimeTrackableConfigure {
            LifetimeTracker.instance?.track(self, configuration: type(of: configurable).lifetimeConfigurationObjc.nonObjc)
        }
    }
}
