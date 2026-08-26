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
            name: "Clock Test Support",
            targets: ["Clock Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-carrier.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-standard-library-extensions.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Clock",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Carrier", package: "swift-carrier"),
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
            ]
        ),
        .target(
            name: "Clock Test Support",
            dependencies: [
                "Clock",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Clock Tests",
            dependencies: [
                "Clock",
                "Clock Test Support",
            ]
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
