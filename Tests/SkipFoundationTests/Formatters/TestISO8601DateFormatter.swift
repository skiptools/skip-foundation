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

class TestISO8601DateFormatter: XCTestCase {
    // Difference in Foundation and Robolectric Java week formatting: Java is offset by 1
    // Difference in handling of fractional seconds between Robolectric Java and Foundation
    // Note that Android is correct for fractional seconds, whereas the local Java used by Robolectric is wrong
    let wk = isJava ? "W41" : "W40"
    let fs = isRobolectric ? "713" : "071"

    func test_stringFromDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss.SSSS zzz"
        let dateString = "2016/10/08 22:31:00.0713 GMT"

        guard let someDateTime = formatter.date(from: dateString) else {
            XCTFail("DateFormatter was unable to parse '\(dateString)' using '\(formatter.dateFormat ?? "")' date format.")
            return
        }
        let isoFormatter = ISO8601DateFormatter()

        //default settings check
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08T22:31:00Z")

        /*
         The following tests cover various cases when changing the .formatOptions property.
         */
        isoFormatter.formatOptions = ISO8601DateFormatter.Options.withInternetDateTime
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08T22:31:00Z")

        isoFormatter.formatOptions = [ISO8601DateFormatter.Options.withInternetDateTime, ISO8601DateFormatter.Options.withSpaceBetweenDateAndTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08 22:31:00Z")

        isoFormatter.formatOptions = ISO8601DateFormatter.Options.withFullTime
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "22:31:00Z")

