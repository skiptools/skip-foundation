// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestDateInterval: XCTestCase {

    func test_defaultInitializer() {
        let dateInterval = DateInterval()
        XCTAssertEqual(dateInterval.duration, 0.0)
    }

    func test_startEndInitializer() {
        let date1 = dateWithString("2019-04-04 17:09:23 -0700")
        let date2 = dateWithString("2019-04-04 18:09:23 -0700")
        let dateInterval = DateInterval(start: date1, end: date2)
        XCTAssertEqual(dateInterval.duration, 60.0 * 60.0)
    }

    func test_startDurationInitializer() {
        let date = dateWithString("2019-04-04 17:09:23 -0700")
        let dateInterval = DateInterval(start: date, duration: 60.0)
        XCTAssertEqual(dateInterval.duration, 60.0)
    }

    func test_compareDifferentStarts() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let date1 = dateWithString("2019-04-04 17:09:23 -0700")
        let date2 = dateWithString("2019-04-04 18:09:23 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 100)
        let dateInterval2 = DateInterval(start: date2, duration: 100)
        XCTAssertEqual(dateInterval1.compare(dateInterval2), .orderedAscending)
        XCTAssertEqual(dateInterval2.compare(dateInterval1), .orderedDescending)
        #endif // !SKIP
    }

    func test_compareDifferentDurations() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let date = dateWithString("2019-04-04 17:09:23 -0700")
        let dateInterval1 = DateInterval(start: date, duration: 60)
        let dateInterval2 = DateInterval(start: date, duration: 90)
        XCTAssertEqual(dateInterval1.compare(dateInterval2), .orderedAscending)
        XCTAssertEqual(dateInterval2.compare(dateInterval1), .orderedDescending)
        #endif // !SKIP
    }

    func test_compareSame() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let date = dateWithString("2019-04-04 17:09:23 -0700")
        let dateInterval1 = DateInterval(start: date, duration: 60)
        let dateInterval2 = DateInterval(start: date, duration: 60)
        XCTAssertEqual(dateInterval1.compare(dateInterval2), .orderedSame)
        XCTAssertEqual(dateInterval2.compare(dateInterval1), .orderedSame)
        #endif // !SKIP
    }

    func test_comparisonOperators() {
        let date1 = dateWithString("2019-04-04 17:00:00 -0700")
        let date2 = dateWithString("2019-04-04 17:30:00 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 60.0)
        let dateInterval2 = DateInterval(start: date2, duration: 60.0)
        let dateInterval3 = DateInterval(start: date1, duration: 90.0)
        let dateInterval4 = DateInterval(start: date1, duration: 60.0)
        XCTAssertTrue(dateInterval1 < dateInterval2)
        XCTAssertTrue(dateInterval1 < dateInterval3)
        XCTAssertTrue(dateInterval1 == dateInterval4)
    }

    func test_intersects() {
        let date1 = dateWithString("2019-04-04 17:09:23 -0700")
        let date2 = dateWithString("2019-04-04 17:10:20 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 60.0)
        let dateInterval2 = DateInterval(start: date2, duration: 15.0)
        XCTAssertTrue(dateInterval1.intersects(dateInterval2))
    }

    func test_intersection() {
        let date1 = dateWithString("2019-04-04 17:00:00 -0700")
        let date2 = dateWithString("2019-04-04 17:15:00 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 60.0 * 30.0)
        let dateInterval2 = DateInterval(start: date2, duration: 60.0 * 30.0)
        let intersection = dateInterval1.intersection(with: dateInterval2)
        XCTAssertNotNil(intersection)
        XCTAssertEqual(intersection!.duration, 60.0 * 15.0)
    }

    func test_intersectionZeroDuration() {
        let date1 = dateWithString("2019-04-04 17:00:00 -0700")
        let date2 = dateWithString("2019-04-04 17:30:00 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 60.0 * 30.0)
        let dateInterval2 = DateInterval(start: date2, duration: 60.0 * 30.0)
        let intersection = dateInterval1.intersection(with: dateInterval2)
        XCTAssertNotNil(intersection)
        XCTAssertEqual(intersection!.duration, 0.0)
    }

    func test_intersectionNil() {
        let date1 = dateWithString("2019-04-04 17:00:00 -0700")
        let date2 = dateWithString("2019-04-04 17:30:01 -0700")
        let dateInterval1 = DateInterval(start: date1, duration: 60.0 * 30.0)
        let dateInterval2 = DateInterval(start: date2, duration: 60.0 * 30.0)
        XCTAssertNil(dateInterval1.intersection(with: dateInterval2))
    }

    func test_contains() {
        let date0 = dateWithString("1964-10-01 06:00:00 +0900")
        let date1 = dateWithString("2019-04-04 17:00:00 -0700")
        let date2 = dateWithString("2019-04-04 17:30:00 -0700")
        let date3 = dateWithString("2019-04-04 17:45:00 -0700")
        let date4 = dateWithString("2019-04-04 17:50:00 -0700")

        XCTAssertTrue(DateInterval(start: .distantPast, end: .distantFuture).contains(date0))
        XCTAssertTrue(DateInterval(start: .distantPast, end: date1).contains(date0))
        XCTAssertFalse(DateInterval(start: .distantPast, end: date1).contains(date2))
        XCTAssertTrue(DateInterval(start: date0, end: date4).contains(date2))
        XCTAssertTrue(DateInterval(start: date1, duration: 60.0 * 45.0).contains(date3))
        XCTAssertFalse(DateInterval(start: date1, duration: 60.0 * 45.0).contains(date4))
        XCTAssertTrue(DateInterval(start: date2, end: .distantFuture).contains(date2))
        XCTAssertFalse(DateInterval(start: date2, end: .distantFuture).contains(date0))
    }

    func test_hashing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        guard #available(iOS 10.10, OSX 10.12, tvOS 10.0, watchOS 3.0, *) else { return }

        let start1a = dateWithString("2019-04-04 17:09:23 -0700")
        let start1b = dateWithString("2019-04-04 17:09:23 -0700")
        let start2a = Date(timeIntervalSinceReferenceDate: start1a.timeIntervalSinceReferenceDate.nextUp)
        let start2b = Date(timeIntervalSinceReferenceDate: start1a.timeIntervalSinceReferenceDate.nextUp)
        let duration1 = 1800.0
        let duration2 = duration1.nextUp
        let intervals: [[DateInterval]] = [
            [
                DateInterval(start: start1a, duration: duration1),
                DateInterval(start: start1b, duration: duration1),
            ],
            [
                DateInterval(start: start1a, duration: duration2),
                DateInterval(start: start1b, duration: duration2),
            ],
            [
                DateInterval(start: start2a, duration: duration1),
                DateInterval(start: start2b, duration: duration1),
            ],
            [
                DateInterval(start: start2a, duration: duration2),
                DateInterval(start: start2b, duration: duration2),
            ],
        ]
        checkHashableGroups(intervals)
        #endif // !SKIP
    }
}


