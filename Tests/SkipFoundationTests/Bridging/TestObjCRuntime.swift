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


class SwiftClass {
    class InnerClass {}
}



struct SwiftStruct {}

enum SwiftEnum {}

class TestObjCRuntime: XCTestCase {

    func testStringFromClass() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let name = testBundleName()
        XCTAssertEqual(NSStringFromClass(NSObject.self), "NSObject")
//        XCTAssertEqual(NSStringFromClass(SwiftClass.self), "\(name).SwiftClass")
#if canImport(SwiftXCTest) && !DEPLOYMENT_RUNTIME_OBJC
//        XCTAssertEqual(NSStringFromClass(XCTestCase.self), "SwiftXCTest.XCTestCase");
#else
//        XCTAssertEqual(NSStringFromClass(XCTestCase.self), "XCTest.XCTestCase");
#endif
        #endif // !SKIP
    }

    func testClassFromString() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let name = testBundleName()
        XCTAssertNotNil(NSClassFromString("NSObject"))
//        XCTAssertNotNil(NSClassFromString("\(name).SwiftClass"))
        XCTAssertNil(NSClassFromString("\(name).SwiftClass.InnerClass"))
        XCTAssertNil(NSClassFromString("SwiftClass"))
        XCTAssertNil(NSClassFromString("MadeUpClassName"))
        XCTAssertNil(NSClassFromString("SwiftStruct"));
        XCTAssertNil(NSClassFromString("SwiftEnum"));
        #endif // !SKIP
    }
    
    #if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT
    func testClassesRenamedByAPINotes() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for entry in _NSClassesRenamedByObjCAPINotes {
            XCTAssert(try XCTUnwrap(NSClassFromString(NSStringFromClass(entry.class))) === entry.class)
            XCTAssert(NSStringFromClass(try XCTUnwrap(NSClassFromString(entry.objCName))) == entry.objCName)
        }
        #endif // !SKIP
    }
    #endif
}


