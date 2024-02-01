// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "skip-foundation",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipFoundation", targets: ["SkipFoundation"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.7.52"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "0.6.4"),
    ],
    targets: [
        .target(name: "SkipFoundation", dependencies: [.product(name: "SkipLib", package: "skip-lib")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipFoundationTests", dependencies: ["SkipFoundation", .product(name: "SkipTest", package: "skip")], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
