// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import Foundation
import XCTest

final class TestCalendarEnumerate: XCTestCase {

    // MARK: - Variables
    private var sut: Calendar!

    // MARK: - Initialization

    /// Suite-level setup method called before the class begins to run any of its test methods
    /// or their associated per-instance setUp methods.
    override func setUp() {
        super.setUp()

        self.sut = Calendar(identifier: .gregorian)
        self.sut.timeZone = TimeZone(identifier: "UTC")!
    }

    // MARK: - Next Date Tests
    func testNextDate_year_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2023

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2023-01-01T00:00:00Z")
    }

    func testNextDate_year_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-01-01T00:00:00Z")
    }

    func testNextDate_quarter_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.quarter = 3

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-07-01T00:00:00Z")
    }

    func testNextDate_quarter_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.quarter = 3

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-07-01T00:00:00Z")
    }

    func testNextDate_month_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 6

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-06-01T00:00:00Z")
    }

    func testNextDate_month_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 6

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-06-01T00:00:00Z")
    }

    func testNextDate_weekOfYear_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.weekOfYear = 42

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-10-11T00:00:00Z")
    }

    func testNextDate_weekOfYear_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.weekOfYear = 42

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-10-09T00:00:00Z")
    }

    func testNextDate_weekOfMonth_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 10
        components.weekOfMonth = 2

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-10-04T00:00:00Z")
    }

    func testNextDate_weekOfMonth_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 10
        components.weekOfMonth = 2

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-10-03T00:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testNextDate_dayOfYear_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.dayOfYear = 123

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-05-02T00:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testNextDate_dayOfYear_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.dayOfYear = 123

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-05-03T00:00:00Z")
    }

    func testNextDate_day_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 8
        components.day = 12

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-08-12T00:00:00Z")
    }

    func testNextDate_day_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 8
        components.day = 12

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2022-08-12T00:00:00Z")
    }

    func testNextDate_weekday_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-01-07T00:00:00Z")
    }

    func testNextDate_weekday_backward_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        /// Maybe a bug in the Swift foundation library itself? Would have expected: 2020-01-07T00:00:00Z.
        XCTAssertNil(result)
    }

    func testNextDate_weekdayOrdinal_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 4

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-01-28T00:00:00Z")
    }

    func testNextDate_weekdayOrdinal_backward_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 4

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        /// Maybe a bug in the Swift foundation library itself? Would have expected: 2020-01-28T00:00:00Z.
        XCTAssertNil(result)
    }

    func testNextDate_time_forward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.hour = 12
        components.minute = 12
        components.second = 12

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .forward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2020-01-01T12:12:12Z")
    }

    func testNextDate_time_backward_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        components.hour = 12
        components.minute = 12
        components.second = 12

        // Act
        let result = self.sut.nextDate(after: start, matching: components, matchingPolicy: .strict, direction: .backward)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.ISO8601Format(), "2019-12-31T12:12:12Z")
    }

    // MARK: - Enumerate Dates (Year) Tests
    func testEnumerateDates_years_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2023

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2023-01-01T00:00:00Z")
    }

    func testEnumerateDates_years_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_years_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-01-01T00:00:00Z")
    }

    func testEnumerateDates_years_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_years_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-07-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2026-01-01T01:00:00Z")
    }

    func testEnumerateDates_years_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2026-12-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2026-01-01T01:00:00Z")
    }

    // MARK: - Enumerate Dates (Quarter) Tests
    func testEnumerateDates_quarter_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.quarter = 3

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-07-01T00:00:00Z")
    }

    func testEnumerateDates_quarter_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.quarter = 5

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_quarter_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.quarter = 3

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-07-01T00:00:00Z")
    }

    func testEnumerateDates_quarter_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.quarter = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_quarter_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-07-01T00:00:00Z")!
        var components = DateComponents()
        components.quarter = 4
        components.weekday = 3
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-07T00:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2026-10-06T00:00:00Z")
    }

    func testEnumerateDates_quarter_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.quarter = 4

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-12-31T22:59:59Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2023-12-31T22:59:59Z")
    }

    // MARK: - Enumerate Dates (Month) Tests

    func testEnumerateDates_month_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 6

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-06-01T00:00:00Z")
    }

    func testEnumerateDates_month_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 13

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_month_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 6

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-06-01T00:00:00Z")
    }

    func testEnumerateDates_month_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_month_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-09-01T00:00:00Z")!
        var components = DateComponents()
        components.month = 11
        components.day = 1
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-11-01T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2026-11-01T01:00:00Z")
    }

    func testEnumerateDates_month_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.month = 11
        components.day = 1
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-11-01T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2024-11-01T01:00:00Z")
    }

    // MARK: - Enumerate Dates (Week of Year) Tests
    func testEnumerateDates_weekOfYear_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.weekOfYear = 42

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-10-11T00:00:00Z")
    }

    func testEnumerateDates_weekOfYear_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.weekOfYear = 53

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekOfYear_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.weekOfYear = 42

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-10-09T00:00:00Z")
    }

    func testEnumerateDates_weekOfYear_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.weekOfYear = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekOfYear_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-07-01T00:00:00Z")!
        var components = DateComponents()
        components.weekOfYear = 44
        components.weekday = 3
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2026-10-27T01:00:00Z")
    }

    func testEnumerateDates_weekOfYear_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.weekOfYear = 44

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-25T23:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2024-10-26T23:00:00Z")
    }

    // MARK: - Enumerate Dates (Week of Month) Tests

    func testEnumerateDates_weekOfMonth_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 10
        components.weekOfMonth = 2

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-10-04T00:00:00Z")
    }

    func testEnumerateDates_weekOfMonth_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 10
        components.weekOfMonth = 6

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekOfMonth_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 10
        components.weekOfMonth = 2

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-10-03T00:00:00Z")
    }

    func testEnumerateDates_weekOfMonth_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 10
        components.weekOfMonth = 6

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekOfMonth_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-10-01T00:00:00Z")!
        var components = DateComponents()
        components.weekOfMonth = 5
        components.weekday = 3
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-11-25T01:00:00Z")
    }

    func testEnumerateDates_weekOfMonth_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.weekOfMonth = 5

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 4 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-11-22T23:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-10-25T22:00:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2025-09-27T22:00:00Z")
        XCTAssertEqual(results[3].ISO8601Format(), "2025-08-23T22:00:00Z")
    }

    // MARK: - Enumerate Dates (Day of Year) Tests
    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.dayOfYear = 123

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-05-02T00:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.dayOfYear = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forward_isLeapYear_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.dayOfYear = 366

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-12-31T00:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forward_isNoLeapYear_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2025
        components.dayOfYear = 366

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.dayOfYear = 123

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-05-03T00:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.dayOfYear = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backward_isLeapYear_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.dayOfYear = 366

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-12-31T23:59:59Z")
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backward_isNoLeapYear_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2026-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2025
        components.dayOfYear = 366

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-07-01T00:00:00Z")!
        var components = DateComponents()
        components.dayOfYear = 301
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2026-10-28T01:00:00Z")
    }

    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.dayOfYear = 301
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2024-10-27T00:00:00Z")
    }

    // MARK: - Enumerate Dates (Day) Tests

    func testEnumerateDates_day_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 8
        components.day = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-08-12T00:00:00Z")
    }

    func testEnumerateDates_day_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 8
        components.day = 32

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_day_forward_isLeapYear_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 29

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-02-29T00:00:00Z")
    }

    func testEnumerateDates_day_forward_isNoLeapYear_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 29

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_day_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 8
        components.day = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-08-12T00:00:00Z")
    }

    func testEnumerateDates_day_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2022
        components.month = 8
        components.day = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_day_backward_isLeapYear_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 29

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-02-29T00:00:00Z")
    }

    func testEnumerateDates_day_backward_isNoLeapYear_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2026-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2025
        components.month = 2
        components.day = 29

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_day_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-10-24T00:00:00Z")!
        var components = DateComponents()
        components.day = 27
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-27T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-11-27T01:00:00Z")
    }

    func testEnumerateDates_day_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-10-30T00:00:00Z")!
        var components = DateComponents()
        components.day = 27
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 2 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-27T01:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-09-27T00:00:00Z")
    }

    // MARK: - Enumerate Dates (Weekday) Tests
    func testEnumerateDates_weekday_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-01-07T00:00:00Z")
    }

    func testEnumerateDates_weekday_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 8

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekday_backward_validComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        /// Maybe a bug in the Swift foundation library itself? Would have expected: 2020-01-07T00:00:00Z.
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekday_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = -1

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekday_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-07-01T00:00:00Z")!
        var components = DateComponents()
        components.weekday = 3
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 18 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 18)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-07-08T00:00:00Z")
        XCTAssertEqual(results[15].ISO8601Format(), "2025-10-21T00:00:00Z")
        XCTAssertEqual(results[16].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[17].ISO8601Format(), "2025-11-04T01:00:00Z")
    }

    func testEnumerateDates_weekday_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.weekday = 3
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 6 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 6)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-11-25T01:00:00Z")
        XCTAssertEqual(results[3].ISO8601Format(), "2025-11-04T01:00:00Z")
        XCTAssertEqual(results[4].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[5].ISO8601Format(), "2025-10-21T00:00:00Z")
    }

    // MARK: - Enumerate Dates (Weekday Ordinal) Tests
    func testEnumerateDates_weekdayOrdinal_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 4

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-01-28T00:00:00Z")
    }

    func testEnumerateDates_weekdayOrdinal_forward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 5

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekdayOrdinal_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 4

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        /// Maybe a bug in the Swift foundation library itself? Would have expected: 2020-01-28T00:00:00Z.
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekdayOrdinal_backward_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2021-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.month = 1
        components.weekday = 3
        components.weekdayOrdinal = 5

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_weekdayOrdinal_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-09-01T00:00:00Z")!
        var components = DateComponents()
        components.weekday = 3
        components.weekdayOrdinal = 4
        components.hour = 2
        components.minute = 0
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 3 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-09-23T00:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-10-28T01:00:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2025-11-25T01:00:00Z")
    }

    func testEnumerateDates_weekdayOrdinal_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-12-01T00:00:00Z")!
        var components = DateComponents()
        components.weekdayOrdinal = 4

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 4 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-11-27T23:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-10-27T23:00:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2025-09-27T22:00:00Z")
        XCTAssertEqual(results[3].ISO8601Format(), "2025-08-27T22:00:00Z")
    }

    // MARK: - Enumerate Dates (Time) Tests
    func testEnumerateDates_time_forward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.hour = 12
        components.minute = 12
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-01-01T12:12:12Z")
    }

    func testEnumerateDates_time_forward_invalidHour_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.hour = 25
        components.minute = 12
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_forward_invalidMinute_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.hour = 12
        components.minute = 61
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_forward_invalidSecond_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        components.hour = 12
        components.minute = 12
        components.second = 61

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_backward_validComponents_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        components.hour = 12
        components.minute = 12
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2019-12-31T12:12:12Z")
    }

    func testEnumerateDates_time_backward_invalidHour_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        components.hour = 25
        components.minute = 12
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_backward_invalidMinute_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        components.hour = 12
        components.minute = 61
        components.second = 12

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_backward_invalidSecond_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        components.hour = 12
        components.minute = 12
        components.second = 61

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_time_forward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-10-25T20:30:00Z")!
        var components = DateComponents()
        components.hour = 2
        components.minute = 30
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 3 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-26T00:30:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-10-27T01:30:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2025-10-28T01:30:00Z")
    }

    func testEnumerateDates_time_backward_dstOffset_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2025-10-26T06:00:00Z")!
        var components = DateComponents()
        components.hour = 2
        components.minute = 30
        components.second = 0

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 3 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].ISO8601Format(), "2025-10-26T01:30:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-10-25T00:30:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2025-10-24T00:30:00Z")
    }

    // MARK: - Special Tests
    func testEnumerateDates_dstGap_forward_nextTime_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2024-03-31T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.day = 31
        components.month = 3
        components.hour = 2
        components.minute = 30

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .nextTime, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-03-31T01:00:00Z")
    }

    func testEnumerateDates_dstGap_forward_strict_shouldReturnNil() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2024-03-31T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.day = 31
        components.month = 3
        components.hour = 2
        components.minute = 30

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_dstGap_backward_nextTime_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2024-04-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.day = 31
        components.month = 3
        components.hour = 2
        components.minute = 30

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .nextTime, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-03-31T01:00:00Z")
    }

    func testEnumerateDates_dstGap_backward_strict_shouldReturnExpectedResult() {
        // Arrange
        self.sut.timeZone = TimeZone(identifier: "Europe/Berlin")!

        let start = ISO8601DateFormatter().date(from: "2024-04-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        components.day = 31
        components.month = 3
        components.hour = 2
        components.minute = 30

        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
                stop = true
            }
        }

        // Assert
        XCTAssertTrue(results.isEmpty)
    }

    func testEnumerateDates_thanksgivingForMultipleYears_shouldReturnExpectedResult() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2024-01-01T00:00:00Z")!

        var components = DateComponents()
        components.month = 11
        components.weekday = 5
        components.weekdayOrdinal = 4

        // Act
        var results: [Date] = []
        var iterations = 0
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
            iterations += 1
            if iterations >= 3 {
                stop = true
            }
        }

        // Assert
        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0].ISO8601Format(), "2024-11-28T00:00:00Z")
        XCTAssertEqual(results[1].ISO8601Format(), "2025-11-27T00:00:00Z")
        XCTAssertEqual(results[2].ISO8601Format(), "2026-11-26T00:00:00Z")
    }
}
