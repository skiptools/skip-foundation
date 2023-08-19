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

class TestNSNull : XCTestCase {
    
    
    func test_alwaysEqual() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let null_1 = NSNull()
        let null_2 = NSNull()
        
        let null_3: NSNull? = NSNull()
        let null_4: NSNull? = nil
        
        //Check that any two NSNull's are ==
        XCTAssertEqual(null_1, null_2)

        //Check that any two NSNull's are ===, preserving the singleton behavior
        XCTAssertTrue(null_1 === null_2)
        
        //Check that NSNull() == .Some(NSNull)
        XCTAssertEqual(null_1, null_3)
        
        //Make sure that NSNull() != .None
        XCTAssertNotEqual(null_1, null_4)        
        #endif // !SKIP
    }
    
    func test_description() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(NSNull().description, "<null>")
        #endif // !SKIP
    }
}


