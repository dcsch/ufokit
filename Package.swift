// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "UFOKit",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "UFOKit", targets: ["UFOKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "UFOKit", dependencies: []),
        .testTarget(name: "UFOKitTests", dependencies: ["UFOKit"]),
    ]
)
