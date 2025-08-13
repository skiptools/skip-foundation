// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

#if SKIP || canImport(Darwin)

fileprivate typealias CaseRelativeFormat = (numericFull: String, namedShort: String, namedAbbreviated: String, dateComponents: DateComponents, timeInterval: TimeInterval)

/// Kotlin formats time intervals approaching/at 0 as "x ago"
fileprivate func rel(_ formatString: String, interval: TimeInterval = 0.0) -> String {
    guard !formatString.isEmpty else { return formatString }
    #if !SKIP
    let isPast = interval < 0.0
    #else
    let isPast = interval < 1.0
    #endif
    return isPast ? "\(formatString) ago" : "in \(formatString)"
}

class TestRelativeDateTimeFormatter: XCTestCase {
    let formatter = RelativeDateTimeFormatter()
    #if !SKIP
    // `spellOut` is not currently supported in Kotlin
    let spellOutNumberFormatter = NumberFormatter()
    #endif

    fileprivate let reversableRelativeTimes: [CaseRelativeFormat] = {
        [
            ("1 second",  "1 sec.", "1s",   DateComponents(second: 1), 1.0),
            ("1 second",  "1 sec.", "1s",   DateComponents(second: 1, nanosecond: 900000000), 1.9),
            ("2 seconds", "2 sec.", "2s",   DateComponents(year: 0, second: 2), 2.0),
            ("1 minute",  "1 min.", "1m",   DateComponents(minute: 1), 60.0),
            ("5 minutes", "5 min.", "5m",   DateComponents(minute: 5), 60.0 * 5.0),
            ("1 hour",    "1 hr.",  "1h",   DateComponents(hour: 1, minute: 999), 60.0 * 60.0),
            ("12 hours",  "12 hr.", "12h",  DateComponents(hour: 12), 60.0 * 60.0 * 12.0),
            ("6 days",    "6 days", "6d",   DateComponents(day: 6), 60.0 * 60.0 * 24.0 * 6.9),
            //("4 weeks",   "4 wk.",  "4w",   DateComponents(weekOfMonth: 4), 60.0 * 60.0 * 24.0 * 30.9),
            ("11 months", "11 mo.", "11mo", DateComponents(month: 11), 60.0 * 60.0 * 24.0 * 364.9),
            ("54 years",  "54 yr.", "54y",  DateComponents(year: 54), 60.0 * 60.0 * 24.0 * 365.0 * 55.0),
            ("55 years",  "55 yr.", "55y",  DateComponents(year: 55), 60.0 * 60.0 * 24.0 * 366.0 * 55.0),
        ]
    }()

    fileprivate let customFormatting: [CaseRelativeFormat] = {
        [
            (rel("0 seconds"), "now",        "now",       DateComponents(second: -0), -0.9),
            ("in 1 day",       "tomorrow",   "tomorrow",  DateComponents(day: 1), 60.0 * 60.0 * 24.0),
            ("1 day ago",      "yesterday",  "yesterday", DateComponents(day: -1), -60.0 * 60.0 * 24.0),
            ("in 1 week",      "next wk.",   "next wk.",  DateComponents(weekOfMonth: 1), 60.0 * 60.0 * 24.0 * 7.0),
            ("1 week ago",     "last wk.",   "last wk.",  DateComponents(day: 1, weekOfMonth: -1), -60.0 * 60.0 * 24.0 * 7.0),
            //("in 1 month",     "next mo.",   "next mo.",  DateComponents(month: 1), 60.0 * 60.0 * 24.0 * 31.0), // disabled because depending on the current day (e.g., Janauary 30), this sometimes shows up as "in four weeks"
            ("1 month ago",    "last mo.",   "last mo.",  DateComponents(month: -1), -60.0 * 60.0 * 24.0 * 31.0),
            ("in 1 year",      "next yr.",   "next yr.",  DateComponents(year: 1), 60.0 * 60.0 * 24.0 * 365.0),
            ("11 months ago",  "11 mo. ago", "11mo ago",  DateComponents(month: -11), -60.0 * 60.0 * 24.0 * 365.0),
            ("1 year ago",     "last yr.",   "last yr.",  DateComponents(year: -1), -60.0 * 60.0 * 24.0 * 366.0),
        ]
    }()

