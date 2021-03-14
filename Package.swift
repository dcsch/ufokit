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
      .package(url: "https://github.com/dcsch/fontpens.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "UFOKit", dependencies: ["FontPens"]),
        .testTarget(name: "UFOKitTests", dependencies: ["UFOKit"]),
    ]
)
