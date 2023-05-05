// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "process-launcher",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "ProcessLauncher", targets: ["ProcessLauncher"]),
        .library(name: "ProcessLauncherTestKit", targets: ["ProcessLauncherTestKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aleksproger/TimeoutStrategy.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/aleksproger/RetryStrategies.git", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "ProcessLauncher", dependencies: [
            "RetryStrategies",
            .product(name: "TimeoutStrategy", package: "TimeoutStrategy")
        ]),

        .target(name: "ProcessLauncherTestKit", dependencies: ["ProcessLauncher"]),

        .testTarget(name: "ProcessLauncherTests", dependencies: [
            "ProcessLauncher",
            "ProcessLauncherTestKit",
            .product(name: "RetryStrategiesTestKit", package: "RetryStrategies"),
            .product(name: "TimeoutStrategyTestKit", package: "TimeoutStrategy")
        ]),
    ]
)
