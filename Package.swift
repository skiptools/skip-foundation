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
        .package(url: "https://source.skip.tools/skip.git", from: "1.5.14"),
        .package(url: "https://source.skip.tools/skip-lib.git", from: "1.3.6"),
    ],
    targets: [
        .target(name: "SkipFoundation", dependencies: [.product(name: "SkipLib", package: "skip-lib")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipFoundationTests", dependencies: ["SkipFoundation", .product(name: "SkipTest", package: "skip")], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

if Context.environment["SKIP_BRIDGE"] ?? "0" != "0" {
    // all library types must be dynamic to support bridging
    package.products = package.products.map({ product in
        guard let libraryProduct = product as? Product.Library else { return product }
        return .library(name: libraryProduct.name, type: .dynamic, targets: libraryProduct.targets)
    })
}
