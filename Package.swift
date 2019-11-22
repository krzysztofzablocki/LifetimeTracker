// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LifetimeTracker",
    products: [
        .library(name: "LifetimeTracker", 
                targets: ["LifetimeTracker"]),
    ],
    targets: [
        .target(name: "LifetimeTracker", path: "Sources")
    ]
)
