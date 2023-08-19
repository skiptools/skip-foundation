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

class TestNSOrderedSet : XCTestCase {

    func test_BasicConstruction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet()
        let set2 = NSOrderedSet(array: ["foo", "bar"])
        XCTAssertEqual(set.count, 0)
        XCTAssertEqual(set2.count, 2)
        #endif // !SKIP
    }

    func test_Enumeration() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let arr = ["foo", "bar", "bar"]
        let set = NSOrderedSet(array: arr)
        var index = 0
        for item in set {
            XCTAssertEqual(arr[index], item as? String)
            index += 1
        }
        #endif // !SKIP
    }
    
    func test_enumerationUsingBlock() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let array = NSOrderedSet(array: Array(0..<100))
        let createIndexesArrayHavingSeen = { (havingSeen: IndexSet) in
            return (0 ..< array.count).map { havingSeen.contains($0) }
        }
        
        let noIndexes = IndexSet()
        let allIndexes = IndexSet(integersIn: 0 ..< array.count)
        let firstHalfOfIndexes = IndexSet(integersIn: 0 ..< array.count / 2)
        let lastHalfOfIndexes = IndexSet(integersIn: array.count / 2 ..< array.count)
        let evenIndexes : IndexSet = {
            var indexes = IndexSet()
            for index in allIndexes.filter({ $0 % 2 == 0 }) {
                indexes.insert(index)
            }
            return indexes
        }()
        
        let testExpectingToSee = { (expectation: IndexSet, block: (inout UnsafeMutableBufferPointer<Bool>) -> Void) in
            var indexesSeen = createIndexesArrayHavingSeen(noIndexes)
            indexesSeen.withUnsafeMutableBufferPointer(block)
//            XCTAssertEqual(indexesSeen, createIndexesArrayHavingSeen(expectation))
        }
        
        // Test enumerateObjects(_:), allowing it to run to completion...
        
        testExpectingToSee(allIndexes) { (indexesSeen) in
            array.enumerateObjects { (value, index, stop) in
                XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                indexesSeen[index] = true
            }
        }
        
        // ... and stopping after the first half:
        
        testExpectingToSee(firstHalfOfIndexes) { (indexesSeen) in
            array.enumerateObjects { (value, index, stop) in
                XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                
                if firstHalfOfIndexes.contains(index) {
                    indexesSeen[index] = true
                } else {
                    stop.pointee = true
                }
            }
        }
        
        // -----
        // Test enumerateObjects(options:using) and enumerateObjects(at:options:using:):
        
        // Test each of these options combinations:
        let optionsToTest: [NSEnumerationOptions] = [
            [],
            [.concurrent],
            [.reverse],
            [.concurrent, .reverse],
            ]
        
        for options in optionsToTest {
            // Run to completion,
            testExpectingToSee(allIndexes) { (indexesSeen) in
                array.enumerateObjects(options: options, using: { (value, index, stop) in
                    XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                    indexesSeen[index] = true
                })
            }
            
            // run it only for half the indexes (use the right half depending on where we start),
            let indexesForHalfEnumeration = options.contains(.reverse) ? lastHalfOfIndexes : firstHalfOfIndexes
            
            testExpectingToSee(indexesForHalfEnumeration) { (indexesSeen) in
                array.enumerateObjects(options: options, using: { (value, index, stop) in
                    XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                    
                    if indexesForHalfEnumeration.contains(index) {
                        indexesSeen[index] = true
                    } else {
                        stop.pointee = true
                    }
                })
            }
            
            // run only for a specific index set to test the at:… variant,
            testExpectingToSee(evenIndexes) { (indexesSeen) in
                array.enumerateObjects(at: evenIndexes, options: options, using: { (value, index, stop) in
                    XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                    indexesSeen[index] = true
                })
            }
            
            // and run for some indexes only to test stopping.
            var indexesForStaggeredEnumeration = indexesForHalfEnumeration
            indexesForStaggeredEnumeration.formIntersection(evenIndexes)
            
            let finalCount = indexesForStaggeredEnumeration.count
            
            let lockForSeenCount = NSLock()
            var seenCount = 0
            
            testExpectingToSee(indexesForStaggeredEnumeration) { (indexesSeen) in
                array.enumerateObjects(at: evenIndexes, options: options, using: { (value, index, stop) in
                    XCTAssertEqual(value as! NSNumber, array[index] as! NSNumber)
                    
                    if (indexesForStaggeredEnumeration.contains(index)) {
                        indexesSeen[index] = true
                        
                        lockForSeenCount.lock()
                        seenCount += 1
                        let currentCount = seenCount
                        lockForSeenCount.unlock()
                        
                        if currentCount == finalCount {
                            stop.pointee = true
                        }
                    }
                })
            }
        }
        #endif // !SKIP
    }

    func test_Uniqueness() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "bar"])
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.object(at: 0) as? String, "foo")
        XCTAssertEqual(set.object(at: 1) as? String, "bar")
        #endif // !SKIP
    }

    func test_reversedEnumeration() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let arr = ["foo", "bar", "baz"]
        let set = NSOrderedSet(array: arr)
        var index = set.count - 1
        let revSet = set.reverseObjectEnumerator()
        for item in revSet {
            XCTAssertEqual(set.object(at: index) as? String, item as? String)
            index -= 1
        }
        #endif // !SKIP
    }

    func test_reversedOrderedSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let days = ["monday", "tuesday", "wednesday", "thursday", "friday"]
        let work = NSOrderedSet(array: days)
        let krow = work.reversed
        var index = work.count - 1
        for item in krow {
            XCTAssertEqual(work.object(at: index) as? String, item as? String)
           index -= 1
        }
        #endif // !SKIP
    }

    func test_reversedEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: [])
        let reversedEnum = set.reverseObjectEnumerator()
        XCTAssertNil(reversedEnum.nextObject())
        let reversedSet = set.reversed
        XCTAssertNil(reversedSet.firstObject)
        #endif // !SKIP
    }

    func test_ObjectAtIndex() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "baz"])
        XCTAssertEqual(set.object(at: 0) as? String, "foo")
        XCTAssertEqual(set.object(at: 1) as? String, "bar")
        XCTAssertEqual(set.object(at: 2) as? String, "baz")
        #endif // !SKIP
    }

    func test_ObjectsAtIndexes() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "baz", "1", "2", "3"])
        let objects = set.objects(at: [1, 3, 5])
        XCTAssertEqual(objects.count, 3)
        XCTAssertEqual(objects[0] as? String, "bar")
        XCTAssertEqual(objects[1] as? String, "1")
        XCTAssertEqual(objects[2] as? String, "3")
        #endif // !SKIP
    }

    func test_FirstAndLastObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "baz"])
        XCTAssertEqual(set.firstObject as? String, "foo")
        XCTAssertEqual(set.lastObject as? String, "baz")
        #endif // !SKIP
    }

    func test_AddObject() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.add("1")
        set.add("2")
        XCTAssertEqual(set[0] as? String, "1")
        XCTAssertEqual(set[1] as? String, "2")
        XCTAssertEqual(set.count, 2)
        #endif // !SKIP
    }

    func test_AddObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.addObjects(from: ["foo", "bar", "baz"])
        XCTAssertEqual(set.object(at: 0) as? String, "foo")
        XCTAssertEqual(set.object(at: 1) as? String, "bar")
        XCTAssertEqual(set.object(at: 2) as? String, "baz")
        #endif // !SKIP
    }

    func test_RemoveAllObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.addObjects(from: ["foo", "bar", "baz"])
        XCTAssertEqual(set.index(of: "foo"), 0)
        set.removeAllObjects()
        XCTAssertEqual(set.count, 0)
        XCTAssertEqual(set.index(of: "foo"), NSNotFound)
        #endif // !SKIP
    }

    func test_RemoveObject() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.addObjects(from: ["foo", "bar", "baz"])
        set.remove("bar")
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.index(of: "baz"), 1)
        #endif // !SKIP
    }

    func test_RemoveObjectAtIndex() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.addObjects(from: ["foo", "bar", "baz"])
        set.removeObject(at: 1)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.index(of: "baz"), 1)
        #endif // !SKIP
    }

    func test_IsEqualToOrderedSet() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "baz"])
        let otherSet = NSOrderedSet(array: ["foo", "bar", "baz"])
        let otherOtherSet = NSOrderedSet(array: ["foo", "bar", "123"])
        XCTAssert(set.isEqual(to: otherSet))
        XCTAssertFalse(set.isEqual(to: otherOtherSet))
        #endif // !SKIP
    }

    func test_Subsets() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSOrderedSet(array: ["foo", "bar", "baz"])
        let otherOrderedSet = NSOrderedSet(array: ["foo", "bar"])
        let otherSet = Set<AnyHashable>(["foo", "baz"])
        let otherOtherSet = Set<AnyHashable>(["foo", "bar", "baz", "123"])
        XCTAssert(otherOrderedSet.isSubset(of: set))
        XCTAssertFalse(set.isSubset(of: otherOrderedSet))
        XCTAssertFalse(set.isSubset(of: otherSet))
        XCTAssert(set.isSubset(of: otherOtherSet))
        #endif // !SKIP
    }

    func test_ReplaceObject() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        set.replaceObject(at: 1, with: "123")
        set[2] = "456"
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "123")
        XCTAssertEqual(set[2] as? String, "456")
        #endif // !SKIP
    }

    func test_ExchangeObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        set.exchangeObject(at: 0, withObjectAt: 2)
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0] as? String, "baz")
        XCTAssertEqual(set[1] as? String, "bar")
        XCTAssertEqual(set[2] as? String, "foo")
        #endif // !SKIP
    }

    func test_MoveObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz", "123", "456")
        var indexes = IndexSet()
        indexes.insert(1)
        indexes.insert(2)
        indexes.insert(4)
        set.moveObjects(at: indexes, to: 0)
        XCTAssertEqual(set.count, 5)
        XCTAssertEqual(set[0] as? String, "bar")
        XCTAssertEqual(set[1] as? String, "baz")
        XCTAssertEqual(set[2] as? String, "456")
        XCTAssertEqual(set[3] as? String, "foo")
        XCTAssertEqual(set[4] as? String, "123")
        #endif // !SKIP
    }

    func test_InsertObjects() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        var indexes = IndexSet()
        indexes.insert(1)
        indexes.insert(3)
        set.insert(["123", "456"], at: indexes)
        XCTAssertEqual(set.count, 5)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "123")
        XCTAssertEqual(set[2] as? String, "bar")
        XCTAssertEqual(set[3] as? String, "456")
        XCTAssertEqual(set[4] as? String, "baz")
        #endif // !SKIP
    }

    func test_Insert() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet()
        set.insert("foo", at: 0)
        XCTAssertEqual(set.count, 1)
        XCTAssertEqual(set[0] as? String, "foo")
        set.insert("bar", at: 1)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[1] as? String, "bar")
        #endif // !SKIP
    }

    func test_SetObjectAtIndex() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        set.setObject("123", at: 1)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "123")
        XCTAssertEqual(set[2] as? String, "baz")
        set.setObject("456", at: 3)
        XCTAssertEqual(set[3] as? String, "456")
        #endif // !SKIP
    }

    func test_RemoveObjectsInRange() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz", "123", "456")
        set.removeObjects(in: NSRange(location: 1, length: 2))
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "123")
        XCTAssertEqual(set[2] as? String, "456")
        #endif // !SKIP
    }

    func test_ReplaceObjectsAtIndexes() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        var indexes = IndexSet()
        indexes.insert(0)
        indexes.insert(2)
        set.replaceObjects(at: indexes, with: ["a", "b"])
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set[0] as? String, "a")
        XCTAssertEqual(set[1] as? String, "bar")
        XCTAssertEqual(set[2] as? String, "b")
        #endif // !SKIP
    }

    func test_Intersection() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        let otherSet = NSOrderedSet(array: ["foo", "baz"])
        XCTAssert(set.intersects(otherSet))
        let otherOtherSet = Set<AnyHashable>(["foo", "123"])
        XCTAssert(set.intersectsSet(otherOtherSet))
        set.intersect(otherSet)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "baz")
        set.intersectSet(otherOtherSet)
        XCTAssertEqual(set.count, 1)
        XCTAssertEqual(set[0] as? String, "foo")

        let nonIntersectingSet = Set<AnyHashable>(["asdf"])
        XCTAssertFalse(set.intersectsSet(nonIntersectingSet))
        #endif // !SKIP
    }

    func test_Subtraction() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        let otherSet = NSOrderedSet(array: ["baz"])
        let otherOtherSet = Set<AnyHashable>(["foo"])
        set.minus(otherSet)
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "bar")
        set.minusSet(otherOtherSet)
        XCTAssertEqual(set.count, 1)
        XCTAssertEqual(set[0] as? String, "bar")
        #endif // !SKIP
    }

    func test_Union() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "foo", "bar", "baz")
        let otherSet = NSOrderedSet(array: ["123", "baz"])
        let otherOtherSet = Set<AnyHashable>(["foo", "456"])
        set.union(otherSet)
        XCTAssertEqual(set.count, 4)
        XCTAssertEqual(set[0] as? String, "foo")
        XCTAssertEqual(set[1] as? String, "bar")
        XCTAssertEqual(set[2] as? String, "baz")
        XCTAssertEqual(set[3] as? String, "123")
        set.unionSet(otherOtherSet)
        XCTAssertEqual(set.count, 5)
        XCTAssertEqual(set[4] as? String, "456")
        #endif // !SKIP
    }

    func test_Initializers() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let copyableObject = NSObject()
        let set = NSMutableOrderedSet(arrayLiteral: copyableObject, "bar", "baz")
        let newSet = NSOrderedSet(orderedSet: set)
        XCTAssert(newSet.isEqual(to: set))
