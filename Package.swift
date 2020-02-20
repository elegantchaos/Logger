// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(
            name: "Logger",
            targets: ["Logger"]),
        .library(
            name: "LoggerKit",
            targets: ["LoggerKit"]),
        .library(
            name: "LoggerTestSupport",
            targets: ["LoggerTestSupport"]),
        .executable(
            name: "Example",
            targets: ["Example"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: []),
        .target(
            name: "LoggerKit",
            dependencies: ["Logger"]),
        .target(
              name: "Example",
              dependencies: ["Logger"]),
        .target(
            name: "LoggerTestSupport",
            dependencies: ["Logger"]),
        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger", "LoggerTestSupport"]),
    ],
    swiftLanguageVersions: [.v4_2]
  )
