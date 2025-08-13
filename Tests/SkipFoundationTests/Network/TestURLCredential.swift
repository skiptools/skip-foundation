// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestURLCredential : XCTestCase {
    
    
    func test_construction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let credential = URLCredential(user: "swiftUser", password: "swiftPassword", persistence: .forSession)
        XCTAssertEqual(credential.user, "swiftUser")
        XCTAssertEqual(credential.password, "swiftPassword")
        XCTAssertEqual(credential.persistence, URLCredential.Persistence.forSession)
        XCTAssertEqual(credential.hasPassword, true)
        #endif // !SKIP
    }

    func test_copy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let credential = URLCredential(user: "swiftUser", password: "swiftPassword", persistence: .forSession)
        let copy = credential.copy() as! URLCredential
        XCTAssertTrue(copy.isEqual(credential))
        #endif // !SKIP
    }
}


