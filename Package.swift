// swift-tools-version:6.2

import Foundation
import PackageDescription

let package = Package(
  name: "Logger",

  platforms: [
    .macOS(.v15), .macCatalyst(.v18), .iOS(.v18), .tvOS(.v18), .watchOS(.v5),
  ],

  products: [
    .library(
      name: "Logger",
      targets: ["Logger"]),
    .library(
      name: "LoggerUI",
      targets: ["LoggerUI"]),
    .library(
      name: "LoggerTestSupport",
      targets: ["LoggerTestSupport"]),
  ],

  dependencies: [],

  targets: [
    .target(
      name: "Logger",
      dependencies: []),
    .target(
      name: "LoggerUI",
      dependencies: ["Logger"]),
    .target(
      name: "LoggerTestSupport",
      dependencies: ["Logger"]),
    .testTarget(
      name: "LoggerTests",
      dependencies: ["Logger", "LoggerTestSupport"]),
  ]
)

if ProcessInfo.processInfo.environment["RESOLVE_COMMAND_PLUGINS"] != nil {
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/elegantchaos/ActionBuilderPlugin.git", from: "1.0.8"),
    .package(url: "https://github.com/elegantchaos/SwiftFormatterPlugin.git", from: "1.0.3"),
  ])
}
