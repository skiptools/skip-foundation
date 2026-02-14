// Copyright 2023–2026 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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
    
    // MARK: - Enumerate Dates (Year) Tests
    
    /// Forward
    func testEnumerateDates_years_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_years_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_years_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_years_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Quarter) Tests
    
    /// Forward
    func testEnumerateDates_quarters_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_quarters_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_quarters_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_quarters_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Month) Tests
    
    /// Forward
    func testEnumerateDates_month_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_month_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_month_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_month_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Week of Year) Tests
    
    /// Forward
    func testEnumerateDates_weekOfYear_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekOfYear_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_weekOfYear_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekOfYear_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Week of Month) Tests
    
    /// Forward
    func testEnumerateDates_weekOfMonth_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekOfMonth_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_weekOfMonth_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekOfMonth_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Day of Year) Tests
    
    /// Forward
    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    func testEnumerateDates_dayOfYear_forwardDirection_invalidComponents_shouldReturnNil() {
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
    func testEnumerateDates_dayOfYear_forwardDirection_isLeapYear_shouldReturnExpectedResult() {
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
    func testEnumerateDates_dayOfYear_forwardDirection_isNoLeapYear_shouldReturnNil() {
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
    
    /// Backward
    @available(macOS 15, iOS 18, *)
    func testEnumerateDates_dayOfYear_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    func testEnumerateDates_dayOfYear_backwardDirection_invalidComponents_shouldReturnNil() {
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
    func testEnumerateDates_dayOfYear_backwardDirection_isLeapYear_shouldReturnExpectedResult() {
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
    func testEnumerateDates_dayOfYear_backwardDirection_isNoLeapYear_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Day) Tests
    
    /// Forward
    func testEnumerateDates_day_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_day_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    func testEnumerateDates_day_forwardDirection_isLeapYear_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_day_forwardDirection_isNoLeapYear_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_day_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_day_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    func testEnumerateDates_day_backwardDirection_isLeapYear_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_day_backwardDirection_isNoLeapYear_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Weekday) Tests
    
    /// Forward
    func testEnumerateDates_weekday_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekday_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_weekdayOrdinal_backwardDirection_validComponents_shouldReturnNil() {
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
    
    func testEnumerateDates_weekday_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Weekday Ordinal) Tests
    
    /// Forward
    func testEnumerateDates_weekdayOrdinal_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekdayOrdinal_forwardDirection_invalidComponents_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_weekdayOrdinal_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_weekdayOrdinal_backwardDirection_invalidComponents_shouldReturnNil() {
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
    
    // MARK: - Enumerate Dates (Time) Tests
    
    /// Forward
    func testEnumerateDates_time_forwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_time_forwardDirection_invalidHour_shouldReturnNil() {
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
    
    func testEnumerateDates_time_forwardDirection_invalidMinute_shouldReturnNil() {
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
    
    func testEnumerateDates_time_forwardDirection_invalidSecond_shouldReturnNil() {
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
    
    /// Backward
    func testEnumerateDates_time_backwardDirection_validComponents_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_time_backwardDirection_invalidHour_shouldReturnNil() {
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
    
    func testEnumerateDates_time_backwardDirection_invalidMinute_shouldReturnNil() {
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
    
    func testEnumerateDates_time_backwardDirection_invalidSecond_shouldReturnNil() {
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
    
    // MARK: - Special Tests
    func testEnumerateDates_dstGap_forwardDirection_nextTime_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_dstGap_forwardDirection_strict_shouldReturnNil() {
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
    
    func testEnumerateDates_dstGap_backwardDirection_nextTime_shouldReturnExpectedResult() {
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
    
    func testEnumerateDates_dstGap_backwardDirection_strict_shouldReturnExpectedResult() {
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
