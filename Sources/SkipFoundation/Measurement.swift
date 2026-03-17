// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public typealias NSMeasurement = Measurement

public struct Measurement<UnitType: FoundationUnit> : Hashable, Comparable, CustomStringConvertible {
    public var value: Double
    public var unit: UnitType

    public init(value: Double, unit: UnitType) {
        self.value = value
        self.unit = unit
    }

    // MARK: Conversion

    public func converted(to otherUnit: UnitType) -> Measurement<UnitType> {
        if unit === otherUnit || unit == otherUnit {
            return Measurement(value: value, unit: otherUnit)
        }
        guard let fromDim = unit as? Dimension,
              let toDim = otherUnit as? Dimension else {
            return Measurement(value: value, unit: otherUnit)
        }
        let baseValue = fromDim.converter.baseUnitValue(fromValue: value)
        let result = toDim.converter.value(fromBaseUnitValue: baseValue)
        return Measurement(value: result, unit: otherUnit)
    }

    // MARK: Equatable (exact comparison, matching Apple Foundation)

    public static func ==(lhs: Measurement, rhs: Measurement) -> Bool {
        if lhs.unit == rhs.unit { return lhs.value == rhs.value }
        guard let lhsDim = lhs.unit as? Dimension,
              let rhsDim = rhs.unit as? Dimension else {
            return false
        }
        let lhsBase = lhsDim.converter.baseUnitValue(fromValue: lhs.value)
        let rhsBase = rhsDim.converter.baseUnitValue(fromValue: rhs.value)
        return lhsBase == rhsBase
    }

    // MARK: Comparable

    public static func <(lhs: Measurement, rhs: Measurement) -> Bool {
        guard let lhsDim = lhs.unit as? Dimension,
              let rhsDim = rhs.unit as? Dimension else {
            return lhs.value < rhs.value
        }
        return lhsDim.converter.baseUnitValue(fromValue: lhs.value) <
               rhsDim.converter.baseUnitValue(fromValue: rhs.value)
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        if let dim = unit as? Dimension {
            hasher.combine(dim.converter.baseUnitValue(fromValue: value))
        } else {
            hasher.combine(value)
            hasher.combine(unit)
        }
    }

    // MARK: CustomStringConvertible

    public var description: String { "\(value) \(unit.symbol)" }

    // MARK: Arithmetic (named methods — Skip does not support custom operators)

    public func adding(_ other: Measurement) -> Measurement {
        if unit == other.unit {
            return Measurement(value: value + other.value, unit: unit)
        }
        let otherConverted = other.converted(to: unit)
        return Measurement(value: value + otherConverted.value, unit: unit)
    }

    public func subtracting(_ other: Measurement) -> Measurement {
        if unit == other.unit {
            return Measurement(value: value - other.value, unit: unit)
        }
        let otherConverted = other.converted(to: unit)
        return Measurement(value: value - otherConverted.value, unit: unit)
    }

    public mutating func negate() {
        value = -value
    }

    public func multiplied(by scalar: Double) -> Measurement {
        return Measurement(value: value * scalar, unit: unit)
    }

    public func divided(by scalar: Double) -> Measurement {
        return Measurement(value: value / scalar, unit: unit)
    }

    // NOTE: Codable is not conformable here — Kotlin type erasure prevents the
    // companion object from referencing the generic UnitType. All Codable
    // encode/decode happens on the native Swift side (Foundation /
    // swift-corelibs-foundation).
}

#else
import Foundation

// Provide the same named methods on native Foundation.Measurement
// so that cross-platform code can use either operators or named methods.
extension Measurement where UnitType: Dimension {
    public func adding(_ other: Measurement) -> Measurement {
        if unit == other.unit {
            return Measurement(value: value + other.value, unit: unit)
        }
        let otherConverted = other.converted(to: unit)
        return Measurement(value: value + otherConverted.value, unit: unit)
    }

    public func subtracting(_ other: Measurement) -> Measurement {
        if unit == other.unit {
            return Measurement(value: value - other.value, unit: unit)
        }
        let otherConverted = other.converted(to: unit)
        return Measurement(value: value - otherConverted.value, unit: unit)
    }

    public func multiplied(by scalar: Double) -> Measurement {
        return Measurement(value: value * scalar, unit: unit)
    }

    public func divided(by scalar: Double) -> Measurement {
        return Measurement(value: value / scalar, unit: unit)
    }
}

#endif
