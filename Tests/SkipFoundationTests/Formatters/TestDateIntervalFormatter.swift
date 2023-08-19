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
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


enum ContainsInOrderResult: Equatable {
    case success
    case missed(String)
    case doesNotEndWithLastElement
}

extension String {
    func containsInOrder(requiresLastToBeAtEnd: Bool = false, _ substrings: [String]) -> ContainsInOrderResult {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var foundRange: Range<String.Index> = startIndex ..< startIndex
        for substring in substrings {
            if let newRange = range(of: substring, options: [], range: foundRange.upperBound..<endIndex, locale: nil) {
                foundRange = newRange
            } else {
                return .missed(substring)
            }
        }
        
        if requiresLastToBeAtEnd {
            return foundRange.upperBound == endIndex ? .success : .doesNotEndWithLastElement
        } else {
            return .success
        }
        #endif // !SKIP
    }
    
    #if !SKIP
    func assertContainsInOrder(requiresLastToBeAtEnd: Bool = false, _ substrings: String...) {
        let result = containsInOrder(requiresLastToBeAtEnd: requiresLastToBeAtEnd, substrings)
        XCTAssert(result == .success, "String '\(self)' (must end with: \(requiresLastToBeAtEnd)) does not contain in sequence: \(substrings) — reason: \(result)")
    }
    #endif // !SKIP
}

class TestDateIntervalFormatter: XCTestCase {
    #if !SKIP
    private var formatter: DateIntervalFormatter!
    #endif

    override func setUp() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        super.setUp()
        
