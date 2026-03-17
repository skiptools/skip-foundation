// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
import XCTest

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestMeasurement: XCTestCase {
    #if !SKIP
    func testHashing() {
        let lengths: [[Measurement<UnitLength>]] = [
            [
                Measurement(value: 5, unit: UnitLength.kilometers),
                Measurement(value: 5000, unit: UnitLength.meters),
                Measurement(value: 5000, unit: UnitLength.meters),
            ],
            [
                Measurement(value: 1, unit: UnitLength.kilometers),
                Measurement(value: 1000, unit: UnitLength.meters),
            ],
            [
                Measurement(value: 1, unit: UnitLength.meters),
                Measurement(value: 1000, unit: UnitLength.millimeters),
            ],
        ]
        checkHashableGroups(lengths)

        let durations: [[Measurement<UnitDuration>]] = [
            [
                Measurement(value: 3600, unit: UnitDuration.seconds),
                Measurement(value: 60, unit: UnitDuration.minutes),
                Measurement(value: 1, unit: UnitDuration.hours),
            ],
            [
                Measurement(value: 1800, unit: UnitDuration.seconds),
                Measurement(value: 30, unit: UnitDuration.minutes),
                Measurement(value: 0.5, unit: UnitDuration.hours),
            ]
        ]
        checkHashableGroups(durations)

#if false && !DARWIN_COMPATIBILITY_TESTS
        let custom: [Measurement<CustomUnit>] = [
            Measurement(value: 1, unit: CustomUnit.bugs),
            Measurement(value: 2, unit: CustomUnit.bugs),
            Measurement(value: 3, unit: CustomUnit.bugs),
            Measurement(value: 4, unit: CustomUnit.bugs),
            Measurement(value: 1, unit: CustomUnit.features),
            Measurement(value: 2, unit: CustomUnit.features),
            Measurement(value: 3, unit: CustomUnit.features),
            Measurement(value: 4, unit: CustomUnit.features),
        ]
        checkHashable(custom, equalityOracle: { $0 == $1 })
#endif
    }

    let fixtures = [
        Fixtures.zeroMeasurement,
        Fixtures.lengthMeasurement,
        Fixtures.frequencyMeasurement,
        Fixtures.angleMeasurement,
    ]

    func testCodingRoundtrip() throws {
        for fixture in fixtures {
            try fixture.assertValueRoundtripsInCoder()
        }
    }

    func testLoadedValuesMatch() throws {
        for fixture in fixtures {
//            try fixture.assertLoadedValuesMatch()
        }
    }
    #endif

    func testMeasurementCreation() {
        let m = Measurement(value: 42.0, unit: UnitLength.meters)
        XCTAssertEqual(m.value, 42.0)
        XCTAssertEqual(m.unit.symbol, "m")
    }

    func testMeasurementConversion() {
        let km = Measurement(value: 1.0, unit: UnitLength.kilometers)
        let m = km.converted(to: UnitLength.meters)
        XCTAssertEqual(m.value, 1000.0, accuracy: 0.001)
    }

    func testMeasurementEquality() {
        let a = Measurement(value: 1000.0, unit: UnitLength.meters)
        let b = Measurement(value: 1.0, unit: UnitLength.kilometers)
        XCTAssertEqual(a, b)
    }

    func testMeasurementComparison() {
        let a = Measurement(value: 1.0, unit: UnitLength.kilometers)
        let b = Measurement(value: 500.0, unit: UnitLength.meters)
        XCTAssertTrue(a > b)
    }

    func testMeasurementArithmetic() {
        let a = Measurement(value: 2.0, unit: UnitMass.kilograms)
        let b = Measurement(value: 500.0, unit: UnitMass.grams)
        let sum = a + b
        XCTAssertEqual(sum.converted(to: UnitMass.kilograms).value, 2.5, accuracy: 0.001)
    }
}
