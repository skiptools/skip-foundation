// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest
#if !SKIP
@testable import func SkipFoundation.SkipFoundationInternalModuleName
@testable import func SkipFoundation.SkipFoundationPublicModuleName
#endif

final class SkipFoundationTests: XCTestCase {
    func testSkipFoundation() throws {
        XCTAssertEqual(3, 1 + 2)
        XCTAssertEqual("SkipFoundation", SkipFoundationInternalModuleName())
        XCTAssertEqual("SkipFoundation", SkipFoundationPublicModuleName())

        // there are only a few system properties on the Android emulator: java.io.tmpdir, user.home, and http.agent "Dalvik/2.1.0 (Linux; U; Android 13; sdk_gphone64_arm64 Build/ TE1A.220922.021)"
        let isJVM = ProcessInfo.processInfo.environment["java.io.tmpdir"] != nil
    }
}
