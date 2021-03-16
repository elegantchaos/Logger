// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "LoggerExample",
    platforms: [
        .macOS(.v10_13), .iOS(.v12), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
    .executable(
        name: "Example",
        targets: ["Example"])
    ],
    dependencies: [
	.package(url: "../../..", .branch("main"))
    ],
    targets: [
    .target(
          name: "Example",
          dependencies: ["Logger"])
    ]
  )
