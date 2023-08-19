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

class TestNSCompoundPredicate: XCTestCase {
    

    private func eval(_ predicate: NSPredicate, object: NSObject = NSObject()) -> Bool {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        return predicate.evaluate(with: object, substitutionVariables: nil)
        #endif // !SKIP
    }

    func test_NotPredicate() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let notTruePredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(value: true))
        let notFalsePredicate = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(value: false))

        XCTAssertFalse(eval(notTruePredicate))
        XCTAssertTrue(eval(notFalsePredicate))
        #endif // !SKIP
    }

    func test_AndPredicateWithNoSubpredicates() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])

        XCTAssertTrue(eval(predicate))
        #endif // !SKIP
    }

    func test_AndPredicateWithOneSubpredicate() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let truePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(value: true)])
        let falsePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(value: false)])

        XCTAssertTrue(eval(truePredicate))
        XCTAssertFalse(eval(falsePredicate))
        #endif // !SKIP
    }

    func test_AndPredicateWithMultipleSubpredicates() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let truePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(value: true), NSPredicate(value: true)])
        let falsePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(value: true), NSPredicate(value: false)])

        XCTAssertTrue(eval(truePredicate))
        XCTAssertFalse(eval(falsePredicate))
        #endif // !SKIP
    }


    func test_OrPredicateWithNoSubpredicates() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [])

        XCTAssertFalse(eval(predicate))
        #endif // !SKIP
    }

    func test_OrPredicateWithOneSubpredicate() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let truePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(value: true)])
        let falsePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(value: false)])

        XCTAssertTrue(eval(truePredicate))
        XCTAssertFalse(eval(falsePredicate))
        #endif // !SKIP
    }

    func test_OrPredicateWithMultipleSubpredicates() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let truePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(value: true), NSPredicate(value: false)])
        let falsePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(value: false), NSPredicate(value: false)])

        XCTAssertTrue(eval(truePredicate))
        XCTAssertFalse(eval(falsePredicate))
        #endif // !SKIP
    }

    func test_AndPredicateShortCircuits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var shortCircuited = true

        let bOK = NSPredicate(value: false)
        let bDontEval = NSPredicate(block: { (_, _) in
            shortCircuited = false
            return true
        })

        let both = NSCompoundPredicate(andPredicateWithSubpredicates: [bOK, bDontEval])
        XCTAssertFalse(eval(both))
        XCTAssertTrue(shortCircuited)
        #endif // !SKIP
    }

    func test_OrPredicateShortCircuits() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var shortCircuited = true

        let bOK = NSPredicate(value: true)
        let bDontEval = NSPredicate(block: { (_, _) in
            shortCircuited = false
            return true
        })

        let both = NSCompoundPredicate(orPredicateWithSubpredicates: [bOK, bDontEval])
        XCTAssertTrue(eval(both))
        XCTAssertTrue(shortCircuited)
        #endif // !SKIP
    }
}