        formatter = DateIntervalFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .long
        formatter.timeStyle = .full
        #endif // !SKIP
    }
    
    override func tearDown() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        formatter = nil
        
        super.tearDown()
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossThreeBillionSeconds() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3e9)
        
        let result = formatter.string(from: older, to: newer)
        result.assertContainsInOrder("January 1",  "2001", "12:00:00\(ts)AM", "Greenwich Mean Time",
                                     "January 25", "2096", "5:20:00\(ts)AM",  "Greenwich Mean Time")
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossThreeMillionSeconds() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3e6)
        
        let result = formatter.string(from: older, to: newer)
        result.assertContainsInOrder("January 1",  "2001", "12:00:00\(ts)AM", "Greenwich Mean Time",
                                     "February 4", "2001", "5:20:00\(ts)PM",  "Greenwich Mean Time")
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossThreeBillionSecondsReversed() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3e9)
        
        let result = formatter.string(from: newer, to: older)
        result.assertContainsInOrder("January 25", "2096", "5:20:00\(ts)AM",  "Greenwich Mean Time",
                                     "January 1",  "2001", "12:00:00\(ts)AM", "Greenwich Mean Time")
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossThreeMillionSecondsReversed() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3e6)
        
        let result = formatter.string(from: newer, to: older)
        result.assertContainsInOrder("February 4", "2001", "5:20:00\(ts)PM",  "Greenwich Mean Time",
                                     "January 1",  "2001", "12:00:00\(ts)AM", "Greenwich Mean Time")
        #endif // !SKIP
    }
    
    func testStringFromDateToSameDate() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let date = Date(timeIntervalSinceReferenceDate: 3e6)
        
        // For a range from a date to itself, we represent the date only once, with no interdate separator.
        let result = formatter.string(from: date, to: date)
        result.assertContainsInOrder(requiresLastToBeAtEnd: true, "February 4", "2001", "5:20:00\(ts)PM",  "Greenwich Mean Time")

        let firstFebruary = try XCTUnwrap(result.range(of: "February"))
        XCTAssertNil(result[firstFebruary.upperBound...].range(of: "February")) // February appears only once.
        #endif // !SKIP
    }
    
    func testStringFromDateIntervalAcrossThreeMillionSeconds() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let interval = DateInterval(start: Date(timeIntervalSinceReferenceDate: 0), duration: 3e6)
        
        let result = try XCTUnwrap(formatter.string(from: interval))
        result.assertContainsInOrder("January 1",  "2001", "12:00:00\(ts)AM", "Greenwich Mean Time",
                                     "February 4", "2001", "5:20:00\(ts)PM",  "Greenwich Mean Time")
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossOneWeek() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        formatter.dateTemplate = "MMMd"
        
        do {
            let older = Date(timeIntervalSinceReferenceDate: 0)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 7)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "1", "8")
        }
        
        do {
            let older = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 28)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 34)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "29", "Feb", "4")
        }
        #endif // !SKIP
    }
    
    #if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    func testStringFromDateToDateAcrossOneWeekWithMonthMinimization() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        formatter.dateTemplate = "MMMd"
        formatter.boundaryStyle = .minimizeAdjacentMonths
        
        do {
            let older = Date(timeIntervalSinceReferenceDate: 0)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 7)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "1", "8")
        }
        
        do {
            let older = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 28)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 34)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "29", "4")
            XCTAssertNil(result.range(of: "Feb"))
        }
        #endif // !SKIP
    }
    #endif
    
    func testStringFromDateToDateAcrossSixtyDays() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        formatter.dateTemplate = "MMMd"
        
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 60)
        
        let result = formatter.string(from: older, to: newer)
        result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "1", "Mar", "2")
        #endif // !SKIP
    }
    
    #if NS_FOUNDATION_ALLOWS_TESTABLE_IMPORT && (os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    func testStringFromDateToDateAcrossSixtyDaysWithMonthMinimization() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        formatter.dateTemplate = "MMMd"
        formatter.boundaryStyle = .minimizeAdjacentMonths
        
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3600 * 24 * 60)
        
        // Minimization shouldn't do anything since this spans more than a month
        let result = formatter.string(from: older, to: newer)
        result.assertContainsInOrder(requiresLastToBeAtEnd: true, "Jan", "1", "Mar", "2")
        #endif // !SKIP
    }
    #endif
    
    func testStringFromDateToDateAcrossFiveHours() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        do {
            let older = Date(timeIntervalSinceReferenceDate: 0)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 5)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true, "January", "1", "2001", "12:00:00\(ts)AM", "5:00:00\(ts)AM", "GMT")

            let firstJanuary = try XCTUnwrap(result.range(of: "January"))
            XCTAssertNil(result[firstJanuary.upperBound...].range(of: "January")) // January appears only once.
        }
        
        do {
            let older = Date(timeIntervalSinceReferenceDate: 3600 * 22)
            let newer = Date(timeIntervalSinceReferenceDate: 3600 * 27)
            
            let result = formatter.string(from: older, to: newer)
            result.assertContainsInOrder(requiresLastToBeAtEnd: true,
                                         "January", "1", "2001", "10:00:00\(ts)PM", "Greenwich Mean Time",
                                         "January", "2", "2001", "3:00:00\(ts)AM",  "Greenwich Mean Time")
        }
        #endif // !SKIP
    }
    
    func testStringFromDateToDateAcrossEighteenHours() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let older = Date(timeIntervalSinceReferenceDate: 0)
        let newer = Date(timeIntervalSinceReferenceDate: 3600 * 18)
        
        let result = formatter.string(from: older, to: newer)
        result.assertContainsInOrder(requiresLastToBeAtEnd: true, "January", "1", "2001", "12:00:00\(ts)AM", "6:00:00\(ts)PM", "GMT")

        let firstJanuary = try XCTUnwrap(result.range(of: "January"))
        XCTAssertNil(result[firstJanuary.upperBound...].range(of: "January")) // January appears only once.
        #endif // !SKIP
    }

    #if !SKIP
    let fixtures = [Fixtures.dateIntervalFormatterDefault,
                    Fixtures.dateIntervalFormatterValuesSetWithoutTemplate,
                    Fixtures.dateIntervalFormatterValuesSetWithTemplate ]
    #endif

    #if !SKIP
    func assertEqualAndNonnil(_ lhs: DateIntervalFormatter?, _ rhs: DateIntervalFormatter?, _ message: @autoclosure () -> String = "") throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        XCTAssertNotNil(lhs)
        XCTAssertNotNil(rhs)
        
        let a = try XCTUnwrap(lhs)
        let b = try XCTUnwrap(rhs)
        
        XCTAssertEqual(a.dateStyle, b.dateStyle, message())
        XCTAssertEqual(a.timeStyle, b.timeStyle, message())
        XCTAssertEqual(a.dateTemplate, b.dateTemplate, message())
        XCTAssertEqual(a.locale, b.locale, message())

        if a.calendar != b.calendar {
            // We're fine if the calendars are equal except for having timezones with the same name.
            XCTAssertEqual(a.calendar.timeZone.identifier, b.calendar.timeZone.identifier, message())
            
            let aWithBsTimezone = a.copy() as! DateIntervalFormatter
            aWithBsTimezone.calendar.timeZone = b.calendar.timeZone
            XCTAssertEqual(aWithBsTimezone.calendar, b.calendar, message())
        } else {
            // It's good!
            XCTAssertEqual(a.calendar, b.calendar, message())
        }
        
        if a.timeZone != b.timeZone {
            XCTAssertEqual(a.timeZone.identifier, b.timeZone.identifier, message())
        } else {
            // It's good!
            XCTAssertEqual(a.timeZone, b.timeZone, message())
        }
        #endif // !SKIP
    }
    #endif
    
    func testCodingRoundtrip() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        for fixture in fixtures {
            let original = try fixture.make()
            
            let coder = NSKeyedArchiver(forWritingWith: NSMutableData())
            coder.encode(original, forKey: NSKeyedArchiveRootObjectKey)
            coder.finishEncoding()
            
            let data = coder.encodedData
            
            let decoder = NSKeyedUnarchiver(forReadingWith: data)
            let object = decoder.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? DateIntervalFormatter
            
            XCTAssertNil(decoder.error)
            try assertEqualAndNonnil(object, original, "Comparing in-memory fixture '\(fixture.identifier)'")
        }
        #endif // !SKIP
    }
    
    func testDecodingFixtures() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
//        for fixture in fixtures {
//            try fixture.loadEach { (fixtureValue, variant) in
//                let original = try fixture.make()
//                try assertEqualAndNonnil(original, fixtureValue, "Comparing loaded fixture \(fixture.identifier) with variant \(variant)")
//            }
//        }
        #endif // !SKIP
    }
    
}