    fileprivate let customDateComponents: [CaseRelativeFormat] = {
        #if !SKIP
        let thisHour = "this hour"
        #else
        let thisHour = "0 hr. ago"
        #endif
        return [
            ("", "", "", DateComponents(), 0.0),
            ("", "", "", DateComponents(nanosecond: 1), 0.0),
            ("", "", "", DateComponents(weekday: 1), 0.0),
            ("", "", "", DateComponents(weekdayOrdinal: 1), 0.0),
            ("", "", "", DateComponents(weekOfYear: 1), 0.0),
            ("", "", "", DateComponents(yearForWeekOfYear: 1), 0.0),
            ("", "", "", DateComponents(quarter: 1), 0.0),
            ("", "", "", DateComponents(era: 1), 0.0),
            (rel("0 seconds"), "now",       "now",       DateComponents(second: 0), 0.0),
            ("in 1 minute",    "in 1 min.", "in 1m",     DateComponents(hour: 0, minute: 1), 0.0),
            (rel("0 hours"),   thisHour,    "this hour", DateComponents(hour: 0), 0.0),
            (rel("0 days"),    "today",     "today",     DateComponents(day: 0), 0.0),
        ]
    }()

    fileprivate let reversableDateComponents: [CaseRelativeFormat] = {
        [
            ("55 days",  "55 days", "55d", DateComponents(day: 55, hour: 56), 1.0),
            ("8 weeks",  "8 wk.",   "8w",  DateComponents(weekOfMonth: 8), 1.0),
            ("55 weeks", "55 wk.",  "55w", DateComponents(weekOfMonth: 55), 1.0),
        ]
    }()

    override func setUp() {
        formatter.locale = Locale(identifier: "en_US")
        #if !SKIP
        formatter.calendar = Calendar(identifier: .gregorian)
        spellOutNumberFormatter.locale = formatter.locale
        spellOutNumberFormatter.numberStyle = .spellOut
        #endif
        super.setUp()
    }

    func test_defaults() {
        let unconfigured = RelativeDateTimeFormatter()
        XCTAssertEqual(unconfigured.dateTimeStyle, .numeric)
        XCTAssertEqual(unconfigured.unitsStyle, .full)

        formatter.dateTimeStyle = .named
        XCTAssertNil(formatter.string(for: 1.0 as TimeInterval))
        XCTAssertNil(formatter.string(for: DateComponents(second: 0)))
        XCTAssertEqual(formatter.string(for: Date(timeIntervalSinceNow: 0)), "now")
    }

    func test_formattingContext() {
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        XCTAssertEqual(formatter.localizedString(fromTimeInterval: 0), "Now")
        formatter.formattingContext = .listItem
        XCTAssertEqual(formatter.localizedString(fromTimeInterval: 0), "now")
//        formatter.formattingContext = .dynamic
//        XCTAssertEqual(formatter.attributedString(for: Date.now, withDefaultAttributes: nil), NSAttributedString("now"))
        formatter.formattingContext = .middleOfSentence
        XCTAssertEqual(formatter.localizedString(fromTimeInterval: 0), "now")
        formatter.formattingContext = .standalone
        XCTAssertEqual(formatter.localizedString(fromTimeInterval: 0), "now")
        formatter.formattingContext = .unknown
        XCTAssertEqual(formatter.localizedString(fromTimeInterval: 0), "now")
    }

