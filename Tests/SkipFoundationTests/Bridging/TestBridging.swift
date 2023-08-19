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
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


#if !SKIP
struct StructWithDescriptionAndDebugDescription:
    CustomStringConvertible, CustomDebugStringConvertible
{
    var description: String { "description" }
    var debugDescription: String { "debugDescription" }
}
#endif

class TestBridging : XCTestCase {

    func testBridgedDescription() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        #if canImport(Foundation) && canImport(SwiftFoundation)
        /*
          Do not test this on Darwin.
          On systems where swift-corelibs-foundation is the Foundation module,
         the stdlib gives us the ability to specify how bridging works
         (by using our __SwiftValue class), which is what we're testing
         here when we do 'a as AnyObject'. But on Darwin, bridging is out
         of SCF's hands — there is an ObjC __SwiftValue class vended by
         the runtime.
          Deceptively, below, when we say 'NSObject', we mean SwiftFoundation.NSObject,
         not the ObjC NSObject class — which is what __SwiftValue actually
         derives from. So, as? NSObject below returns nil on Darwin.
          Since this functionality is tested by the stdlib tests on Darwin,
         just skip this test here.
        */
        #else
        // Struct with working (debug)description properties:
        let a = StructWithDescriptionAndDebugDescription()
        XCTAssertEqual("description", a.description)
        XCTAssertEqual("debugDescription", a.debugDescription)

        // Wrap it up in a SwiftValue container
        let b = (a as AnyObject) as? NSObject
        XCTAssertNotNil(b)
        let c = try XCTUnwrap(b)

        // Check that the wrapper forwards (debug)description
        // to the wrapped description property.
//        XCTAssertEqual("description", c.description)
//        XCTAssertEqual("description", c.debugDescription)
        #endif
        #endif // !SKIP
    }

    func testDynamicCast() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // Covers https://github.com/apple/swift-corelibs-foundation/pull/2500
        class TestClass {}
        let anyArray: Any = [TestClass()]
        XCTAssertNotNil(anyArray as? NSObject)
        #endif // !SKIP
    }

    func testConstantsImmortal() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        func release(_ ptr: UnsafeRawPointer, count: Int) {
            let object: Unmanaged<NSNumber> = Unmanaged.fromOpaque(ptr)
            for _ in 0..<count {
                object.release()
            }
        } 

        let trueConstant = NSNumber(value: true)
        let falseConstant = NSNumber(value: false)

        // To accurately read the whole refcount, we need to read the second
        // word of the pointer.
        let truePtr = unsafeBitCast(trueConstant, to: UnsafePointer<Int>.self)
        let falsePtr = unsafeBitCast(falseConstant, to: UnsafePointer<Int>.self)

        let trueRefCount = truePtr.advanced(by: 1).pointee
        let falseRefCount = falsePtr.advanced(by: 1).pointee

        XCTAssertEqual(trueRefCount, falseRefCount)

        release(truePtr, count: 5)
        release(falsePtr, count: 5)

        XCTAssertEqual(trueRefCount, truePtr.advanced(by: 1).pointee)
        XCTAssertEqual(falseRefCount, falsePtr.advanced(by: 1).pointee)
        #endif // !SKIP
    }
}


