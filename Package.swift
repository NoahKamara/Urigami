// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "urigami",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "UrigamiKit", targets: ["UrigamiKit"]),
        .executable(name: "urigami", targets: ["UrigamiCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/vapor/console-kit.git", from: "4.15.2"),
    ],
    targets: [
        .executableTarget(
            name: "UrigamiCLI",
            dependencies: [
                "UrigamiKit",
                .product(name: "ConsoleKit", package: "console-kit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
                .unsafeFlags(["-whole-module-optimization", "-O"], .when(configuration: .release))
            ]
        ),
        .target(
            name: "UrigamiKit",
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
            ]
        ),
    ]
)
