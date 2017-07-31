//
//  LifetimeTrackerTests.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 27/07/2017.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation
import XCTest
@testable import LifetimeTracker

private final class Foo {}

class LifetimeTrackerTests: XCTestCase {
    func testDeallocTrackerFiresOnDealloc() {
        var fake: Foo? = Foo()
        var wasCalled = false

        onDealloc(of: fake as Any) { wasCalled = true }
        fake = nil

        XCTAssertTrue(wasCalled)
    }

    func testDeallocTrackerDoesntFire() {
        let fake: Foo? = Foo()
        var wasCalled = false

        onDealloc(of: fake as Any) { wasCalled = true }

        XCTAssertFalse(wasCalled)
    }
    
    static var allTests = [
        ("testDeallocTrackerFiresOnDealloc", testDeallocTrackerFiresOnDealloc),
        ("testDeallocTrackerDoesntFire", testDeallocTrackerDoesntFire)
    ]
}
