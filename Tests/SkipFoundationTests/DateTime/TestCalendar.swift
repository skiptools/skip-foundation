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
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestCalendar: XCTestCase {

    func test_allCalendars() {
        #if !SKIP
        for identifier in [
            Calendar.Identifier.buddhist,
            Calendar.Identifier.chinese,
            Calendar.Identifier.coptic,
            Calendar.Identifier.ethiopicAmeteAlem,
            Calendar.Identifier.ethiopicAmeteMihret,
            Calendar.Identifier.gregorian,
            Calendar.Identifier.hebrew,
            Calendar.Identifier.indian,
            Calendar.Identifier.islamic,
            Calendar.Identifier.islamicCivil,
            Calendar.Identifier.islamicTabular,
            Calendar.Identifier.islamicUmmAlQura,
            Calendar.Identifier.iso8601,
            Calendar.Identifier.japanese,
            Calendar.Identifier.persian,
            Calendar.Identifier.republicOfChina
            ] as [Calendar.Identifier] {
                let calendar = Calendar(identifier: identifier)
                XCTAssertEqual(identifier,calendar.identifier)
        }
        #else
        XCTAssertEqual(Calendar.Identifier.gregorian, Calendar(identifier: Calendar.Identifier.gregorian).identifier)
        #endif
    }

    func test_gettingDatesOnGregorianCalendar() {
        let date = Date(timeIntervalSince1970: 1449332351)

        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: date)

        XCTAssertEqual(components.year, 2015)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 5)

        // Test for problem reported by Malcolm Barclay via swift-corelibs-dev
        // https://lists.swift.org/pipermail/swift-corelibs-dev/Week-of-Mon-20161128/001031.html
        let fromDate = Date()
        let interval = 200
        let toDate = Date(timeInterval: TimeInterval(interval), since: fromDate)
        #if SKIP
        throw XCTSkip("TODO: dateComponents interval calculations")
        #endif
        let fromToComponents = calendar.dateComponents(Set([Calendar.Component.second]), from: fromDate, to: toDate)
        XCTAssertEqual(fromToComponents.second, interval);

        // Issue with 32-bit CF calendar vector on Linux
        // Crashes on macOS 10.12.2/Foundation 1349.25
        // (Possibly related) rdar://24384757
        /*
        let interval2 = Int(INT32_MAX) + 1
        let toDate2 = Date(timeInterval: TimeInterval(interval2), since: fromDate)
        let fromToComponents2 = calendar.dateComponents([.second], from: fromDate, to: toDate2)
        XCTAssertEqual(fromToComponents2.second, interval2);
        */
    }

    func test_gettingDatesOnISO8601Calendar() {
        #if SKIP
        throw XCTSkip("Skip: unsupported ISO8601Calendar")
        #else
        let date = Date(timeIntervalSince1970: 1449332351)

        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        XCTAssertEqual(components.year, 2015)
        XCTAssertEqual(components.month, 12)
        XCTAssertEqual(components.day, 5)
        #endif // !SKIP
    }


    func test_gettingDatesOnHebrewCalendar() {
        #if SKIP
        throw XCTSkip("Skip: unsupported HebrewCalendar")
        #else
        let date = Date(timeIntervalSince1970: 1552580351)

        var calendar = Calendar(identifier: .hebrew)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 5779)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 7)
        XCTAssertEqual(components.isLeapMonth, false)
        #endif // !SKIP
    }

    func test_gettingDatesOnChineseCalendar() {
        #if SKIP
        throw XCTSkip("Skip: unsupported ChineseCalendar")
        #else
        let date = Date(timeIntervalSince1970: 1591460351.0)

        var calendar = Calendar(identifier: .chinese)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 37)
        XCTAssertEqual(components.month, 4)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.isLeapMonth, true)
        #endif // !SKIP
    }

    func test_gettingDatesOnPersianCalendar() {
        #if SKIP
        throw XCTSkip("Skip: unsupported PersianCalendar")
        #else
        let date = Date(timeIntervalSince1970: 1539146705)

        var calendar = Calendar(identifier: .persian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 1397)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 18)

        #endif // !SKIP
    }
    
    func test_gettingDatesOnJapaneseCalendar() throws {
        #if SKIP
        throw XCTSkip("Skip: unsupported JapaneseCalendar")
        #else
        var calendar = Calendar(identifier: .japanese)
        calendar.timeZone = try XCTUnwrap( TimeZone(identifier: "UTC") )
        calendar.locale = Locale(identifier: "en_US_POSIX")
        
        do {
            let date = Date(timeIntervalSince1970: 1556633400) // April 30, 2019
            let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
            XCTAssertEqual(calendar.eraSymbols[try XCTUnwrap(components.era)], "Heisei")
            XCTAssertEqual(components.year, 31)
            XCTAssertEqual(components.month, 4)
            XCTAssertEqual(components.day, 30)
        }
        
        // Test for new Japanese calendar era (starting from May 1, 2019)
        do {
            let date = Date(timeIntervalSince1970: 1556719800) // May 1, 2019
            let components = calendar.dateComponents([.era, .year, .month, .day], from: date)
            XCTAssertEqual(calendar.eraSymbols[try XCTUnwrap(components.era)], "Reiwa")
            XCTAssertEqual(components.year, 1)
            XCTAssertEqual(components.month, 5)
            XCTAssertEqual(components.day, 1)
        }
        #endif // !SKIP
    }

    func test_ampmSymbols() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        XCTAssertEqual(calendar.amSymbol, "AM")
        XCTAssertEqual(calendar.pmSymbol, "PM")
    }

    func test_currentCalendarRRstability() {
        var AMSymbols = Array<String>()
        for _ in 1...10 {
            let cal = Calendar.current
            AMSymbols.append(cal.amSymbol)
        }

        XCTAssertEqual(AMSymbols.count, 10, "Accessing current calendar should work over multiple callouts")
    }

    func test_copy() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        var calendar = Calendar.current

        //Mutate below fields and check if change is being reflected in copy.
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 2

        let copy = calendar
        XCTAssertTrue(copy == calendar)

        //verify firstWeekday and minimumDaysInFirstWeek of 'copy'.
        calendar.firstWeekday = 3
        calendar.minimumDaysInFirstWeek = 3
        XCTAssertEqual(copy.firstWeekday, 2)
        XCTAssertEqual(copy.minimumDaysInFirstWeek, 2)
        #endif // !SKIP
    }

    func test_component() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let thisDay = calendar.date(from: DateComponents(year: 2016, month: 10, day: 4))!
        XCTAssertEqual(calendar.component(.year, from: thisDay), 2016)
        XCTAssertEqual(calendar.component(.month, from: thisDay), 10)
        XCTAssertEqual(calendar.component(.day, from: thisDay), 4)
    }

    func test_addingDates() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let thisDay = calendar.date(from: DateComponents(year: 2016, month: 10, day: 4))!

        let thisDayComponents = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: thisDay)
        XCTAssertEqual(thisDayComponents.year, 2016)
        XCTAssertEqual(thisDayComponents.month, 10)
        XCTAssertEqual(thisDayComponents.day, 4)

        let diffComponents = DateComponents(day: 1)
        let dayAfter = calendar.date(byAdding: diffComponents, to: thisDay)

        let dayAfterComponents = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: dayAfter!)
        XCTAssertEqual(dayAfterComponents.year, 2016)
        XCTAssertEqual(dayAfterComponents.month, 10)
        XCTAssertEqual(dayAfterComponents.day, 5)

        let diffComponents30 = DateComponents(day: 30)

        let monthAfter = calendar.date(byAdding: diffComponents30, to: thisDay, wrappingComponents: true)

        let monthAfterComponents = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: monthAfter!)
        XCTAssertEqual(monthAfterComponents.year, 2016)
        XCTAssertEqual(monthAfterComponents.month, 10)
        XCTAssertEqual(monthAfterComponents.day, 3)
    }

    func test_addingDates_issue182() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startDate = Date(timeIntervalSince1970: 0)

        do {
            let comps = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: startDate)

            XCTAssertEqual(comps.year, 1970)
            XCTAssertEqual(comps.month, 1)
            XCTAssertEqual(comps.day, 1)
        }

        // testing with and without wrapping
        do {
            let endDate = calendar.date(byAdding: .day, value: 60, to: startDate, wrappingComponents: true)!

            let comps = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: endDate)

            XCTAssertEqual(comps.year, 1970)
            XCTAssertEqual(comps.month, 1)
            XCTAssertEqual(comps.day, 30)
        }

        do {
            let endDate = calendar.date(byAdding: .day, value: 60, to: startDate)!

            let comps = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: endDate)

            XCTAssertEqual(comps.year, 1970)
            XCTAssertEqual(comps.day, 2)
            XCTAssertEqual(comps.month, 3)
        }

    }

    func test_addingComponents() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let thisDay = calendar.date(from: DateComponents(year: 2016, month: 10, day: 4))!
        let dayAfter = calendar.date(byAdding: .day, value: 1, to: thisDay)

        let dayAfterComponents = calendar.dateComponents(Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day]), from: dayAfter!)
        XCTAssertEqual(dayAfterComponents.year, 2016)
        XCTAssertEqual(dayAfterComponents.month, 10)
        XCTAssertEqual(dayAfterComponents.day, 5)
    }

    func test_datesNotOnWeekend() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let mondayInDecember = calendar.date(from: DateComponents(year: 2018, month: 12, day: 10))!
        XCTAssertFalse(calendar.isDateInWeekend(mondayInDecember))
        let tuesdayInNovember = calendar.date(from: DateComponents(year: 2017, month: 11, day: 14))!
        XCTAssertFalse(calendar.isDateInWeekend(tuesdayInNovember))
        let wednesdayInFebruary = calendar.date(from: DateComponents(year: 2016, month: 2, day: 17))!
        XCTAssertFalse(calendar.isDateInWeekend(wednesdayInFebruary))
        let thursdayInOctober = calendar.date(from: DateComponents(year: 2015, month: 10, day: 22))!
        XCTAssertFalse(calendar.isDateInWeekend(thursdayInOctober))
        let fridayInSeptember = calendar.date(from: DateComponents(year: 2014, month: 9, day: 26))!
        XCTAssertFalse(calendar.isDateInWeekend(fridayInSeptember))
    }

    func test_datesOnWeekend() {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let saturdayInJanuary = calendar.date(from: DateComponents(year:2017, month: 1, day: 7))!
        XCTAssertTrue(calendar.isDateInWeekend(saturdayInJanuary))
        let sundayInFebruary = calendar.date(from: DateComponents(year: 2016, month: 2, day: 14))!
        XCTAssertTrue(calendar.isDateInWeekend(sundayInFebruary))
    }

    func test_customMirror() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let calendarMirror = calendar.customMirror

        XCTAssertEqual(calendar.identifier, calendarMirror.descendant("identifier") as? Calendar.Identifier)
        XCTAssertEqual(calendar.locale, calendarMirror.descendant("locale") as? Locale)
        XCTAssertEqual(calendar.timeZone, calendarMirror.descendant("timeZone") as? TimeZone)
        XCTAssertEqual(calendar.firstWeekday, calendarMirror.descendant("firstWeekday") as? Int)
        XCTAssertEqual(calendar.minimumDaysInFirstWeek, calendarMirror.descendant("minimumDaysInFirstWeek") as? Int)
        #endif
    }

    func test_hashing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let calendars: [Calendar] = [
            Calendar.autoupdatingCurrent,
            Calendar(identifier: .buddhist),
            Calendar(identifier: .gregorian),
            Calendar(identifier: .islamic),
            Calendar(identifier: .iso8601),
        ]
        checkHashable(calendars, equalityOracle: { $0 == $1 })

        // autoupdating calendar isn't equal to the current, even though it's
        // likely to be the same.
        let calendars2: [Calendar] = [
            Calendar.autoupdatingCurrent,
            Calendar.current,
        ]
        checkHashable(calendars2, equalityOracle: { $0 == $1 })
        #endif // !SKIP
    }

    func test_dateFromDoesntMutate() throws {
        // Check that date(from:) does not change the timeZone of the calendar
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = try XCTUnwrap(TimeZone(identifier: "UTC"))

        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))

        let expectedDescription = calendar.timeZone == TimeZone.current ? "GMT (current)" : "GMT (fixed)"

        let calendarCopy = calendar
        XCTAssertEqual(calendarCopy.timeZone.identifier, "GMT")
