// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MobilePreviewer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MobilePreviewer", targets: ["MobilePreviewer"])
    ],
    targets: [
        .executableTarget(
            name: "MobilePreviewer",
            path: "Sources/MobilePreviewer"
        )
    ]
)
