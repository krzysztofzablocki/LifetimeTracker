import XCTest
@testable import LifetimeTrackerTests

XCTMain([
    testCase(LifetimeTrackerTests.allTests),
    testCase(VisibilityTests.allTests),
])
