// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestUnitInformationStorage: XCTestCase {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testUnitInformationStorage() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let bits = Measurement(value: 8, unit: UnitInformationStorage.bits)
        XCTAssertEqual(
            bits.converted(to: .bytes).value,
            1,
            "Conversion from bits to bytes"
        )
        XCTAssertEqual(
            bits.converted(to: .nibbles).value,
            2,
            "Conversion from bits to nibbles"
        )
        XCTAssertEqual(
            bits.converted(to: .yottabits).value,
            8.0e-24,
            accuracy: 1.0e-27,
            "Conversion from bits to yottabits"
        )
        XCTAssertEqual(
            bits.converted(to: .gibibits).value,
            7.450581e-09,
            accuracy: 1.0e-12,
            "Conversion from bits to gibibits"
        )
        #endif // !SKIP
    }
}


