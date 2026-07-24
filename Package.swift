// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PortBrowser",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PortBrowser", targets: ["PortBrowser"])
    ],
    targets: [
        .executableTarget(
            name: "PortBrowser",
            path: "Sources/PortBrowser",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