    func test_numericFull() throws {
        throw XCTSkip("relative date formatting assumptions break when current date is at beginnging or end of month")
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .full
        XCTAssertEqual(formatter.localizedString(from: DateComponents(day: 1, hour: 1)), "in 1 day")
        for (numericFull, _, _, dateComponents, timeInterval) in customFormatting {
            XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), numericFull)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), numericFull)
        }
        for (numericFull, _, _, dateComponents, _) in customDateComponents {
            XCTAssertEqual(formatter.localizedString(from: dateComponents), numericFull)
        }
        for direction in [-1, 1] {
            for (numericFull, _, _, dateComponents, timeInterval) in reversableRelativeTimes {
                let (timeInterval, dateComponents, numericFull) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: numericFull)
                XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), numericFull)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), numericFull)
            }
            for (numericFull, _, _, dateComponents, timeInterval) in reversableDateComponents {
                let (_, dateComponents, numericFull) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: numericFull)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), numericFull)
            }
        }
    }

    func test_numericSpelledOut() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // e.g.: Test Suite 'Selected tests' started at 2025-03-01 22:20:41.197.Test Suite 'skip-foundationPackageTests.xctest' started at 2025-03-01 22:20:41.199.Test Suite 'TestRelativeDateTimeFormatter' started at 2025-03-01 22:20:41.199.Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_numericSpelledOut]' started./Users/runner/work/skip-foundation/skip-foundation/Tests/SkipFoundationTests/Formatters/TestRelativeDateTimeFormatter.swift:157: error: -[SkipFoundationTests.TestRelativeDateTimeFormatter test_numericSpelledOut] : XCTAssertEqual failed: ("one year ago") is not equal to ("eleven months ago")Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_numericSpelledOut]' failed (0.709 seconds).
        throw XCTSkip("relative date formatting assumptions break when current date is at beginnging or end of month")
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .spellOut
        for (numericFull, _, _, dateComponents, timeInterval) in customFormatting {
            let numericSpelledOut = spellOutNumbers(numericFull)
            XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), numericSpelledOut)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), numericSpelledOut)
        }
        for (numericFull, _, _, dateComponents, _) in customDateComponents {
            let numericSpelledOut = spellOutNumbers(numericFull)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), numericSpelledOut)
        }
        for direction in [-1, 1] {
            for (numericFull, _, _, dateComponents, timeInterval) in reversableRelativeTimes {
                let (timeInterval, dateComponents, numericFull) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: numericFull)
                let numericSpelledOut = spellOutNumbers(numericFull)
                XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), numericSpelledOut)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), numericSpelledOut)
            }
            for (numericFull, _, _, dateComponents, timeInterval) in reversableDateComponents {
                let (_, dateComponents, numericFull) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: numericFull)
                let numericSpelledOut = spellOutNumbers(numericFull)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), numericSpelledOut)
            }
        }
        #endif
    }

    func test_namedShort() throws {
        // e.g.: [✗] Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedShort]' started./Users/runner/work/skip-foundation/skip-foundation/Tests/SkipFoundationTests/Formatters/TestRelativeDateTimeFormatter.swift:184: error: -[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedShort] : XCTAssertEqual failed: ("last yr.") is not equal to ("11 mo. ago")Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedShort]' failed (0.695 seconds).Test Suite 'TestRelativeDateTimeFormatter' failed at 2025-03-01 22:20:41.874.
        throw XCTSkip("relative date formatting assumptions break when current date is at beginnging or end of month")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        for (_, namedShort, _, dateComponents, timeInterval) in customFormatting {
            XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), namedShort)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), namedShort)
        }
        for (_, namedShort, _, dateComponents, _) in customDateComponents {
            XCTAssertEqual(formatter.localizedString(from: dateComponents), namedShort)
        }
        for direction in [-1, 1] {
            for (_, namedShort, _, dateComponents, timeInterval) in reversableRelativeTimes {
                let (timeInterval, dateComponents, namedShort) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: namedShort)
                XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), namedShort)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), namedShort)
            }
            for (_, namedShort, _, dateComponents, timeInterval) in reversableDateComponents {
                let (_, dateComponents, namedShort) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: namedShort)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), namedShort)
            }
        }
    }

    private func platformAbbreviatedOutputFormat(abbreviated: String, short: String) -> String {
        #if !SKIP
        if #available(macOS 14, iOS 17, watchOS 10, tvOS 17, *) {
            return abbreviated
        }
        #endif
        return short
    }

    func test_namedAbbreviated() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        // e.g.: Test Suite 'Selected tests' started at 2025-03-01 22:20:41.122.Test Suite 'skip-foundationPackageTests.xctest' started at 2025-03-01 22:20:41.123.Test Suite 'TestRelativeDateTimeFormatter' started at 2025-03-01 22:20:41.123.Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedAbbreviated]' started./Users/runner/work/skip-foundation/skip-foundation/Tests/SkipFoundationTests/Formatters/TestRelativeDateTimeFormatter.swift:220: error: -[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedAbbreviated] : XCTAssertEqual failed: ("last yr.") is not equal to ("11 mo. ago")Test Case '-[SkipFoundationTests.TestRelativeDateTimeFormatter test_namedAbbreviated]' failed (0.751 seconds).Test Suite 'TestRelativeDateTimeFormatter' failed at 2025-03-01 22:20:41.874.
        throw XCTSkip("relative date formatting assumptions break when current date is at beginnging or end of month")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .abbreviated
        for (_, namedShort, namedAbbreviated, dateComponents, timeInterval) in customFormatting {
            let namedAbbreviated = platformAbbreviatedOutputFormat(abbreviated: namedAbbreviated, short: namedShort)
            XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), namedAbbreviated)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), namedAbbreviated)
        }
        for (_, namedShort, namedAbbreviated, dateComponents, _) in customDateComponents {
            let namedAbbreviated = platformAbbreviatedOutputFormat(abbreviated: namedAbbreviated, short: namedShort)
            XCTAssertEqual(formatter.localizedString(from: dateComponents), namedAbbreviated)
        }
        for direction in [-1, 1] {
            for (_, namedShort, _namedAbbreviated, dateComponents, timeInterval) in reversableRelativeTimes {
                let _namedAbbreviated = platformAbbreviatedOutputFormat(abbreviated: _namedAbbreviated, short: namedShort)
                let (timeInterval, dateComponents, namedAbbreviated) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: _namedAbbreviated)
                XCTAssertEqual(formatter.localizedString(fromTimeInterval: timeInterval), namedAbbreviated)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), namedAbbreviated)
            }
            for (_, namedShort, _namedAbbreviated, dateComponents, timeInterval) in reversableDateComponents {
                let _namedAbbreviated = platformAbbreviatedOutputFormat(abbreviated: _namedAbbreviated, short: namedShort)
                let (_, dateComponents, namedAbbreviated) = applyReversable(interval: timeInterval, components: dateComponents, direction: direction, formatString: _namedAbbreviated)
                XCTAssertEqual(formatter.localizedString(from: dateComponents), namedAbbreviated)
            }
        }
        #endif
    }

    fileprivate func spellOutNumbers(_ formatString: String) -> String {
        #if !SKIP
        return formatString
            .split(separator: " ").map {
                let word = String($0)
                guard let int = Int(word) else { return word }
                return spellOutNumberFormatter.string(from: int as NSNumber) ?? word
            }
            .joined(separator: " ")
        #else
        return formatString
        #endif
    }

    fileprivate func applyReversable(interval: TimeInterval, components: DateComponents, direction: Int, formatString: String) -> (TimeInterval, DateComponents, String) {
        let timeInterval = interval * Double(direction)
        let formattedString = rel(formatString, interval: timeInterval)
        var components = components
        if timeInterval < 0 {
            if components.year != nil {
                components.year = components.year! * -1
            }
            if components.month != nil {
                components.month = components.month! * -1
            }
            if components.weekOfMonth != nil {
                components.weekOfMonth = components.weekOfMonth! * -1
            }
            if components.day != nil {
                components.day = components.day! * -1
            }
            if components.hour != nil {
                components.hour = components.hour! * -1
            }
            if components.minute != nil {
                components.minute = components.minute! * -1
            }
            if components.second != nil {
                components.second = components.second! * -1
            }
            if components.nanosecond != nil {
                components.nanosecond = components.nanosecond! * -1
            }
            if components.weekday != nil {
                components.weekday = components.weekday! * -1
            }
        }
        return (timeInterval, components, formattedString)
    }
}

#endif
