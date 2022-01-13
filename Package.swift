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
    ],
    targets: [
        .target(
            name: "LifetimeTracker",
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("Localizable.strings", localization: .default),
            ]
        )
    ]
)
