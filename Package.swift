// swift-tools-version: 6.0

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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "PassFast",
            path: "Sources/PassFast",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "PassFastTests",
            dependencies: [
                "PassFast",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests/PassFastTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
