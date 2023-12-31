// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import OSLog
import XCTest

@available(macOS 13, iOS 16, watchOS 10, tvOS 16, *)
final class BundleTests: XCTestCase {
    let logger: Logger = Logger(subsystem: "test", category: "BundleTests")

    func testBundle() throws {
        // Swift will be: Contents/Resources/ -- file:///~/Library/Developer/Xcode/DerivedData/DemoApp-ABCDEF/Build/Products/Debug/SkipFoundationTests.xctest/Contents/Resources/Skip_SkipFoundationTests.bundle/
        // Kotlin will be: file:/SRCDIR/Skip/kip/SkipFoundationTests/modules/SkipFoundation/build/tmp/kotlin-classes/debugUnitTest/skip/foundation/
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "textasset", withExtension: "txt", subdirectory: nil, localization: nil))
        logger.info("resourceURL: \(resourceURL.absoluteString)")
        let str = try String(contentsOf: resourceURL)
        XCTAssertEqual("Some text\n", str)
    }

    func testBundleInfo() throws {
        #if !SKIP
        // sadly, the Info.plist is auto-generated by SPM and cannot be overridden
        let _ = Bundle.module.infoDictionary ?? [:]
        let name = Bundle.module.bundleURL.deletingPathExtension().lastPathComponent
        XCTAssertTrue(name.hasSuffix("_SkipFoundationTests"), "unexpected name: \(name)")
        let moduleName = name.split(separator: "_").last?.description ?? name // turn "Skip_SkipFoundationTests" into "SkipFoundationTests"
        XCTAssertEqual("SkipFoundationTests", moduleName)

        //XCTAssertEqual(["BuildMachineOSBuild", "CFBundleDevelopmentRegion", "CFBundleIdentifier", "CFBundleInfoDictionaryVersion", "CFBundleName", "CFBundlePackageType", "CFBundleSupportedPlatforms", "DTCompiler", "DTPlatformBuild", "DTPlatformName", "DTPlatformVersion", "DTSDKBuild", "DTSDKName", "DTXcode", "DTXcodeBuild", "LSMinimumSystemVersion"], Set(info.keys))
        //XCTAssertEqual("Skip_SkipFoundationTests", info["CFBundleName"] as? String)
        #endif
    }
}
