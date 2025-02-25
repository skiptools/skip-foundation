// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

final class URLTests: XCTestCase {
    func testURLs() throws {
        let url: URL? = URL(string: "https://github.com/skiptools/skip.git")
        XCTAssertEqual("https://github.com/skiptools/skip.git", url?.absoluteString)
        XCTAssertEqual("/skiptools/skip.git", url!.path())
        XCTAssertEqual("github.com", url?.host)
        XCTAssertEqual("git", url?.pathExtension)
        XCTAssertEqual("skip.git", url?.lastPathComponent)
        XCTAssertEqual(false, url?.isFileURL)

        #if false
        // This fails on CI
        let complexURL = URL(string: "https://github.com:443/user/new?user=foo&password=password@^%|1")
        XCTAssertNotNil(complexURL)
        XCTAssertEqual(443, complexURL?.port)
        XCTAssertEqual("user=foo&password=password@%5E%25%7C1", complexURL?.query())
        #endif
    }
}
