// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "skip-foundation",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipFoundation", targets: ["SkipFoundation"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.6.42"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "0.3.11"),
    ],
    targets: [
        .target(name: "SkipFoundation", dependencies: [.product(name: "SkipLib", package: "skip-lib", condition: .when(platforms: [.macOS]))], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipFoundationTests", dependencies: ["SkipFoundation"], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
