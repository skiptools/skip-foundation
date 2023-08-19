// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "skip-foundation",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
    products: [
        .library(name: "SkipFoundation", targets: ["SkipFoundation"]),
        .library(name: "SkipFoundationKt", targets: ["SkipFoundationKt"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "0.5.83"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "0.0.0"),
        .package(url: "https://source.skip.tools/skip-unit.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "SkipFoundation", plugins: [.plugin(name: "preflight", package: "skip")]),
        .target(name: "SkipFoundationKt", dependencies: [
            "SkipFoundation",
            .product(name: "SkipLibKt", package: "skip-lib"),
        ], resources: [.process("Skip")], plugins: [.plugin(name: "transpile", package: "skip")]),
        .testTarget(name: "SkipFoundationTests", dependencies: [
            "SkipFoundation"
        ], resources: [.process("Resources")], plugins: [.plugin(name: "preflight", package: "skip")]),
        .testTarget(name: "SkipFoundationKtTests", dependencies: [
            "SkipFoundationKt",
            .product(name: "SkipUnitKt", package: "skip-unit"),
        ], resources: [.process("Skip")], plugins: [.plugin(name: "transpile", package: "skip")]),
    ]
)
