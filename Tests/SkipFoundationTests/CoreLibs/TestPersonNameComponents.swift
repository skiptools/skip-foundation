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
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

private func assertEqual(_ lhs:PersonNameComponents,
                         _ rhs: PersonNameComponents) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
    assert(equal: true, lhs, rhs)
        #endif // !SKIP
}

private func assertNotEqual(_ lhs:PersonNameComponents,
                            _ rhs: PersonNameComponents) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
    assert(equal: false, lhs, rhs)
        #endif // !SKIP
}

private func assert(equal: Bool,
                    _ lhs:PersonNameComponents,
                    _ rhs: PersonNameComponents) {
        #if SKIP
        throw XCTSkip("TODO")
        #else
    if equal {
        XCTAssertEqual(lhs, rhs)
        XCTAssertEqual(lhs._bridgeToObjectiveC(), rhs._bridgeToObjectiveC())
        XCTAssertTrue(lhs._bridgeToObjectiveC().isEqual(rhs))
    } else {
        XCTAssertNotEqual(lhs, rhs)
        XCTAssertNotEqual(lhs._bridgeToObjectiveC(), rhs._bridgeToObjectiveC())
        XCTAssertFalse(lhs._bridgeToObjectiveC().isEqual(rhs))
    }
        #endif // !SKIP
}

class TestPersonNameComponents : XCTestCase {
    
    
    func testCopy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let original = NSPersonNameComponents()
        original.givenName = "Maria"
        original.phoneticRepresentation = PersonNameComponents()
        original.phoneticRepresentation!.givenName = "Jeff"
        let copy = original.copy(with:nil) as! NSPersonNameComponents
        copy.givenName = "Rebecca"
        
        XCTAssertNotEqual(original.givenName, copy.givenName)
        XCTAssertEqual(original.phoneticRepresentation!.givenName,copy.phoneticRepresentation!.givenName)
        XCTAssertNil(copy.phoneticRepresentation!.phoneticRepresentation)
        #endif // !SKIP
    }

    func testEquality() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        do {
            let lhs = PersonNameComponents()
            let rhs = PersonNameComponents()
            assertEqual(lhs, rhs)
        }

        let lhs = self.makePersonNameComponentsWithTestValues()
        do {
            let rhs = self.makePersonNameComponentsWithTestValues()
            assertEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.namePrefix = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.givenName = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.middleName = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.familyName = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.nameSuffix = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.nickname = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        do {
            var rhs = self.makePersonNameComponentsWithTestValues()
            rhs.phoneticRepresentation?.namePrefix = "differentValue"
            assertNotEqual(lhs, rhs)
        }
        #endif // !SKIP
    }

    // MARK: - Helpers

    private func makePersonNameComponentsWithTestValues() -> PersonNameComponents {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var components = PersonNameComponents()
        components.namePrefix = "namePrefix"
        components.givenName = "givenName"
        components.middleName = "middleName"
        components.familyName = "familyName"
        components.nameSuffix = "nameSuffix"
        components.nickname = "nickname"
        components.phoneticRepresentation = {
            var components = PersonNameComponents()
            components.namePrefix = "phonetic_namePrefix"
            components.givenName = "phonetic_givenName"
            components.middleName = "phonetic_middleName"
            components.familyName = "phonetic_familyName"
            components.nameSuffix = "phonetic_nameSuffix"
            components.nickname = "phonetic_nickname"
            return components
        }()
        return components
        #endif // !SKIP
    }
}

        


