// swift-tools-version:5.6

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
            targets: ["LoggerTestSupport"]),
        
//        .plugin(
//            name: "lint",
//            targets: ["LinterPlugin"]
//        ),
    ],
    
    dependencies: [
//        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
//        .package(url: "https://github.com/realm/SwiftLint", branch: "master"),
    ],
    
    targets: [
        .target(
            name: "Logger",
            dependencies: []),
        
            .target(
                name: "LoggerKit",
                dependencies: ["Logger"]
            ),
        
            .target(
                name: "LoggerUI",
                dependencies: ["Logger"]
            ),
        
            .target(
                name: "LoggerTestSupport",
                dependencies: ["Logger"]
            ),
        
            .testTarget(
                name: "LoggerTests",
                dependencies: ["Logger", "LoggerTestSupport"]
            ),
        
            .testTarget(
                name: "LoggerKitTests",
                dependencies: ["LoggerKit", "LoggerTestSupport"]
            )
        
//            .plugin(name: "LinterPlugin",
//                    capability: .command(
//                        intent: .custom(verb: "lint", description: "Format with swift-lint"),
//                        permissions: [
//                            .writeToPackageDirectory(reason: "This command lints source files")
//                        ]
//                    ),
//                    dependencies: [
//                        .product(name: "swiftlint", package: "SwiftLint"),
//                    ]
//                   )

        
    ]
)


import Foundation
if ProcessInfo.processInfo.environment["RESOLVE_COMMAND_PLUGINS"] != nil {
    package.dependencies.append(
        .package(url: "https://github.com/elegantchaos/SwiftFormatterPlugin.git", from: "1.0.2")
    )
}
