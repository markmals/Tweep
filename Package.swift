// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Tweep",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [.library(name: "Tweep", targets: ["Tweep"])],
    dependencies: [],
    targets: [
        .target(name: "Tweep", dependencies: []),
        .testTarget(name: "TweepTests", dependencies: ["Tweep"])
    ]
)
