// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//


#if !SKIP
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension AttributedStringProtocol {
    fileprivate mutating func genericSetAttribute() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        self.testInt = 3
        #endif // !SKIP
    }
}
#endif

/// Tests for `AttributedString` to confirm expected CoW behavior
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
final class TestAttributedStringCOW: XCTestCase {
    
    // MARK: - Utility Functions
    
    func createAttributedString() -> AttributedString {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var str = AttributedString("Hello", attributes: container)
        str += AttributedString(" ")
        str += AttributedString("World", attributes: containerB)
        return str
        #endif // !SKIP
    }
    
    #if !SKIP
    func assertCOWCopy(file: StaticString = #file, line: UInt = #line, _ operation: (inout AttributedString) -> Void) {
        let str = createAttributedString()
        var copy = str
        operation(&copy)
        XCTAssertNotEqual(str, copy, "Mutation operation did not copy when multiple references exist", file: file, line: line)
    }

    func assertCOWNoCopy(file: StaticString = #file, line: UInt = #line, _ operation: (inout AttributedString) -> Void) {
        var str = createAttributedString()
//        let gutsPtr = Unmanaged.passUnretained(str._guts)
//        operation(&str)
//        let newGutsPtr = Unmanaged.passUnretained(str._guts)
//        XCTAssertEqual(gutsPtr.toOpaque(), newGutsPtr.toOpaque(), "Mutation operation copied when only one reference exists", file: file, line: line)
    }
    
    func assertCOWBehavior(file: StaticString = #file, line: UInt = #line, _ operation: (inout AttributedString) -> Void) {
        assertCOWCopy(file: file, line: line, operation)
        assertCOWNoCopy(file: file, line: line, operation)
    }
    #endif // !SKIP

    func makeSubrange(_ str: AttributedString) -> Range<AttributedString.Index> {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        return str.characters.index(str.startIndex, offsetBy: 2)..<str.characters.index(str.endIndex, offsetBy: -2)
        #endif // !SKIP
    }
    
    #if !SKIP
    lazy var container: AttributeContainer = {
        var container = AttributeContainer()
        container.testInt = 2
        return container
    }()
    
    lazy var containerB: AttributeContainer = {
        var container = AttributeContainer()
        container.testBool = true
        return container
    }()
    #endif

    // MARK: - Tests
    
    func testTopLevelType() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        assertCOWBehavior { (str) in
            str.setAttributes(container)
        }
        assertCOWBehavior { (str) in
            str.mergeAttributes(container)
        }
        assertCOWBehavior { (str) in
            str.replaceAttributes(container, with: containerB)
        }
        assertCOWBehavior { (str) in
            str.append(AttributedString("b", attributes: containerB))
        }
        assertCOWBehavior { (str) in
            str.insert(AttributedString("b", attributes: containerB), at: str.startIndex)
        }
        assertCOWBehavior { (str) in
            str.removeSubrange(..<str.characters.index(str.startIndex, offsetBy: 3))
        }
        assertCOWBehavior { (str) in
            str.replaceSubrange(..<str.characters.index(str.startIndex, offsetBy: 3), with: AttributedString("b", attributes: containerB))
        }
        assertCOWBehavior { (str) in
            str[AttributeScopes.TestAttributes.TestIntAttribute.self] = 3
        }
        assertCOWBehavior { (str) in
            str.testInt = 3
        }
        assertCOWBehavior { (str) in
            str.test.testInt = 3
        }
        #endif // !SKIP
    }
    
    func testSubstring() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        assertCOWBehavior { (str) in
            str[makeSubrange(str)].setAttributes(container)
        }
        assertCOWBehavior { (str) in
            str[makeSubrange(str)].mergeAttributes(container)
        }
        assertCOWBehavior { (str) in
            str[makeSubrange(str)].replaceAttributes(container, with: containerB)
        }
        assertCOWBehavior { (str) in
            str[makeSubrange(str)][AttributeScopes.TestAttributes.TestIntAttribute.self] = 3
        }
        assertCOWBehavior { (str) in
            str[makeSubrange(str)].testInt = 3
        }
        assertCOWBehavior { (str) in
            str[makeSubrange(str)].test.testInt = 3
        }
        #endif // !SKIP
    }
    
    func testCharacters() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let char: Character = "a"
        
        assertCOWBehavior { (str) in
            str.characters.replaceSubrange(makeSubrange(str), with: "abc")
        }
        assertCOWBehavior { (str) in
            str.characters.append(char)
        }
        assertCOWBehavior { (str) in
            str.characters.append(contentsOf: "abc")
        }
        assertCOWBehavior { (str) in
            str.characters.append(contentsOf: [char, char, char])
        }
        assertCOWBehavior { (str) in
            str.characters[str.startIndex] = "A"
        }
        assertCOWBehavior { (str) in
            str.characters[makeSubrange(str)].append("a")
        }
        #endif // !SKIP
    }
    
    func testUnicodeScalars() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let scalar: UnicodeScalar = "a"
        
        assertCOWBehavior { (str) in
            str.unicodeScalars.replaceSubrange(makeSubrange(str), with: [scalar, scalar])
        }
        #endif // !SKIP
    }
    
    func testGenericProtocol() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        assertCOWBehavior {
            $0.genericSetAttribute()
        }
        assertCOWBehavior {
            $0[makeSubrange($0)].genericSetAttribute()
        }
        #endif // !SKIP
    }
    
}

