// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-clock",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Clock", targets: ["Clock"]),
        .library(name: "Clock Concurrency", targets: ["Clock Concurrency"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-point.git", branch: "main", traits: ["Affine"]),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-time.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Clock",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Time", package: "swift-time"),
            ],
            path: "Sources/Clock"
        ),
        .target(
            name: "Clock Concurrency",
            dependencies: [
                .target(name: "Clock"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Time", package: "swift-time"),
            ],
            path: "Sources/Clock Concurrency"
        ),
        .testTarget(
            name: "Clock Tests",
            dependencies: [
                .product(name: "Point", package: "swift-point"),
                .target(name: "Clock"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Time", package: "swift-time"),
            ],
            path: "Tests/Clock Tests"
        ),
        .testTarget(
            name: "Clock Concurrency Tests",
            dependencies: [
                .target(name: "Clock Concurrency"),
                .product(name: "Time", package: "swift-time"),
            ],
            path: "Tests/Clock Concurrency Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
