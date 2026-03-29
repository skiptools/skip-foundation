// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import Foundation
import XCTest

class TestString : XCTestCase {
    func test_rangeof() {
        let str = "Hello, Skip!"
        let rangeAll = str.range(of: str)
        XCTAssertEqual(rangeAll, str.startIndex..<str.endIndex)
        let rangeEL = str.range(of: "el")
        XCTAssertEqual(rangeEL, str.index(str.startIndex, offsetBy: 1)..<str.index(str.startIndex, offsetBy: 3))
    }
}
