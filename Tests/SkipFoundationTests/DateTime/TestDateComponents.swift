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
// Copyright (c) 2014 - 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestDateComponents: XCTestCase {

    func test_hash() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        let c1 = DateComponents(year: 2018, month: 8, day: 1)
//        let c2 = DateComponents(year: 2018, month: 8, day: 1)
//
//        XCTAssertEqual(c1, c2)
//        XCTAssertEqual(c1.hashValue, c2.hashValue)
//
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.calendar,
//            throughValues: [
//                Calendar(identifier: .gregorian),
//                Calendar(identifier: .buddhist),
//                Calendar(identifier: .chinese),
//                Calendar(identifier: .coptic),
//                Calendar(identifier: .hebrew),
//                Calendar(identifier: .indian),
//                Calendar(identifier: .islamic),
//                Calendar(identifier: .iso8601),
//                Calendar(identifier: .japanese),
//                Calendar(identifier: .persian)
//            ])
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.timeZone,
//            throughValues: (-10...10).map { TimeZone(secondsFromGMT: 3600 * $0) })
//        // Note: These assume components aren't range checked.
//        let integers: [Int?] = (0..<20).map { $0 as Int? }
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.era,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.year,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.quarter,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.month,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.day,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.hour,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.minute,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.second,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.nanosecond,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.weekOfYear,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.weekOfMonth,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.yearForWeekOfYear,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.weekday,
//            throughValues: integers)
//        checkHashing_ValueType(
//            initialValue: DateComponents(),
//            byMutating: \DateComponents.weekdayOrdinal,
//            throughValues: integers)
//        // isLeapMonth does not have enough values to test it here.
        #endif // !SKIP
    }

    func test_isValidDate() throws {
        // SR-11569
        let calendarTimeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let dateComponentsTimeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 3600))

        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = calendarTimeZone

        var dc = DateComponents()
        dc.calendar = calendar
        dc.timeZone = dateComponentsTimeZone
        dc.year = 2019
        dc.month = 1
        dc.day = 2
        dc.hour = 3
        dc.minute = 4
        dc.second = 5
        #if !SKIP // nanosecond unsupported in Skip due to no field in java.util.Calendar
        dc.nanosecond = 6
        #endif
        XCTAssertTrue(dc.isValidDate)
    }

}


