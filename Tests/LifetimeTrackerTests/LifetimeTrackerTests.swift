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

private final class TrackableObject: NSObject, LifetimeTrackable {

    static var lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "TrackableObject")

    override init() {
        super.init()

        trackLifetime()
    }
}

class LifetimeTrackerTests: XCTestCase {

    override func setUp() {
        LifetimeTracker.setup { (trackedGroups: [String: LifetimeTracker.EntriesGroup]) in
            // Nothing to do here
        }
    }
    override func tearDown() {
        LifetimeTracker.instance = nil
    }

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

    func testEntryMaxCountDoesNotChangeAfterMultipleAllocations() {

        var currentEntryMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.entries[TrackableObject.lifetimeConfiguration.instanceName]?.maxCount
        }

        TrackableObject.lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "TrackableObject")

        // Create the initial object with a count of 1
        let _ = TrackableObject()

        // Test that the inital maxCount is used
        XCTAssertEqual(currentEntryMaxCount, 1, "Entry maxCount != 1 after the first initialization")

        // Test that a second allocation doesn't change the initial maxCount
        let _ = TrackableObject()
        XCTAssertEqual(currentEntryMaxCount, 1, "Entry maxCount != 1 after the first initialization")
    }

    func testConfigurationMaxCountIncrementationUpdatesEntryAndGroupMaxCount() {

        var currentEntryMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.entries[TrackableObject.lifetimeConfiguration.instanceName]?.maxCount
        }
        var currentGroupMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.maxCount
        }

        // Create the initial object with a count of 1
        TrackableObject.lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "TrackableObject")
        let _ = TrackableObject()

        // Test that the inital maxCount is used
        XCTAssertEqual(currentEntryMaxCount, 1, "Entry maxCount != 1 after the first initialization")
        XCTAssertEqual(currentGroupMaxCount, 1, "Group maxCount != 1 after the first initialization")

        // Test that a modification of the objects maxCount with a allocation or deallocation does change the entries and groups maxCount
        TrackableObject.lifetimeConfiguration.maxCount = 2
        let _ = TrackableObject()
        XCTAssertEqual(currentEntryMaxCount, 2, "Entry maxCount != 2 after the modification of maxCount")
        XCTAssertEqual(currentGroupMaxCount, 2, "Group maxCount != 2 after the modification of maxCount")
    }

    func testConfigurationMaxCountDecrementationUpdatesEntryAndGroupMaxCount() {

        var currentEntryMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.entries[TrackableObject.lifetimeConfiguration.instanceName]?.maxCount
        }
        var currentGroupMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.maxCount
        }

        // Create the initial object with a count of 3
        TrackableObject.lifetimeConfiguration = LifetimeConfiguration(maxCount: 3, groupName: "TrackableObject")
        let _ = TrackableObject()

        // Test that the inital maxCount is used
        XCTAssertEqual(currentEntryMaxCount, 3, "Entry maxCount != 3 after the first initialization")
        XCTAssertEqual(currentGroupMaxCount, 3, "Group maxCount != 3 after the first initialization")

        // Test that a modification of the objects maxCount after a new allocation does change the entries and groups maxCount
        TrackableObject.lifetimeConfiguration.maxCount = 2
        let _ = TrackableObject()
        XCTAssertEqual(currentEntryMaxCount, 2, "Entry maxCount != 2 after the modification of maxCount")
        XCTAssertEqual(currentGroupMaxCount, 2, "Group maxCount != 2 after the modification of maxCount")
    }

    func testConfigurationMaxCountIncrementationDoeNotChangeOverriddenGroupsMaxCount() {

        var currentEntryMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.entries[TrackableObject.lifetimeConfiguration.instanceName]?.maxCount
        }
        var currentGroupMaxCount: Int? {
            return LifetimeTracker.instance?.trackedGroups["TrackableObject"]?.maxCount
        }

        // Create the initial object with a count of 3
        TrackableObject.lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "TrackableObject", groupMaxCount: 2)
        let _ = TrackableObject()

        // Test that the inital maxCount is used
        XCTAssertEqual(currentEntryMaxCount, 1, "Entry maxCount != 1 after the first initialization")
        XCTAssertEqual(currentGroupMaxCount, 2, "Overriden group maxCount != 2 after the first initialization")

        // Test that a modification of the objects maxCount after a new allocation doesn't change the overriden group maxCount
        TrackableObject.lifetimeConfiguration.maxCount = 2
        let _ = TrackableObject()
        XCTAssertEqual(currentEntryMaxCount, 2, "Entry maxCount != 2 after the modification of maxCount")
        XCTAssertEqual(currentGroupMaxCount, 2, "Overriden group maxCount != 2 after the modification of maxCount")
    }

    func testLeakClosure() {
        var hasLeaked = false
        LifetimeTracker.instance?.onLeakDetected = { entry, group in
            hasLeaked = true
        }

        TrackableObject.lifetimeConfiguration = LifetimeConfiguration(maxCount: 1)
        var trackables = [TrackableObject]()
        trackables.append(TrackableObject())
        XCTAssert(!hasLeaked)
        trackables.append(TrackableObject())
        XCTAssert(hasLeaked)
    }

    static var allTests = [
        ("testDeallocTrackerFiresOnDealloc", testDeallocTrackerFiresOnDealloc),
        ("testDeallocTrackerDoesntFire", testDeallocTrackerDoesntFire),
        ("testEntryMaxCountDoesNotChangeAfterMultipleAllocations", testEntryMaxCountDoesNotChangeAfterMultipleAllocations),
        ("testConfigurationMaxCountIncrementationUpdatesEntryAndGroupMaxCount", testConfigurationMaxCountIncrementationUpdatesEntryAndGroupMaxCount),
        ("testConfigurationMaxCountDecrementationUpdatesEntryAndGroupMaxCount", testConfigurationMaxCountDecrementationUpdatesEntryAndGroupMaxCount),
        ("testConfigurationMaxCountIncrementationDoeNotChangeOverriddenGroupsMaxCount", testConfigurationMaxCountIncrementationDoeNotChangeOverriddenGroupsMaxCount),
        ("testLeakClosure", testLeakClosure)
    ]
}
