// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "LoggerExample",
  platforms: [
    .macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11),
  ],
  products: [
    .executable(name: "Example", targets: ["Example"])
  ],
  dependencies: [
    // Use the checkout containing this example, including uncommitted changes.
    .package(name: "Logger", path: "../../..")
    // In a separate project, use a released version instead:
    // .package(url: "https://github.com/elegantchaos/Logger.git", from: "2.1.1")
  ],
  targets: [
    .executableTarget(
      name: "Example",
      dependencies: [.product(name: "Logger", package: "Logger")]
    )
  ]
)
