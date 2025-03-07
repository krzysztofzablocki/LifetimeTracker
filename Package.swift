// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LifetimeTracker",
    defaultLocalization: "en",
    products: [
        .library(
            name: "LifetimeTracker",
            targets: ["LifetimeTracker"]
        ),
        .library(
            name: "LifetimeTrackerCore",
            targets: ["LifetimeTrackerCore"]
        ),
    ],
    targets: [
        .target(
            name: "LifetimeTrackerCore"
        ),
        .target(
            name: "LifetimeTracker",
            dependencies: [
                .target(name: "LifetimeTrackerCore"),
            ],
            resources: [
                .process("Resources"),
                .process("Localizable.strings", localization: .default),
            ]
        )
    ]
)
