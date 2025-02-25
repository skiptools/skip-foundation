// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestDimension: XCTestCase {

    func test_encodeDecode() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let original = Dimension(symbol: "symbol", converter: UnitConverterLinear(coefficient: 1.0))
        #endif // !SKIP
    }

}


