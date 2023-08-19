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
// Copyright (c) 2014 - 2016, 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestIndexPath: XCTestCase {
    
    func testEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip = IndexPath()
        XCTAssertEqual(ip.count, 0)

        // Darwin allows nil if length is 0
        let nsip = NSIndexPath(indexes: nil, length: 0)
        XCTAssertEqual(nsip.length, 0)
        let newIp = nsip.adding(1)
        XCTAssertEqual(newIp.count, 1)
        #endif // !SKIP
    }
    
    func testSingleIndex() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip = IndexPath(index: 1)
        XCTAssertEqual(ip.count, 1)
        XCTAssertEqual(ip[0], 1)
        
        let highValueIp = IndexPath(index: .max)
        XCTAssertEqual(highValueIp.count, 1)
        XCTAssertEqual(highValueIp[0], .max)
        
        let lowValueIp = IndexPath(index: .min)
        XCTAssertEqual(lowValueIp.count, 1)
        XCTAssertEqual(lowValueIp[0], .min)
        #endif // !SKIP
    }
    
    func testTwoIndexes() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip = IndexPath(indexes: [0, 1])
        XCTAssertEqual(ip.count, 2)
        XCTAssertEqual(ip[0], 0)
        XCTAssertEqual(ip[1], 1)
        #endif // !SKIP
    }
    
    func testManyIndexes() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip = IndexPath(indexes: [0, 1, 2, 3, 4])
        XCTAssertEqual(ip.count, 5)
        XCTAssertEqual(ip[0], 0)
        XCTAssertEqual(ip[1], 1)
        XCTAssertEqual(ip[2], 2)
        XCTAssertEqual(ip[3], 3)
        XCTAssertEqual(ip[4], 4)
        #endif // !SKIP
    }
    
    func testCreateFromSequence() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let seq = repeatElement(5, count: 3)
        let ip = IndexPath(indexes: seq)
        XCTAssertEqual(ip.count, 3)
        XCTAssertEqual(ip[0], 5)
        XCTAssertEqual(ip[1], 5)
        XCTAssertEqual(ip[2], 5)
        #endif // !SKIP
    }
    
    func testCreateFromLiteral() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3, 4]
        XCTAssertEqual(ip.count, 4)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        XCTAssertEqual(ip[2], 3)
        XCTAssertEqual(ip[3], 4)
        #endif // !SKIP
    }
    
    func testDropLast() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3, 4]
        let ip2 = ip.dropLast()
        XCTAssertEqual(ip2.count, 3)
        XCTAssertEqual(ip2[0], 1)
        XCTAssertEqual(ip2[1], 2)
        XCTAssertEqual(ip2[2], 3)
        #endif // !SKIP
    }
    
    func testDropLastFromEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = []
        let ip2 = ip.dropLast()
        XCTAssertEqual(ip2.count, 0)
        #endif // !SKIP
    }
    
    func testDropLastFromSingle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1]
        let ip2 = ip.dropLast()
        XCTAssertEqual(ip2.count, 0)
        #endif // !SKIP
    }
    
    func testDropLastFromPair() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2]
        let ip2 = ip.dropLast()
        XCTAssertEqual(ip2.count, 1)
        XCTAssertEqual(ip2[0], 1)
        #endif // !SKIP
    }
    
    func testDropLastFromTriple() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3]
        let ip2 = ip.dropLast()
        XCTAssertEqual(ip2.count, 2)
        XCTAssertEqual(ip2[0], 1)
        XCTAssertEqual(ip2[1], 2)
        #endif // !SKIP
    }
    
    func testStartEndIndex() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3, 4]
        XCTAssertEqual(ip.startIndex, 0)
        XCTAssertEqual(ip.endIndex, ip.count)
        #endif // !SKIP
    }
    
    func testIterator() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3, 4]
        var iter = ip.makeIterator()
        var sum = 0
        while let index = iter.next() {
            sum += index
        }
        XCTAssertEqual(sum, 1 + 2 + 3 + 4)
        #endif // !SKIP
    }
    
    func testIndexing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip: IndexPath = [1, 2, 3, 4]
        XCTAssertEqual(ip.index(before: 1), 0)
        XCTAssertEqual(ip.index(before: 0), -1) // beyond range!
        XCTAssertEqual(ip.index(after: 1), 2)
        XCTAssertEqual(ip.index(after: 4), 5) // beyond range!
        #endif // !SKIP
    }
    
    func testCompare() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1: IndexPath = [1, 2]
        let ip2: IndexPath = [3, 4]
        let ip3: IndexPath = [5, 1]
        let ip4: IndexPath = [1, 1, 1]
        let ip5: IndexPath = [1, 1, 9]
        
        XCTAssertEqual(ip1.compare(ip1), .orderedSame)
        XCTAssertEqual(ip1 < ip1, false)
        XCTAssertEqual(ip1 <= ip1, true)
        XCTAssertEqual(ip1 == ip1, true)
        XCTAssertEqual(ip1 >= ip1, true)
        XCTAssertEqual(ip1 > ip1, false)
        
        XCTAssertEqual(ip1.compare(ip2), .orderedAscending)
        XCTAssertEqual(ip1 < ip2, true)
        XCTAssertEqual(ip1 <= ip2, true)
        XCTAssertEqual(ip1 == ip2, false)
        XCTAssertEqual(ip1 >= ip2, false)
        XCTAssertEqual(ip1 > ip2, false)
        
        XCTAssertEqual(ip1.compare(ip3), .orderedAscending)
        XCTAssertEqual(ip1 < ip3, true)
        XCTAssertEqual(ip1 <= ip3, true)
        XCTAssertEqual(ip1 == ip3, false)
        XCTAssertEqual(ip1 >= ip3, false)
        XCTAssertEqual(ip1 > ip3, false)
        
        XCTAssertEqual(ip1.compare(ip4), .orderedDescending)
        XCTAssertEqual(ip1 < ip4, false)
        XCTAssertEqual(ip1 <= ip4, false)
        XCTAssertEqual(ip1 == ip4, false)
        XCTAssertEqual(ip1 >= ip4, true)
        XCTAssertEqual(ip1 > ip4, true)
        
        XCTAssertEqual(ip1.compare(ip5), .orderedDescending)
        XCTAssertEqual(ip1 < ip5, false)
        XCTAssertEqual(ip1 <= ip5, false)
        XCTAssertEqual(ip1 == ip5, false)
        XCTAssertEqual(ip1 >= ip5, true)
        XCTAssertEqual(ip1 > ip5, true)
        
        XCTAssertEqual(ip2.compare(ip1), .orderedDescending)
        XCTAssertEqual(ip2 < ip1, false)
        XCTAssertEqual(ip2 <= ip1, false)
        XCTAssertEqual(ip2 == ip1, false)
        XCTAssertEqual(ip2 >= ip1, true)
        XCTAssertEqual(ip2 > ip1, true)
        
        XCTAssertEqual(ip2.compare(ip2), .orderedSame)
        XCTAssertEqual(ip2 < ip2, false)
        XCTAssertEqual(ip2 <= ip2, true)
        XCTAssertEqual(ip2 == ip2, true)
        XCTAssertEqual(ip2 >= ip2, true)
        XCTAssertEqual(ip2 > ip2, false)
        
        XCTAssertEqual(ip2.compare(ip3), .orderedAscending)
        XCTAssertEqual(ip2 < ip3, true)
        XCTAssertEqual(ip2 <= ip3, true)
        XCTAssertEqual(ip2 == ip3, false)
        XCTAssertEqual(ip2 >= ip3, false)
        XCTAssertEqual(ip2 > ip3, false)
        
        XCTAssertEqual(ip2.compare(ip4), .orderedDescending)
        XCTAssertEqual(ip2.compare(ip5), .orderedDescending)
        XCTAssertEqual(ip3.compare(ip1), .orderedDescending)
        XCTAssertEqual(ip3.compare(ip2), .orderedDescending)
        XCTAssertEqual(ip3.compare(ip3), .orderedSame)
        XCTAssertEqual(ip3.compare(ip4), .orderedDescending)
        XCTAssertEqual(ip3.compare(ip5), .orderedDescending)
        XCTAssertEqual(ip4.compare(ip1), .orderedAscending)
        XCTAssertEqual(ip4.compare(ip2), .orderedAscending)
        XCTAssertEqual(ip4.compare(ip3), .orderedAscending)
        XCTAssertEqual(ip4.compare(ip4), .orderedSame)
        XCTAssertEqual(ip4.compare(ip5), .orderedAscending)
        XCTAssertEqual(ip5.compare(ip1), .orderedAscending)
        XCTAssertEqual(ip5.compare(ip2), .orderedAscending)
        XCTAssertEqual(ip5.compare(ip3), .orderedAscending)
        XCTAssertEqual(ip5.compare(ip4), .orderedDescending)
        XCTAssertEqual(ip5.compare(ip5), .orderedSame)
        
        let ip6: IndexPath = [1, 1]
        XCTAssertEqual(ip6.compare(ip5), .orderedAscending)
        XCTAssertEqual(ip5.compare(ip6), .orderedDescending)
        #endif // !SKIP
    }
    
    func testHashing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let samples: [IndexPath] = [
            [],
            [1],
            [2],
            [Int.max],
            [1, 1],
            [2, 1],
            [1, 2],
            [1, 1, 1],
            [2, 1, 1],
            [1, 2, 1],
            [1, 1, 2],
            [Int.max, Int.max, Int.max],
        ]
        checkHashable(samples, equalityOracle: { $0 == $1 })
 
        // this should not cause an overflow crash
        let hash: Int? = IndexPath(indexes: [Int.max >> 8, 2, Int.max >> 36]).hashValue
        XCTAssertNotNil(hash)
        #endif // !SKIP
    }
    
    func testEquality() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1: IndexPath = [1, 1]
        let ip2: IndexPath = [1, 1]
        let ip3: IndexPath = [1, 1, 1]
        let ip4: IndexPath = []
        let ip5: IndexPath = [1]
        
        XCTAssertTrue(ip1 == ip2)
        XCTAssertFalse(ip1 == ip3)
        XCTAssertFalse(ip1 == ip4)
        XCTAssertFalse(ip4 == ip1)
        XCTAssertFalse(ip5 == ip1)
        XCTAssertFalse(ip5 == ip4)
        XCTAssertTrue(ip4 == ip4)
        XCTAssertTrue(ip5 == ip5)
        #endif // !SKIP
    }
    
    func testSubscripting() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip1: IndexPath = [1]
        var ip2: IndexPath = [1, 2]
        var ip3: IndexPath = [1, 2, 3]
        
        XCTAssertEqual(ip1[0], 1)
        
        XCTAssertEqual(ip2[0], 1)
        XCTAssertEqual(ip2[1], 2)
        
        XCTAssertEqual(ip3[0], 1)
        XCTAssertEqual(ip3[1], 2)
        XCTAssertEqual(ip3[2], 3)
        
        ip1[0] = 2
        XCTAssertEqual(ip1[0], 2)
        
        ip2[0] = 2
        ip2[1] = 3
        XCTAssertEqual(ip2[0], 2)
        XCTAssertEqual(ip2[1], 3)
        
        ip3[0] = 2
        ip3[1] = 3
        ip3[2] = 4
        XCTAssertEqual(ip3[0], 2)
        XCTAssertEqual(ip3[1], 3)
        XCTAssertEqual(ip3[2], 4)
        
        let ip4 = ip3[0..<2]
        XCTAssertEqual(ip4.count, 2)
        XCTAssertEqual(ip4[0], 2)
        XCTAssertEqual(ip4[1], 3)

        let ip5 = ip3[1...]
        XCTAssertEqual(ip5.count, 2)
        XCTAssertEqual(ip5[0], 3)
        XCTAssertEqual(ip5[1], 4)

        let ip6 = ip3[2...]
        XCTAssertEqual(ip6.count, 1)
        XCTAssertEqual(ip6[0], 4)
        #endif // !SKIP
    }
    
    func testAppending() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip : IndexPath = [1, 2, 3, 4]
        let ip2 = IndexPath(indexes: [5, 6, 7])
        
        ip.append(ip2)
        
        XCTAssertEqual(ip.count, 7)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[6], 7)
        
        let ip3 = ip.appending(IndexPath(indexes: [8, 9]))
        XCTAssertEqual(ip3.count, 9)
        XCTAssertEqual(ip3[7], 8)
        XCTAssertEqual(ip3[8], 9)
        
        let ip4 = ip3.appending([10, 11])
        XCTAssertEqual(ip4.count, 11)
        XCTAssertEqual(ip4[9], 10)
        XCTAssertEqual(ip4[10], 11)
        
        let ip5 = ip.appending(8)
        XCTAssertEqual(ip5.count, 8)
        XCTAssertEqual(ip5[7], 8)
        #endif // !SKIP
    }
    
    func testAppendEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(1)
        
        XCTAssertEqual(ip.count, 1)
        XCTAssertEqual(ip[0], 1)
        
        ip.append(2)
        XCTAssertEqual(ip.count, 2)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        
        ip.append(3)
        XCTAssertEqual(ip.count, 3)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        XCTAssertEqual(ip[2], 3)
        
        ip.append(4)
        XCTAssertEqual(ip.count, 4)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        XCTAssertEqual(ip[2], 3)
        XCTAssertEqual(ip[3], 4)
        #endif // !SKIP
    }
    
    func testAppendEmptyIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(IndexPath(indexes: []))
        
        XCTAssertEqual(ip.count, 0)
        #endif // !SKIP
    }
    
    func testAppendManyIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(IndexPath(indexes: [1, 2, 3]))
        
        XCTAssertEqual(ip.count, 3)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        XCTAssertEqual(ip[2], 3)
        #endif // !SKIP
    }
    
    func testAppendEmptyIndexPathToSingle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = [1]
        ip.append(IndexPath(indexes: []))
        
        XCTAssertEqual(ip.count, 1)
        XCTAssertEqual(ip[0], 1)
        #endif // !SKIP
    }
    
    func testAppendSingleIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(IndexPath(indexes: [1]))
        
        XCTAssertEqual(ip.count, 1)
        XCTAssertEqual(ip[0], 1)
        #endif // !SKIP
    }
    
    func testAppendSingleIndexPathToSingle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = [1]
        ip.append(IndexPath(indexes: [1]))
        
        XCTAssertEqual(ip.count, 2)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 1)
        #endif // !SKIP
    }
    
    func testAppendPairIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(IndexPath(indexes: [1, 2]))
        
        XCTAssertEqual(ip.count, 2)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        #endif // !SKIP
    }
    
    func testAppendManyIndexPathToEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = []
        ip.append(IndexPath(indexes: [1, 2, 3]))
        
        XCTAssertEqual(ip.count, 3)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[1], 2)
        XCTAssertEqual(ip[2], 3)
        #endif // !SKIP
    }
    
    func testAppendByOperator() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1: IndexPath = []
        let ip2: IndexPath = []
        
        let ip3 = ip1 + ip2
        XCTAssertEqual(ip3.count, 0)
        
        let ip4: IndexPath = [1]
        let ip5: IndexPath = [2]
        
        let ip6 = ip4 + ip5
        XCTAssertEqual(ip6.count, 2)
        XCTAssertEqual(ip6[0], 1)
        XCTAssertEqual(ip6[1], 2)
        
        var ip7: IndexPath = []
        ip7 += ip6
        XCTAssertEqual(ip7.count, 2)
        XCTAssertEqual(ip7[0], 1)
        XCTAssertEqual(ip7[1], 2)
        #endif // !SKIP
    }
    
    func testAppendArray() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip: IndexPath = [1, 2, 3, 4]
        let indexes = [5, 6, 7]
        
        ip.append(indexes)
        
        XCTAssertEqual(ip.count, 7)
        XCTAssertEqual(ip[0], 1)
        XCTAssertEqual(ip[6], 7)
        #endif // !SKIP
    }
    
    func testRanges() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1 = IndexPath(indexes: [1, 2, 3])
        let ip2 = IndexPath(indexes: [6, 7, 8])
        
        // Replace the whole range
        var mutateMe = ip1
        mutateMe[0..<3] = ip2
        XCTAssertEqual(mutateMe, ip2)
        
        // Insert at the beginning
        mutateMe = ip1
        mutateMe[0..<0] = ip2
        XCTAssertEqual(mutateMe, IndexPath(indexes: [6, 7, 8, 1, 2, 3]))
        
        // Insert at the end
        mutateMe = ip1
        mutateMe[3..<3] = ip2
        XCTAssertEqual(mutateMe, IndexPath(indexes: [1, 2, 3, 6, 7, 8]))
        
        // Insert in middle
        mutateMe = ip1
        mutateMe[2..<2] = ip2
        XCTAssertEqual(mutateMe, IndexPath(indexes: [1, 2, 6, 7, 8, 3]))
        #endif // !SKIP
    }
    
    func testRangeFromEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1 = IndexPath()
        let ip2 = ip1[0..<0]
        XCTAssertEqual(ip2.count, 0)
        #endif // !SKIP
    }
    
    func testRangeFromSingle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1 = IndexPath(indexes: [1])
        let ip2 = ip1[0..<0]
        XCTAssertEqual(ip2.count, 0)
        let ip3 = ip1[0..<1]
        XCTAssertEqual(ip3.count, 1)
        XCTAssertEqual(ip3[0], 1)
        #endif // !SKIP
    }
    
    func testRangeFromPair() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1 = IndexPath(indexes: [1, 2])
        let ip2 = ip1[0..<0]
        XCTAssertEqual(ip2.count, 0)
        let ip3 = ip1[0..<1]
        XCTAssertEqual(ip3.count, 1)
        XCTAssertEqual(ip3[0], 1)
        let ip4 = ip1[1..<1]
        XCTAssertEqual(ip4.count, 0)
        let ip5 = ip1[0..<2]
        XCTAssertEqual(ip5.count, 2)
        XCTAssertEqual(ip5[0], 1)
        XCTAssertEqual(ip5[1], 2)
        let ip6 = ip1[1..<2]
        XCTAssertEqual(ip6.count, 1)
        XCTAssertEqual(ip6[0], 2)
        let ip7 = ip1[2..<2]
        XCTAssertEqual(ip7.count, 0)
        #endif // !SKIP
    }
    
    func testRangeFromMany() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1 = IndexPath(indexes: [1, 2, 3])
        let ip2 = ip1[0..<0]
        XCTAssertEqual(ip2.count, 0)
        let ip3 = ip1[0..<1]
        XCTAssertEqual(ip3.count, 1)
        let ip4 = ip1[0..<2]
        XCTAssertEqual(ip4.count, 2)
        let ip5 = ip1[0..<3]
        XCTAssertEqual(ip5.count, 3)
        #endif // !SKIP
    }
    
    func testRangeReplacementSingle() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip1 = IndexPath(indexes: [1])
        ip1[0..<1] = IndexPath(indexes: [2])
        XCTAssertEqual(ip1[0], 2)
        
        ip1[0..<1] = IndexPath(indexes: [])
        XCTAssertEqual(ip1.count, 0)
        #endif // !SKIP
    }
    
    func testRangeReplacementPair() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip1 = IndexPath(indexes: [1, 2])
        ip1[0..<1] = IndexPath(indexes: [2, 3])
        XCTAssertEqual(ip1.count, 3)
        XCTAssertEqual(ip1[0], 2)
        XCTAssertEqual(ip1[1], 3)
        XCTAssertEqual(ip1[2], 2)
        
        ip1[0..<1] = IndexPath(indexes: [])
        XCTAssertEqual(ip1.count, 2)
        #endif // !SKIP
    }
    
    func testMoreRanges() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var ip = IndexPath(indexes: [1, 2, 3])
        let ip2 = IndexPath(indexes: [5, 6, 7, 8, 9, 10])
        
        ip[1..<2] = ip2
        XCTAssertEqual(ip, IndexPath(indexes: [1, 5, 6, 7, 8, 9, 10, 3]))
        #endif // !SKIP
    }
    
    func testIteration() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip = IndexPath(indexes: [1, 2, 3])
        
        var count = 0
        for _ in ip {
            count += 1
        }
        
        XCTAssertEqual(3, count)
        #endif // !SKIP
    }
    
    func testDescription() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1: IndexPath = []
        let ip2: IndexPath = [1]
        let ip3: IndexPath = [1, 2]
        let ip4: IndexPath = [1, 2, 3]
        
        XCTAssertEqual(ip1.description, "[]")
        XCTAssertEqual(ip2.description, "[1]")
        XCTAssertEqual(ip3.description, "[1, 2]")
        XCTAssertEqual(ip4.description, "[1, 2, 3]")
        
        XCTAssertEqual(ip1.debugDescription, ip1.description)
        XCTAssertEqual(ip2.debugDescription, ip2.description)
        XCTAssertEqual(ip3.debugDescription, ip3.description)
        XCTAssertEqual(ip4.debugDescription, ip4.description)
        #endif // !SKIP
    }
    
    func testBridgeToObjC() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let ip1: IndexPath = []
        let ip2: IndexPath = [1]
        let ip3: IndexPath = [1, 2]
        let ip4: IndexPath = [1, 2, 3]
        
        let nsip1 = ip1._bridgeToObjectiveC()
        let nsip2 = ip2._bridgeToObjectiveC()
        let nsip3 = ip3._bridgeToObjectiveC()
        let nsip4 = ip4._bridgeToObjectiveC()
        
        XCTAssertEqual(nsip1.length, 0)
        XCTAssertEqual(nsip2.length, 1)
        XCTAssertEqual(nsip3.length, 2)
        XCTAssertEqual(nsip4.length, 3)
        #endif // !SKIP
    }
    
    func testForceBridgeFromObjC() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let nsip1 = NSIndexPath()
        let nsip2 = NSIndexPath(index: 1)
        let nsip3 = [1, 2].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        let nsip4 = [1, 2, 3].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        
        var ip1: IndexPath?
        IndexPath._forceBridgeFromObjectiveC(nsip1, result: &ip1)
        XCTAssertNotNil(ip1)
        XCTAssertEqual(ip1!.count, 0)
        
        var ip2: IndexPath?
        IndexPath._forceBridgeFromObjectiveC(nsip2, result: &ip2)
        XCTAssertNotNil(ip2)
        XCTAssertEqual(ip2!.count, 1)
        XCTAssertEqual(ip2![0], 1)
        
        var ip3: IndexPath?
        IndexPath._forceBridgeFromObjectiveC(nsip3, result: &ip3)
        XCTAssertNotNil(ip3)
        XCTAssertEqual(ip3!.count, 2)
        XCTAssertEqual(ip3![0], 1)
        XCTAssertEqual(ip3![1], 2)
        
        var ip4: IndexPath?
        IndexPath._forceBridgeFromObjectiveC(nsip4, result: &ip4)
        XCTAssertNotNil(ip4)
        XCTAssertEqual(ip4!.count, 3)
        XCTAssertEqual(ip4![0], 1)
        XCTAssertEqual(ip4![1], 2)
        XCTAssertEqual(ip4![2], 3)
        #endif // !SKIP
    }
    
    func testConditionalBridgeFromObjC() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let nsip1 = NSIndexPath()
        let nsip2 = NSIndexPath(index: 1)
        let nsip3 = [1, 2].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        let nsip4 = [1, 2, 3].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        
        var ip1: IndexPath?
        XCTAssertTrue(IndexPath._conditionallyBridgeFromObjectiveC(nsip1, result: &ip1))
        XCTAssertNotNil(ip1)
        XCTAssertEqual(ip1!.count, 0)
        
        var ip2: IndexPath?
        XCTAssertTrue(IndexPath._conditionallyBridgeFromObjectiveC(nsip2, result: &ip2))
        XCTAssertNotNil(ip2)
        XCTAssertEqual(ip2!.count, 1)
        XCTAssertEqual(ip2![0], 1)
        
        var ip3: IndexPath?
        XCTAssertTrue(IndexPath._conditionallyBridgeFromObjectiveC(nsip3, result: &ip3))
        XCTAssertNotNil(ip3)
        XCTAssertEqual(ip3!.count, 2)
        XCTAssertEqual(ip3![0], 1)
        XCTAssertEqual(ip3![1], 2)
        
        var ip4: IndexPath?
        XCTAssertTrue(IndexPath._conditionallyBridgeFromObjectiveC(nsip4, result: &ip4))
        XCTAssertNotNil(ip4)
        XCTAssertEqual(ip4!.count, 3)
        XCTAssertEqual(ip4![0], 1)
        XCTAssertEqual(ip4![1], 2)
        XCTAssertEqual(ip4![2], 3)
        #endif // !SKIP
    }
    
    func testUnconditionalBridgeFromObjC() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let nsip1 = NSIndexPath()
        let nsip2 = NSIndexPath(index: 1)
        let nsip3 = [1, 2].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        let nsip4 = [1, 2, 3].withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Int>) -> NSIndexPath in
            return NSIndexPath(indexes: buffer.baseAddress, length: buffer.count)
        }
        
        let ip1: IndexPath = IndexPath._unconditionallyBridgeFromObjectiveC(nsip1)
        XCTAssertEqual(ip1.count, 0)
        
        let ip2: IndexPath = IndexPath._unconditionallyBridgeFromObjectiveC(nsip2)
        XCTAssertEqual(ip2.count, 1)
        XCTAssertEqual(ip2[0], 1)
        
        let ip3: IndexPath = IndexPath._unconditionallyBridgeFromObjectiveC(nsip3)
        XCTAssertEqual(ip3.count, 2)
        XCTAssertEqual(ip3[0], 1)
        XCTAssertEqual(ip3[1], 2)
        
        let ip4: IndexPath = IndexPath._unconditionallyBridgeFromObjectiveC(nsip4)
        XCTAssertEqual(ip4.count, 3)
        XCTAssertEqual(ip4[0], 1)
        XCTAssertEqual(ip4[1], 2)
        XCTAssertEqual(ip4[2], 3)
        #endif // !SKIP
    }
    
    func testObjcBridgeType() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertTrue(IndexPath._getObjectiveCType() == NSIndexPath.self)
        #endif // !SKIP
    }
    
    func test_AnyHashableContainingIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let values: [IndexPath] = [
            IndexPath(indexes: [1, 2]),
            IndexPath(indexes: [1, 2, 3]),
            IndexPath(indexes: [1, 2, 3]),
            ]
        let anyHashables = values.map(AnyHashable.init)
        XCTAssert(IndexPath.self == type(of: anyHashables[0].base))
        XCTAssert(IndexPath.self == type(of: anyHashables[1].base))
        XCTAssert(IndexPath.self == type(of: anyHashables[2].base))
        XCTAssertNotEqual(anyHashables[0], anyHashables[1])
        XCTAssertEqual(anyHashables[1], anyHashables[2])
        #endif // !SKIP
    }
    
    func test_AnyHashableCreatedFromNSIndexPath() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let values: [NSIndexPath] = [
            NSIndexPath(index: 1),
            NSIndexPath(index: 2),
            NSIndexPath(index: 2),
            ]
        let anyHashables = values.map(AnyHashable.init)
        XCTAssert(IndexPath.self == type(of: anyHashables[0].base))
        XCTAssert(IndexPath.self == type(of: anyHashables[1].base))
        XCTAssert(IndexPath.self == type(of: anyHashables[2].base))
        XCTAssertNotEqual(anyHashables[0], anyHashables[1])
        XCTAssertEqual(anyHashables[1], anyHashables[2])
        #endif // !SKIP
    }
    
    func test_unconditionallyBridgeFromObjectiveC() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertEqual(IndexPath(), IndexPath._unconditionallyBridgeFromObjectiveC(nil))
        #endif // !SKIP
    }
    
    func test_slice_1ary() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let indexPath: IndexPath = [0]
        let res = indexPath.dropFirst()
        XCTAssertEqual(0, res.count)
        
        let slice = indexPath[1..<1]
        XCTAssertEqual(0, slice.count)
        #endif // !SKIP
    }

    func test_copy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var indexes = [1, 2, 3]
        let nip1 = NSIndexPath(indexes: &indexes, length: 3)
        let nip2 = nip1
        XCTAssertEqual(nip1.length, 3)
        XCTAssertEqual(nip2.length, 3)
        XCTAssertEqual(nip1, nip2)
        #endif // !SKIP
    }

    #if !SKIP
    let fixtures: [TypedFixture<NSIndexPath>] = [
        Fixtures.indexPathEmpty,
        Fixtures.indexPathOneIndex,
        Fixtures.indexPathManyIndices,
    ]
    #endif
    
    func testCodingRoundtrip() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
            try fixture.assertValueRoundtripsInCoder()
        }
        #endif // !SKIP
    }
    
    func testLoadedValuesMatch() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
//            try fixture.assertLoadedValuesMatch()
        }
        #endif // !SKIP
    }
    

}


