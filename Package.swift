// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LifetimeTracker",
    products: [
        .library(name: "LifetimeTracker", 
                targets: ["LifetimeTracker"]),
    ]
)

#if os(iOS)
package.targets.append(
    .target(name: "LifetimeTracker", path: "Sources")
)
#else
package.targets.append(
    .target(name: "LifetimeTracker", path: "Sources", exclude: ["UI", "iOS"])
)
#endif