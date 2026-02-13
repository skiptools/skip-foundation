// Copyright 2023–2026 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

final class TestCalendarEnumerate: XCTestCase {
    
    // MARK: - Variables
    private let sut: Calendar = {
        var result = Calendar(identifier: .gregorian)
        result.timeZone = TimeZone(identifier: "UTC")!
        return result
    }()
    
    /*
    
    // MARK: - Enumerate Year Tests
    
    /// Forward
    func testEnumerateYears_forwardDirection_validComponents_shouldReturnExpectedDate() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2023
        
        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2023-01-01T00:00:00Z")
    }
    
    func testEnumerateYears_forwardDirection_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2020-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2019
        
        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .forward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    
    /// Backward
    func testEnumerateYears_backwardDirection_validComponents_shouldReturnExpectedDate() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2020
        
        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-01-01T00:00:00Z")
    }
    
    func testEnumerateYears_backwardDirection_invalidComponents_shouldReturnNil() {
        // Arrange
        let start = ISO8601DateFormatter().date(from: "2023-01-01T00:00:00Z")!
        var components = DateComponents()
        components.year = 2024
        
        // Act
        var results: [Date] = []
        self.sut.enumerateDates(startingAfter: start, matching: components, matchingPolicy: .strict, direction: .backward) { (date, _, stop) in
            if let date = date {
                results.append(date)
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: - Enumerate Quarter Tests
    
    /// Forward
    func testEnumerateQuarters_forwardDirection_validComponents_shouldReturnExpectedDate() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-07-01T00:00:00Z")
    }
    
    func testEnumerateQuarters_forwardDirection_invalidComponents_shouldReturnNil() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    
    /// Backward
    func testEnumerateQuarters_backwardDirection_validComponents_shouldReturnExpectedDate() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-07-01T00:00:00Z")
    }
    
    func testEnumerateQuarters_backwardDirection_invalidComponents_shouldReturnNil() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    
    // MARK: - Enumerate Month Tests
    
    /// Forward
    func testEnumerateMonths_forwardDirection_validComponents_shouldReturnExpectedDate() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2020-06-01T00:00:00Z")
    }
    
    func testEnumerateMonths_forwardDirection_invalidComponents_shouldReturnNil() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    
    /// Backward
    func testEnumerateMonths_backwardDirection_validComponents_shouldReturnExpectedDate() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].ISO8601Format(), "2022-06-01T00:00:00Z")
    }
    
    func testEnumerateMonths_backwardDirection_invalidComponents_shouldReturnNil() {
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
            }
        }
        
        // Assert
        XCTAssertEqual(results.count, 0)
    }
    */
}
