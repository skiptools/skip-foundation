// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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
