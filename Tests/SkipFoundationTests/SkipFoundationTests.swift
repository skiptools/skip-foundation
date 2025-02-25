// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import OSLog
import XCTest
#if !SKIP
@testable import func SkipFoundation.SkipFoundationInternalModuleName
@testable import func SkipFoundation.SkipFoundationPublicModuleName
#endif

final class SkipFoundationTests: XCTestCase {
    let logger: Logger = Logger(subsystem: "test", category: "SkipFoundationTests")

    func testSkipFoundation() throws {
        XCTAssertEqual(3, 1 + 2)
        XCTAssertEqual("SkipFoundation", SkipFoundationInternalModuleName())
        XCTAssertEqual("SkipFoundation", SkipFoundationPublicModuleName())
    }

    func testSystemProperties() throws {
        let env = ProcessInfo.processInfo.environment

        // returns the value of the given key iff we are on Robolectric
        func check(_ key: String, value: String) {
            if isRobolectric {
                XCTAssertEqual(value, env[key], "Unexpected value for Robolectric system property \(key): \(env[key] ?? "")")
            } else if isAndroidEmulator {
                logger.log("ANDROID ENV: \(key)=\(env[key] ?? "")")
                XCTAssertNotNil(env[key], "Android system property should not been nil for key \(key)")
            } else {
                XCTAssertNil(env[key], "Swift system property should have been nil for key \(key) value=\(env[key] ?? "")")
            }
        }

        check("android.os.Build.BOARD", value: "unknown")
        check("android.os.Build.BOOTLOADER", value: "unknown")
        check("android.os.Build.BRAND", value: "unknown")
        check("android.os.Build.DEVICE", value: "robolectric")
        check("android.os.Build.DISPLAY", value: "sdk_phone_x86-userdebug 10 QPP6.190730.006 5803371 test-keys")
        check("android.os.Build.FINGERPRINT", value: "robolectric")
        check("android.os.Build.HARDWARE", value: "robolectric")
        check("android.os.Build.HOST", value: "wphn1.hot.corp.google.com")
        check("android.os.Build.ID", value: "QPP6.190730.006")
        check("android.os.Build.MANUFACTURER", value: "unknown")
        check("android.os.Build.MODEL", value: "robolectric")
        check("android.os.Build.PRODUCT", value: "robolectric")
        check("android.os.Build.TAGS", value: "test-keys")
        check("android.os.Build.TYPE", value: "userdebug")
        check("android.os.Build.USER", value: "android-build")

        //XCTAssertEqual("", env["android.os.Build.SUPPORTED_32_BIT_ABIS"])
        //XCTAssertEqual("", env["android.os.Build.SUPPORTED_64_BIT_ABIS"])
        //XCTAssertEqual("", env["android.os.Build.SUPPORTED_ABIS"])

        check("android.os.Build.VERSION.BASE_OS", value: "")
        check("android.os.Build.VERSION.CODENAME", value: "REL")
        check("android.os.Build.VERSION.INCREMENTAL", value: "5803371")
        check("android.os.Build.VERSION.PREVIEW_SDK_INT", value: "0")
        check("android.os.Build.VERSION.RELEASE", value: "10")
        check("android.os.Build.VERSION.SDK_INT", value: "29")
        check("android.os.Build.VERSION.SECURITY_PATCH", value: "2019-08-01")
    }
}

