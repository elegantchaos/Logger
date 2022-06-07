// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
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
            name: "LoggerUI",
            dependencies: ["Logger"]),
        .target(
            name: "LoggerTestSupport",
            dependencies: ["Logger"]),
        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger", "LoggerTestSupport"]),
        .testTarget(
            name: "LoggerKitTests",
            dependencies: ["LoggerKit", "LoggerTestSupport"])
    ]
  )

#if swift(>=5.6)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )

package.dependencies.append(
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.41.2")
  )
#endif
