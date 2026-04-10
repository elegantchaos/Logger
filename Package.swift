// swift-tools-version:6.2

import Foundation
import PackageDescription

let package = Package(
  name: "Logger",

  platforms: [
    .macOS(.v15),
    .macCatalyst(.v18),
    .iOS(.v18),
    .tvOS(.v18),
    .watchOS(.v11),
    .custom(
      "Ubuntu", versionString: "22.04"
    ),
  ],

  products: [
    .library(
      name: "Logger",
      targets: ["Logger"]
    ),

    .library(
      name: "LoggerUI",
      targets: ["LoggerUI"]
    ),

    .library(
      name: "LoggerTestSupport",
      targets: ["LoggerTestSupport"]
    ),
  ],

  dependencies: [
    .package(
      url: "https://github.com/elegantchaos/ActionBuilderPlugin.git",
      from: "2.0.3"
    )
  ],

  targets: [
    .target(
      name: "Logger",
      dependencies: []
    ),

    .target(
      name: "LoggerUI",
      dependencies: [
        "Logger"
      ],
    ),

    .target(
      name: "LoggerTestSupport",
      dependencies: [
        "Logger"
      ]
    ),

    .testTarget(
      name: "LoggerTests",
      dependencies: [
        "Logger",
        "LoggerUI",
        "LoggerTestSupport",
      ]
    ),
  ]
)
