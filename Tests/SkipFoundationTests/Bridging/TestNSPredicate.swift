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

class TestNSPredicate: XCTestCase {


    func test_BooleanPredicate() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let truePredicate = NSPredicate(value: true)
        let falsePredicate = NSPredicate(value: false)

        XCTAssertTrue(truePredicate.evaluate(with: NSObject()))
        XCTAssertFalse(falsePredicate.evaluate(with: NSObject()))
        #endif // !SKIP
    }


    func test_BlockPredicateWithoutVariableBindings() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let isNSStringPredicate = NSPredicate { (object, bindings) -> Bool in
            return object is NSString
        }

        XCTAssertTrue(isNSStringPredicate.evaluate(with: NSString()))
        XCTAssertFalse(isNSStringPredicate.evaluate(with: NSArray()))
        #endif // !SKIP
    }

    #if !SKIP
    let lengthLessThanThreePredicate = NSPredicate { (obj, bindings) -> Bool in
        return (obj as! String).utf16.count < 3
    }
    #endif

    let startArray = ["1", "12", "123", "1234"]
    let expectedArray = ["1", "12"]

    func test_filterNSArray() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let filteredArray = NSArray(array: startArray).filtered(using: lengthLessThanThreePredicate).map { $0 as! String }
        XCTAssertEqual(expectedArray, filteredArray)
        #endif // !SKIP
    }

    func test_filterNSMutableArray() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array = NSMutableArray(array: startArray)
        array.filter(using: lengthLessThanThreePredicate)
        XCTAssertEqual(NSArray(array: expectedArray), array)
        #endif // !SKIP
    }

    func test_filterNSSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSSet(array: startArray)
        let filteredSet = set.filtered(using: lengthLessThanThreePredicate)
        XCTAssertEqual(Set(expectedArray), filteredSet)
        #endif // !SKIP
    }

    func test_filterNSMutableSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableSet(array: ["1", "12", "123", "1234"])
        set.filter(using: lengthLessThanThreePredicate)

        XCTAssertEqual(Set(expectedArray), Set(set.allObjects.map { $0 as! String }))
        #endif // !SKIP
    }

    func test_filterNSOrderedSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let orderedSet = NSOrderedSet(array: startArray)
        let filteredOrderedSet = orderedSet.filtered(using: lengthLessThanThreePredicate)
        XCTAssertEqual(NSOrderedSet(array: expectedArray), filteredOrderedSet)
        #endif // !SKIP
    }

    func test_filterNSMutableOrderedSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let orderedSet = NSMutableOrderedSet()
        orderedSet.addObjects(from: startArray)
        orderedSet.filter(using: lengthLessThanThreePredicate)

        let expectedOrderedSet = NSMutableOrderedSet()
        expectedOrderedSet.addObjects(from: expectedArray)
        XCTAssertEqual(expectedOrderedSet, orderedSet)
        #endif // !SKIP
    }
    
    func test_copy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let predicate = NSPredicate(value: true)
        XCTAssert(predicate.isEqual(predicate.copy()))
        #endif // !SKIP
    }
}


