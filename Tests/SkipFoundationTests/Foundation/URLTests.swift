// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

final class URLTests: XCTestCase {
    func testURLs() throws {
        let url: URL? = URL(string: "https://github.com/skiptools/skip.git")
        XCTAssertEqual("https://github.com/skiptools/skip.git", url?.absoluteString)
        XCTAssertEqual("/skiptools/skip.git", url?.path)
        XCTAssertEqual("github.com", url?.host)
        XCTAssertEqual("git", url?.pathExtension)
        XCTAssertEqual("skip.git", url?.lastPathComponent)
        XCTAssertEqual(false, url?.isFileURL)
    }
}
