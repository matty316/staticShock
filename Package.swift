// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StaticShock",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/matty316/markymark.git", exact: "0.0.7"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "StaticShock", dependencies: [
                // other dependencies
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "MarkyMark", package: "MarkyMark")
            ]),
        .testTarget(name: "StaticShockTests", dependencies: ["StaticShock"], resources: [.copy("TestData")]),
    ]
)