//        XCTAssertEqual(calendarCopy.timeZone.description, expectedDescription)

        let dc = try calendarCopy.dateComponents(in: XCTUnwrap(TimeZone(identifier: "America/New_York")), from: XCTUnwrap(df.date(from: "2019-01-01")))
        XCTAssertEqual(calendarCopy.timeZone.identifier, "GMT")
//        XCTAssertEqual(calendarCopy.timeZone.description, expectedDescription)

        let dt = try XCTUnwrap(calendarCopy.date(from: dc))
        XCTAssertEqual(calendarCopy.timeZone.identifier, "GMT")
        XCTAssertEqual(calendarCopy.timeZone, calendar.timeZone)
        XCTAssertEqual(calendarCopy, calendar)
        #if SKIP
        throw XCTSkip("TODO: dateComponents interval calculations")
        #endif
        XCTAssertEqual(dt.description, "2019-01-01 00:00:00 +0000")
//        XCTAssertEqual(calendarCopy.timeZone.description, expectedDescription)
    }

    func test_sr10638() {
        // https://bugs.swift.org/browse/SR-10638
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        XCTAssertGreaterThan(cal.eraSymbols.count, 0)
    }

    func test_nextDate() throws {
        #if SKIP
        throw XCTSkip("TODO: dateComponents nextDate")
        #else
        var calendar = Calendar.current
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "US/Pacific"))
        let date_20200101 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2020, month: 01, day: 1)))

        do {
            let expected = try XCTUnwrap(calendar.date(from: DateComponents(year: 2020, month: 01, day: 2, hour: 0)))
            let components = DateComponents(year: 2020, month: 1, day: 2, hour: 0, minute: 0, second: 0)
            let next = calendar.nextDate(after: date_20200101, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .forward)
            XCTAssertEqual(next, expected)
        }

        do {
            // SR-13979 - Check nil result when no valid nextDate
            let components = DateComponents(year: 2019, month: 2, day: 1, hour: 0, minute: 0, second: 0)
            let next = calendar.nextDate(after: date_20200101, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents, direction: .forward)
            XCTAssertNil(next)
        }
        #endif // !SKIP
    }

    func testTimeZoneDates() throws {
        for zoneID in [
            "America/New_York",
            "GMT",
            "Europe/Zurich",
        ] {
            let t = 1728038797.0
            let date = Date(timeIntervalSince1970: t)

            var calendar = Calendar.current
            calendar.timeZone = try XCTUnwrap(TimeZone(identifier: zoneID))

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date)

            XCTAssertEqual(components.year, 2024)
            XCTAssertEqual(components.month, 10)
            XCTAssertEqual(components.day, 4)
            XCTAssertEqual(components.hour, zoneID == "America/New_York" ? 6 : zoneID == "Europe/Zurich" ? 12 : 10)
            XCTAssertEqual(components.minute, 46)
            XCTAssertEqual(components.second, 37)
            XCTAssertEqual(components.timeZone?.identifier, zoneID)

            let date2 = calendar.date(from: components)!
            XCTAssertEqual(date2, date)
            XCTAssertEqual(date2.timeIntervalSince1970, date.timeIntervalSince1970)
        }
    }

    func testDatesInCESTTimeZone() throws {
        // check error reported at: https://skiptools.slack.com/archives/C078X69G8F2/p1728038976873919?thread_ts=1726730418.442729&cid=C078X69G8F2
        let date = Date(timeIntervalSince1970: 1728038797.580)

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Europe/Zurich")!

        let components = calendar.dateComponents([.year, .month, .day], from: date)

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 10)
        XCTAssertEqual(components.day, 4)

        XCTAssertNil(components.calendar)
        XCTAssertNil(components.timeZone)

        var zdate = try XCTUnwrap(calendar.date(from: components))

        let ztcomponents = calendar.dateComponents([.hour, .minute, .second], from: zdate)

        XCTAssertNil(ztcomponents.calendar)
        XCTAssertNil(ztcomponents.timeZone)

        XCTAssertEqual(ztcomponents.hour, 0)
        XCTAssertEqual(ztcomponents.minute, 0)
        XCTAssertEqual(ztcomponents.second, 0)

        XCTAssertEqual(1727992800.0, zdate.timeIntervalSince1970)

        let tcomponents = calendar.dateComponents([.hour, .minute, .second], from: date)
        XCTAssertEqual(tcomponents.hour, 12)
        XCTAssertEqual(tcomponents.minute, 46)
        XCTAssertEqual(tcomponents.second, 37)

        XCTAssertNil(tcomponents.calendar)
        XCTAssertNil(tcomponents.timeZone)

        let zcomponents = calendar.dateComponents([.year, .month, .day], from: zdate)

        XCTAssertNil(zcomponents.calendar)
        XCTAssertNil(zcomponents.timeZone)

        XCTAssertEqual(zcomponents.year, 2024)
        XCTAssertEqual(zcomponents.month, 10)
        XCTAssertEqual(zcomponents.day, 4) // java.lang.AssertionError: 5 != 4

        func expectTime(_ t: Double, _ components: Set<Calendar.Component>) {
            let components = calendar.dateComponents(components, from: date)
            var dt = calendar.date(from: components)!
            XCTAssertEqual(t, dt.timeIntervalSince1970, "incorrect time interval for calendar components: \(components)")
        }

        expectTime(1704063600.0, [.year])
        expectTime(1727733600.0, [.year, .month])
        expectTime(1727992800.0, [.year, .month, .day])
        expectTime(1728036000.0, [.year, .month, .day, .hour])
        expectTime(1728038760.0, [.year, .month, .day, .hour, .minute])
        expectTime(1728038797.0, [.year, .month, .day, .hour, .minute, .second])
        #if !SKIP
        expectTime(1728038797.58, [.year, .month, .day, .hour, .minute, .second, .nanosecond])
        #endif
    }
    
    func testCalendarWithIdentifier() {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        XCTAssertNotNil(gregorianCalendar)
        XCTAssertEqual(gregorianCalendar.identifier, .gregorian)
        
        let iso8601Calendar = Calendar(identifier: .iso8601)
        XCTAssertNotNil(iso8601Calendar)
        XCTAssertEqual(iso8601Calendar.identifier, .iso8601)
    }
    
    func testCalendarCurrent() {
        let calendar = Calendar.current
        XCTAssertNotNil(calendar)
    }
    
    func testLocale() {
        let calendar = Calendar.current
        XCTAssertEqual(calendar.locale, Locale.current)
    }
    
    func testTimeZone() {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.timeZone = timeZone
        XCTAssertEqual(calendar.timeZone, timeZone)
    }
    
    func testFirstWeekday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // Monday
        XCTAssertEqual(calendar.firstWeekday, 2)
    }
    
    func testSymbols() {
        let calendar = Calendar(identifier: .gregorian)
        XCTAssertGreaterThan(calendar.eraSymbols.count, 0)
        XCTAssertGreaterThan(calendar.monthSymbols.count, 0)
        XCTAssertGreaterThan(calendar.shortMonthSymbols.count, 0)
        XCTAssertGreaterThan(calendar.weekdaySymbols.count, 0)
        XCTAssertGreaterThan(calendar.shortWeekdaySymbols.count, 0)
    }
    
    func testRangeOfComponents() {
        let calendar = Calendar(identifier: .gregorian)

        // Test range for months
        let monthRange = calendar.minimumRange(of: .month)
        XCTAssertEqual(monthRange, 1..<13)

        // Test range for days in a month
        let dayRange = calendar.minimumRange(of: .day)
        XCTAssertEqual(dayRange, 1..<29)

        // Test range for hours in a day
        let hourRange = calendar.minimumRange(of: .hour)
        XCTAssertEqual(hourRange, 0..<24)

        // Test range for minutes in an hour
        let minuteRange = calendar.minimumRange(of: .minute)
        XCTAssertEqual(minuteRange, 0..<60)

        // Test range for seconds in a minute
        let secondRange = calendar.minimumRange(of: .second)
        XCTAssertEqual(secondRange, 0..<60)

        // Test range for weeks in a month (varies by month, so using valid range)
        let weekOfMonthRange = calendar.minimumRange(of: .weekOfMonth)
        XCTAssertEqual(weekOfMonthRange, 1..<5)

        // Test range for weeks in a year
        let weekOfYearRange = calendar.minimumRange(of: .weekOfYear)
        XCTAssertEqual(weekOfYearRange, 1..<53)

        // Test range for eras (usually 0..<2 for Gregorian calendar)
        let eraRange = calendar.minimumRange(of: .era)
        XCTAssertEqual(eraRange, 0..<2)
    }
    
    func testDateComparison() {
        let calendar = Calendar(identifier: .gregorian)
        let date1 = Date()
        let date2 = calendar.date(byAdding: .day, value: 1, to: date1)!
        
        let comparisonResult = calendar.compare(date1, to: date2, toGranularity: .day)
#if SKIP
        XCTAssertEqual(comparisonResult,  ComparisonResult.ascending)
#else
        XCTAssertEqual(comparisonResult,  .orderedAscending)
#endif
    }
    
    func testDateFromComponents() {
        var components = DateComponents()
        components.year = 2024
        components.month = 10
        components.day = 15
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)
        XCTAssertNotNil(date)
    }
    
    func testDateByAddingComponents() {
        let calendar = Calendar(identifier: .gregorian)
        let date = Date()
        
        let newDate = calendar.date(byAdding: .day, value: 1, to: date)
        XCTAssertNotNil(newDate)
    }
}