        isoFormatter.formatOptions = [ISO8601DateFormatter.Options.withFullTime, ISO8601DateFormatter.Options.withFractionalSeconds]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "22:31:00.\(fs)Z")

        isoFormatter.formatOptions = ISO8601DateFormatter.Options.withFullDate
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08")

        isoFormatter.formatOptions = [ISO8601DateFormatter.Options.withFullTime, ISO8601DateFormatter.Options.withFullDate]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08T22:31:00Z")

        isoFormatter.formatOptions = [ISO8601DateFormatter.Options.withFullTime, ISO8601DateFormatter.Options.withFullDate, ISO8601DateFormatter.Options.withSpaceBetweenDateAndTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08 22:31:00Z")

        isoFormatter.formatOptions = [.withFullTime, .withFullDate, .withSpaceBetweenDateAndTime, .withFractionalSeconds]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08 22:31:00.\(fs)Z")

        isoFormatter.formatOptions = [.withDay, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "282T223100")

        isoFormatter.formatOptions = [.withDay, .withTime, .withFractionalSeconds]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "282T223100.\(fs)")

        isoFormatter.formatOptions = [.withWeekOfYear, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "\(wk)T223100")

        isoFormatter.formatOptions = [.withMonth, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10T223100")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "\(wk)06T223100")

        isoFormatter.formatOptions = [.withDay, .withMonth, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "1008T223100")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth, .withTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)T223100")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)T22:31:00")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk) 22:31:00")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime, .withDashSeparatorInDate]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10-\(wk) 22:31:00")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime, .withDashSeparatorInDate, .withFractionalSeconds]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10-\(wk) 22:31:00.\(fs)")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "\(wk)06")

        isoFormatter.formatOptions = [.withDay, .withMonth]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "1008")

        isoFormatter.formatOptions = [.withWeekOfYear, .withMonth]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withMonth]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)06")

        // .withFractionalSeconds should be ignored if neither .withTime or .withFullTime are specified
        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withFractionalSeconds]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)06")

        isoFormatter.formatOptions = [.withMonth, .withDay, .withWeekOfYear, .withDashSeparatorInDate]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10-\(wk)-06")

        /*
         The following tests cover various cases when changing the .formatOptions property with a different TimeZone set.
         */

        // was "PST", but that is considered legacy, and returns GMT on Android (although it works in Robolectric)
        guard let pstTimeZone = TimeZone(identifier: "America/Los_Angeles") else {
            XCTFail("Failed to create instance of TimeZone using PST identifier")
            return
        }

        isoFormatter.timeZone = pstTimeZone

        isoFormatter.formatOptions = [.withInternetDateTime]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08T15:31:00-07:00")

        isoFormatter.formatOptions = [.withTime, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "153100-0700")

        isoFormatter.formatOptions = [.withDay, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "282-0700")

        isoFormatter.formatOptions = [.withWeekOfYear, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "\(wk)-0700")

        isoFormatter.formatOptions = [.withMonth, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10-0700")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "\(wk)06-0700")

        isoFormatter.formatOptions = [.withDay, .withMonth, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "1008-0700")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)06-0700")

        isoFormatter.formatOptions = [.withFullDate, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "2016-10-08-0700")

        isoFormatter.formatOptions = [.withFullTime, .withTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "15:31:00-07:00")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone, .withColonSeparatorInTimeZone]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10\(wk)06-07:00")

        isoFormatter.formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone, .withColonSeparatorInTimeZone, .withDashSeparatorInDate]
        XCTAssertEqual(isoFormatter.string(from: someDateTime), "10-\(wk)-06-07:00")
    }



    func test_dateFromString() {
        let f = ISO8601DateFormatter()
        var result = f.date(from: "2016-10-08T00:00:00Z")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2016-10-08 00:00:00 +0000")
        }

        result = f.date(from: "2016-10-08T00:00:00+0600")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2016-10-07 18:00:00 +0000")
        }

        result = f.date(from: "2016-10-08T00:00:00-0600")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2016-10-08 06:00:00 +0000")
        }

        result = f.date(from: "12345")
        XCTAssertNil(result)


        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        result = f.date(from: "2025-01-11T15:30:24.390+00:00")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2025-01-11 15:30:24 +0000")
        }

        result = f.date(from: "2025-01-11T15:30:24.1+00:00")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2025-01-11 15:30:24 +0000")
        }

        result = f.date(from: "2025-01-11T15:30:24.390858+00:00")
        XCTAssertNotNil(result)
        if let stringResult = result?.description {
            XCTAssertEqual(stringResult, "2025-01-11 15:30:24 +0000")
        }
    }



    func test_stringFromDateClass() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm zzz"
        let dateString = "2016/10/08 22:31 GMT"

        guard let someDateTime = formatter.date(from: dateString) else {
            XCTFail("DateFormatter was unable to parse '\(dateString)' using '\(formatter.dateFormat ?? "")' date format.")
            return
        }

        guard let timeZone = TimeZone(identifier: "GMT") else {
            XCTFail("Failed to create instance of TimeZone using GMT identifier")
            return
        }

        var formatOptions: ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withColonSeparatorInTimeZone]

        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08T22:31:00Z")

        /*
         The following tests cover various cases when changing the .formatOptions property.
         */

        formatOptions = [.withInternetDateTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08T22:31:00Z")

        formatOptions = [.withInternetDateTime, .withSpaceBetweenDateAndTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08 22:31:00Z")

        formatOptions = .withFullTime
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "22:31:00Z")

        formatOptions = .withFullDate
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08")

        formatOptions = [.withFullTime, .withFullDate]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08T22:31:00Z")

        formatOptions = [.withFullTime, .withFullDate, .withSpaceBetweenDateAndTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "2016-10-08 22:31:00Z")

        formatOptions = [.withDay, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "282T223100")

        formatOptions = [.withWeekOfYear, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "\(wk)T223100")

        formatOptions = [.withMonth, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10T223100")

        formatOptions = [.withDay, .withWeekOfYear, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "\(wk)06T223100")

        formatOptions = [.withDay, .withMonth, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "1008T223100")

        formatOptions = [.withWeekOfYear, .withMonth, .withTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10\(wk)T223100")

        formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10\(wk)T22:31:00")

        formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10\(wk) 22:31:00")

        formatOptions = [.withWeekOfYear, .withMonth, .withTime, .withColonSeparatorInTime, .withSpaceBetweenDateAndTime, .withDashSeparatorInDate]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10-\(wk) 22:31:00")

        formatOptions = [.withDay, .withWeekOfYear]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "\(wk)06")

        formatOptions = [.withDay, .withMonth]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "1008")

        formatOptions = [.withWeekOfYear, .withMonth]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10\(wk)")

        formatOptions = [.withDay, .withWeekOfYear, .withMonth]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10\(wk)06")

        formatOptions = [.withMonth, .withDay, .withWeekOfYear, .withDashSeparatorInDate]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: timeZone, formatOptions: formatOptions), "10-\(wk)-06")

        /*
         The following tests cover various cases when changing the .formatOptions property with a different TimeZone set.
         */

        // was "PST", but that is considered legacy, and returns GMT on Android (although it works in Robolectric)
        guard let pstTimeZone = TimeZone(identifier: "America/Los_Angeles") else {
            XCTFail("Failed to create instance of TimeZone using PST identifier")
            return
        }

        formatOptions = [.withInternetDateTime]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "2016-10-08T15:31:00-07:00")

        formatOptions = [.withTime, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "153100-0700")

        formatOptions = [.withDay, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "282-0700")

        formatOptions = [.withWeekOfYear, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "\(wk)-0700")

        formatOptions = [.withMonth, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "10-0700")

        formatOptions = [.withDay, .withWeekOfYear, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "\(wk)06-0700")

        formatOptions = [.withDay, .withMonth, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "1008-0700")

        formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "10\(wk)06-0700")

        formatOptions = [.withFullDate, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "2016-10-08-0700")

        formatOptions = [.withFullTime, .withTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "15:31:00-07:00")

        formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone, .withColonSeparatorInTimeZone]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "10\(wk)06-07:00")

        formatOptions = [.withDay, .withWeekOfYear, .withMonth, .withTimeZone, .withColonSeparatorInTimeZone, .withDashSeparatorInDate]
        XCTAssertEqual(ISO8601DateFormatter.string(from: someDateTime, timeZone: pstTimeZone, formatOptions: formatOptions), "10-\(wk)-06-07:00")
    }

    #if !SKIP
    let fixtures = [
        Fixtures.iso8601FormatterDefault,
        Fixtures.iso8601FormatterOptionsSet
    ]
    #endif
    
    func areEqual(_ a: ISO8601DateFormatter, _ b: ISO8601DateFormatter) -> Bool {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        return a.formatOptions == b.formatOptions &&
            a.timeZone.identifier == b.timeZone.identifier
        #endif // !SKIP
    }
    
    func test_codingRoundtrip() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
            try fixture.assertValueRoundtripsInCoder(secureCoding: true, matchingWith: areEqual(_:_:))
        }
        #endif // !SKIP
    }
    
    func test_loadingFixtures() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
//            try fixture.assertLoadedValuesMatch(areEqual(_:_:))
        }
        #endif // !SKIP
    }

    func test_copy() throws {
        let original = ISO8601DateFormatter()
        original.timeZone = try XCTUnwrap(TimeZone(identifier: "GMT"))

        #if SKIP
        throw XCTSkip("TODO")
        #else
        original.formatOptions = [
            .withInternetDateTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withColonSeparatorInTimeZone,
        ]
        let copied = try XCTUnwrap(original.copy() as? ISO8601DateFormatter)
        XCTAssertEqual(copied.timeZone, original.timeZone)
        XCTAssertEqual(copied.formatOptions, original.formatOptions)

        copied.timeZone = try XCTUnwrap(TimeZone(identifier: "JST"))
        copied.formatOptions.insert(.withFractionalSeconds)
//        XCTAssertNotEqual(copied.timeZone, original.timeZone)
//        XCTAssertNotEqual(copied.formatOptions, original.formatOptions)
//        XCTAssertFalse(original.formatOptions.contains(.withFractionalSeconds))
        XCTAssertTrue(copied.formatOptions.contains(.withFractionalSeconds))
        #endif // !SKIP
    }
    
}


