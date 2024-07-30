// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Passage",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Passage",
            targets: ["Passage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.55.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Passage",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "PassageTests",
            dependencies: ["Passage"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
