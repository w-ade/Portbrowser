// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Visto",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Visto", targets: ["Visto"])
    ],
    targets: [
        .executableTarget(
            name: "Visto",
            path: "Sources/Visto",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
