// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import Foundation
import XCTest

class TestString : XCTestCase {
    func test_percentEncodingRoundTrip() {
        let allowed = CharacterSet.urlQueryAllowed
        let original = "a b+c%d 中文 🎉"
        let encoded = original.addingPercentEncoding(withAllowedCharacters: allowed)
        XCTAssertEqual(encoded, "a%20b+c%25d%20%E4%B8%AD%E6%96%87%20%F0%9F%8E%89")
        XCTAssertEqual(encoded?.removingPercentEncoding, original)
    }

    func test_rangeof() {
        let str = "Hello, Skip!"
        let rangeAll = str.range(of: str)
        XCTAssertEqual(rangeAll, str.startIndex..<str.endIndex)
        let rangeEL = str.range(of: "el")
        XCTAssertEqual(rangeEL, str.index(str.startIndex, offsetBy: 1)..<str.index(str.startIndex, offsetBy: 3))
    }
}
