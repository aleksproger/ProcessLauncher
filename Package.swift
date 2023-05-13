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
        .package(url: "https://github.com/aleksproger/timeout-strategy.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/aleksproger/retry-strategies.git", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "ProcessLauncher", dependencies: [
            .product(name: "RetryStrategiesTestKit", package: "retry-strategies"),
            .product(name: "TimeoutStrategy", package: "timeout-strategy")
        ]),

        .target(name: "ProcessLauncherTestKit", dependencies: ["ProcessLauncher"]),

        .testTarget(name: "ProcessLauncherTests", dependencies: [
            "ProcessLauncher",
            "ProcessLauncherTestKit",
            .product(name: "RetryStrategiesTestKit", package: "retry-strategies"),
            .product(name: "TimeoutStrategyTestKit", package: "timeout-strategy")
        ]),
    ]
)
