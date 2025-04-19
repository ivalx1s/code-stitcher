// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "code-stitcher",
    targets: [
        .executableTarget(
            name: "CodeStitcher",
            path: "Sources"
        ),
    ]
)
