// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Portview",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Portview", targets: ["Portview"])
    ],
    targets: [
        .executableTarget(
            name: "Portview",
            path: "Sources/Portview",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
