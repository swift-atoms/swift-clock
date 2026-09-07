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

        .library(name: "Clock Foundation Integration", targets: ["Clock Foundation Integration"]),
        .library(name: "Clock Test Support", targets: ["Clock Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Clock",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            path: "Sources/Clock"
        ),
        
        .target(
            name: "Clock Foundation Integration",
            dependencies: [
                .target(name: "Clock"),
            ],
            path: "Sources/Clock Foundation Integration"
        ),
        .target(
            name: "Clock Test Support",
            dependencies: [
                .target(name: "Clock"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Clock Tests",
            dependencies: [
                .target(name: "Clock"),
                .product(name: "Tagged", package: "swift-tagged"),
                .target(name: "Clock Test Support"),
                .target(name: "Clock Foundation Integration"),
            ],
            path: "Tests/Clock Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
