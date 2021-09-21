// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "g2swift",
    products: [
        .executable(name: "g2swift", targets: ["g2swift"]),
        .library(name: "libg2swift", targets: ["libg2swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0")
    ],
    targets: [
        .target(name: "libg2swift"),
        .executableTarget(
            name: "g2swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "libg2swift"
            ]
        )
    ]
)
