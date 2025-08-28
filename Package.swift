// swift-tools-version:6.2

import Foundation
import PackageDescription

let usePlugins = ProcessInfo.processInfo.environment["RESOLVE_COMMAND_PLUGINS"] != nil

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

  dependencies: [],

  targets: [
    .target(
      name: "Logger",
      dependencies: [],
      plugins: usePlugins
        ? [
          .plugin(name: "ActionBuilderPlugin", package: "ActionBuilderPlugin")
        ] : []
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
        "LoggerTestSupport",
      ]
    ),
  ]
)

if usePlugins {
  package.dependencies.append(contentsOf: [
    .package(
      url: "https://github.com/elegantchaos/ActionBuilderPlugin.git",
      from: "2.0.1"
    )
  ])
}
