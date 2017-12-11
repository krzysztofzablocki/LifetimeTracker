//
//  LifetimeConfigurationObjc.swift
//  LifetimeTracker
//
//  Created by Jan Čislinský on 09. 12. 2017.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

@objc public class LifetimeConfigurationObjc: NSObject {
    internal let nonObjc: LifetimeConfiguration

    @objc public static func defaultSetup() {
        LifetimeTracker.setup(onUpdate: LifetimeTrackerDashboardIntegration(visibility: .visibleWithIssuesDetected).refreshUI)
    }

    @objc public init(maxCount: Int) {
        nonObjc = LifetimeConfiguration(maxCount: maxCount)
        super.init()
    }
    @objc public init(maxCount: Int, groupName: String) {
        nonObjc = LifetimeConfiguration(maxCount: maxCount, groupName: groupName)
        super.init()
    }
    @objc public init(maxCount: Int, groupName: String, groupMaxCount: Int) {
        nonObjc = LifetimeConfiguration(maxCount: maxCount, groupName: groupName, groupMaxCount: groupMaxCount)
        super.init()
    }
}