//        XCTAssert(set[0] === newSet[0])

        let unorderedSet = Set<AnyHashable>(["foo", "bar", "baz"])
        let newSetFromUnorderedSet = NSOrderedSet(set: unorderedSet)
        XCTAssertEqual(newSetFromUnorderedSet.count, 3)
        XCTAssert(newSetFromUnorderedSet.contains("foo"))
        #endif // !SKIP
    }

    func test_Sorting() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let set = NSMutableOrderedSet(arrayLiteral: "a", "d", "c", "b")
        set.sort(options: []) { lhs, rhs in
            if let lhs = lhs as? String, let rhs = rhs as? String {
                return lhs.compare(rhs)
            }
            return .orderedSame
        }
        XCTAssertEqual(set[0] as? String, "a")
        XCTAssertEqual(set[1] as? String, "b")
        XCTAssertEqual(set[2] as? String, "c")
        XCTAssertEqual(set[3] as? String, "d")

        set.sortRange(NSRange(location: 1, length: 2), options: []) { lhs, rhs in
            if let lhs = lhs as? String, let rhs = rhs as? String {
                return rhs.compare(lhs)
            }
            return .orderedSame
        }
        XCTAssertEqual(set[0] as? String, "a")
        XCTAssertEqual(set[1] as? String, "c")
        XCTAssertEqual(set[2] as? String, "b")
        XCTAssertEqual(set[3] as? String, "d")
        #endif // !SKIP
    }

    func test_reversedEnumerationMutable() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let arr = ["foo", "bar", "baz"]
        let set = NSMutableOrderedSet()
        set.addObjects(from: arr)

        set.add("jazz")
        var index = set.count - 1
        var revSet = set.reverseObjectEnumerator()
        for item in revSet {
            XCTAssertEqual(set.object(at: index) as? String, item as? String)
            index -= 1
        }

        set.remove("jazz")
        index = set.count - 1
        revSet = set.reverseObjectEnumerator()
        for item in revSet {
            XCTAssertEqual(set.object(at: index) as? String, item as? String)
            index -= 1
        }


        #endif // !SKIP
    }

    func test_reversedOrderedSetMutable() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let days = ["monday", "tuesday", "wednesday", "thursday", "friday"]
        let work =  NSMutableOrderedSet()
        work.addObjects(from: days)
        var krow = work.reversed
        XCTAssertEqual(work.firstObject as? String, krow.lastObject as? String)
        XCTAssertEqual(work.lastObject as? String, krow.firstObject as? String)

        work.add("saturday")
        krow = work.reversed
        XCTAssertEqual(work.firstObject as? String, krow.lastObject as? String)
        XCTAssertEqual(work.lastObject as? String, krow.firstObject as? String)
        #endif // !SKIP
    }

    #if !SKIP
    let fixtures = [
        Fixtures.orderedSetEmpty,
        Fixtures.orderedSetOfNumbers
    ]
    
    let mutableFixtures = [
        Fixtures.mutableOrderedSetEmpty,
        Fixtures.mutableOrderedSetOfNumbers
    ]
    #endif
    
    func test_codingRoundtrip() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
            try fixture.assertValueRoundtripsInCoder()
        }
        for fixture in mutableFixtures {
            try fixture.assertValueRoundtripsInCoder()
        }
        #endif // !SKIP
    }
    
    func test_loadedValuesMatch() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
            try fixture.assertLoadedValuesMatch()
        }
        for fixture in mutableFixtures {
            try fixture.assertLoadedValuesMatch()
        }
        #endif // !SKIP
    }
    
}


