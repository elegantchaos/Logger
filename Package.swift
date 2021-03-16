// swift-tools-version:5.0

import PackageDescription

var products: [Product] = [
    .library(
        name: "Logger",
        targets: ["Logger"]),
    .library(
        name: "LoggerUI",
        targets: ["LoggerUI"]),
    .library(
        name: "LoggerKit",
        targets: ["LoggerKit"]),
    .library(
        name: "LoggerTestSupport",
        targets: ["LoggerTestSupport"])
]


#if os(macOS)
products.append(
    .executable(
        name: "LoggerExample",
        targets: ["LoggerExample"]
    )
)
#endif

let package = Package(
    name: "Logger",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v5)
    ],
    products: products,
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
            name: "LoggerUI",
            dependencies: ["Logger"]),
        .target(
              name: "LoggerExample",
              dependencies: ["Logger"]),
        .target(
            name: "LoggerTestSupport",
            dependencies: ["Logger"]),
        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger", "LoggerTestSupport"]),
        .testTarget(
            name: "LoggerKitTests",
            dependencies: ["LoggerKit", "LoggerTestSupport"]),
    ]
  )
