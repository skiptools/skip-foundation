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

class TestNSValue : XCTestCase {
    
    func test_valueWithCGPoint() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if !os(iOS)
        let point = CGPoint(x: CGFloat(1.0), y: CGFloat(2.0234))
        let value = NSValue(point: point)
        XCTAssertEqual(value.pointValue, point)
        
        var expected = CGPoint()
        value.getValue(&expected)
        XCTAssertEqual(expected, point)
        #endif
        #endif // !SKIP
    }
    
    func test_valueWithCGSize() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if !os(iOS)
        let size = CGSize(width: CGFloat(1123.234), height: CGFloat(3452.234))
        let value = NSValue(size: size)
        XCTAssertEqual(value.sizeValue, size)
        
        var expected = CGSize()
        value.getValue(&expected)
        XCTAssertEqual(expected, size)
        #endif
        #endif // !SKIP
    }
    
    func test_valueWithCGRect() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if !os(iOS)
        let point = CGPoint(x: CGFloat(1.0), y: CGFloat(2.0234))
        let size = CGSize(width: CGFloat(1123.234), height: CGFloat(3452.234))
        let rect = CGRect(origin: point, size: size)
        let value = NSValue(rect: rect)
        XCTAssertEqual(value.rectValue, rect)
        
        var expected = CGRect()
        value.getValue(&expected)
        XCTAssertEqual(expected, rect)
        #endif
        #endif // !SKIP
    }
    
    func test_valueWithNSRange() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let range = NSRange(location: 1, length: 2)
        let value = NSValue(range: range)
        XCTAssertEqual(value.rangeValue.location, range.location)
        XCTAssertEqual(value.rangeValue.length, range.length)

        var expected = NSRange()
        value.getValue(&expected)
        XCTAssertEqual(expected.location, range.location)
        XCTAssertEqual(expected.length, range.length)
        #endif // !SKIP
    }
    
    func test_valueWithNSEdgeInsets() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if !os(iOS)
        let edgeInsets = NSEdgeInsets(top: CGFloat(234.0), left: CGFloat(23.20), bottom: CGFloat(0.0), right: CGFloat(99.0))
        let value = NSValue(edgeInsets: edgeInsets)
        XCTAssertEqual(value.edgeInsetsValue.top, edgeInsets.top)
        XCTAssertEqual(value.edgeInsetsValue.left, edgeInsets.left)
        XCTAssertEqual(value.edgeInsetsValue.bottom, edgeInsets.bottom)
        XCTAssertEqual(value.edgeInsetsValue.right, edgeInsets.right)
        
        var expected = NSEdgeInsets()
        value.getValue(&expected)
        XCTAssertEqual(expected.top, edgeInsets.top)
        XCTAssertEqual(expected.left, edgeInsets.left)
        XCTAssertEqual(expected.bottom, edgeInsets.bottom)
        XCTAssertEqual(expected.right, edgeInsets.right)
        #endif
        #endif // !SKIP
    }
    
    func test_valueWithLong() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var long: Int32 = 123456
        var expected: Int32 = 0
        NSValue(bytes: &long, objCType: "l").getValue(&expected)
        XCTAssertEqual(long, expected)
        #endif // !SKIP
    }
    
    func test_valueWithULongLongArray() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array: Array<UInt64> = [12341234123, 23452345234, 23475982345, 9893563243, 13469816598]
        array.withUnsafeBufferPointer { cArray in
            var expected = [UInt64](repeating: 0, count: 5)
            NSValue(bytes: cArray.baseAddress!, objCType: "[5Q]").getValue(&expected)
            XCTAssertEqual(array, expected)
        }
        #endif // !SKIP
    }
    
    func test_valueWithShortArray() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array: Array<Int16> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        let objctype = "[" + String(array.count) + "s]"
        array.withUnsafeBufferPointer { cArray in
            var expected = [Int16](repeating: 0, count: array.count)
            NSValue(bytes: cArray.baseAddress!, objCType: objctype).getValue(&expected)
            XCTAssertEqual(array, expected)
        }
        #endif // !SKIP
    }

    func test_valueWithCharPtr() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var charArray = [UInt8]("testing123".utf8)
        charArray.withUnsafeMutableBufferPointer {
            var charPtr = $0.baseAddress!
            var expectedPtr: UnsafeMutablePointer<UInt8>? = nil
        
            NSValue(bytes: &charPtr, objCType: "*").getValue(&expectedPtr)
            XCTAssertEqual(charPtr, expectedPtr)
        }
        #endif // !SKIP
    }

    func test_isEqual() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let number = NSNumber(value: Int(123))
        var long: Int32 = 123456
        let value = NSValue(bytes: &long, objCType: "l")
        XCTAssertFalse(value.isEqual(number))
        #endif // !SKIP
    }
}


