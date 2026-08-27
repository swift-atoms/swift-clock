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
        .library(
            name: "Clock",
            targets: ["Clock"]
        ),
        .library(
            name: "Clock Standard Library Integration",
            targets: ["Clock Standard Library Integration"]
        ),
        .library(
            name: "Clock Apple Foundation Integration",
            targets: ["Clock Apple Foundation Integration"]
        ),
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
                .product(name: "Tagged", package: "swift-tagged")
            ]
        ),
        .target(
            name: "Clock Standard Library Integration",
            dependencies: ["Clock"]
        ),
        .target(
            name: "Clock Apple Foundation Integration",
            dependencies: [
                "Clock",
                "Clock Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Clock Tests",
            dependencies: ["Clock"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
