// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PassFast",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "PassFast",
            targets: ["PassFast"]
        ),
    ],
    targets: [
        .target(
            name: "PassFast",
            path: "Sources/PassFast"
        ),
        .testTarget(
            name: "PassFastTests",
            dependencies: ["PassFast"],
            path: "Tests/PassFastTests"
        ),
    ]
)
