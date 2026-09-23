// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Portbrowser",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Portbrowser", targets: ["Portbrowser"])
    ],
    targets: [
        .executableTarget(
            name: "Portbrowser",
            path: "Sources/Portbrowser",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
