//
//  VisibilityTests.swift
//  LifetimeTracker
//
//  Created by Jim Roepcke on 2017-10-24.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation
import XCTest
@testable import LifetimeTracker

private typealias Visibility = LifetimeTrackerDashboardIntegration.Visibility

class VisibilityTests: XCTestCase {

    func testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreNoIssuesToDisplay() {
        let behavior = Visibility.alwaysHidden
        let hasIssuesToDisplay = false
        XCTAssertTrue(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    func testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreIssuesToDisplay() {
        let behavior = Visibility.alwaysHidden
        let hasIssuesToDisplay = true
        XCTAssertTrue(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    func testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreNoIssuesToDisplay() {
        let behavior = Visibility.alwaysVisible
        let hasIssuesToDisplay = false
        XCTAssertFalse(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    func testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreIssuesToDisplay() {
        let behavior = Visibility.alwaysVisible
        let hasIssuesToDisplay = true
        XCTAssertFalse(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    func testHidesWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreNoIssuesToDisplay() {
        let behavior = Visibility.visibleWithIssuesDetected
        let hasIssuesToDisplay = false
        XCTAssertTrue(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    func testDoesNotHideWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreIssuesToDisplay() {
        let behavior = Visibility.visibleWithIssuesDetected
        let hasIssuesToDisplay = true
        XCTAssertFalse(behavior.windowIsHidden(hasIssuesToDisplay: hasIssuesToDisplay))
    }

    static var allTests = [
        ("testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreNoIssuesToDisplay", testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreNoIssuesToDisplay),
        ("testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreIssuesToDisplay", testHidesWindowWhenBehaviorIsAlwaysHiddenAndThereAreIssuesToDisplay),
        ("testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreNoIssuesToDisplay", testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreNoIssuesToDisplay),
        ("testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreIssuesToDisplay", testDoesNotHideWindowWhenBehaviorIsAlwaysVisibleAndThereAreIssuesToDisplay),
        ("testHidesWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreNoIssuesToDisplay", testHidesWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreNoIssuesToDisplay),
        ("testDoesNotHideWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreIssuesToDisplay", testDoesNotHideWindowWhenBehaviorIsVisibleWithIssuesDetectedAndThereAreIssuesToDisplay),
    ]
}
