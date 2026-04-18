// Copyright 2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

// "Unit" is a reserved name in Kotlin (kotlin.Unit). On iOS, Foundation.Unit
// is used directly. In Skip/Kotlin, FoundationUnit is the base class; consumers
// use Dimension subclasses (UnitMass, UnitLength, etc.) — not Unit directly.
public typealias NSUnit = FoundationUnit
public typealias NSDimension = Dimension

// MARK: - UnitConverter

public class UnitConverter {
    public init() {}

    public func baseUnitValue(fromValue value: Double) -> Double {
        return value
    }

    public func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return baseUnitValue
    }
}

// MARK: - UnitConverterLinear

public final class UnitConverterLinear : UnitConverter, Hashable {
    public let coefficient: Double
    public let constant: Double

    public init(coefficient: Double, constant: Double = 0) {
        self.coefficient = coefficient
        self.constant = constant
        super.init()
    }

    public override func baseUnitValue(fromValue value: Double) -> Double {
        return value * coefficient + constant
    }

    public override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return (baseUnitValue - constant) / coefficient
    }

    public static func ==(lhs: UnitConverterLinear, rhs: UnitConverterLinear) -> Bool {
        return lhs.coefficient == rhs.coefficient && lhs.constant == rhs.constant
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(coefficient)
        hasher.combine(constant)
    }
}

// MARK: - UnitConverterReciprocal

public final class UnitConverterReciprocal : UnitConverter, Hashable {
    public let reciprocal: Double

    public init(reciprocal: Double) {
        self.reciprocal = reciprocal
        super.init()
    }

    public override func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal / value
    }

    public override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal / baseUnitValue
    }

    public static func ==(lhs: UnitConverterReciprocal, rhs: UnitConverterReciprocal) -> Bool {
        return lhs.reciprocal == rhs.reciprocal
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(reciprocal)
    }
}

// MARK: - FoundationUnit (named to avoid Kotlin's kotlin.Unit conflict)

public class FoundationUnit : Hashable, CustomStringConvertible {
    public let symbol: String

    public init(symbol: String) {
        self.symbol = symbol
    }

    public var description: String { symbol }

    public static func ==(lhs: FoundationUnit, rhs: FoundationUnit) -> Bool {
        if lhs === rhs { return true }
        guard type(of: lhs) == type(of: rhs) else { return false }
        return lhs.symbol == rhs.symbol
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

// MARK: - Dimension

public class Dimension : FoundationUnit {
    public let converter: UnitConverter

    public init(symbol: String, converter: UnitConverter) {
        self.converter = converter
        super.init(symbol: symbol)
    }

    public class func baseUnit() -> Dimension {
        fatalError("Subclass must override baseUnit()")
    }

    public static func ==(lhs: Dimension, rhs: Dimension) -> Bool {
        if lhs === rhs { return true }
        guard type(of: lhs) == type(of: rhs) else { return false }
        guard lhs.symbol == rhs.symbol else { return false }
        // Compare converters by type and value
        if let lc = lhs.converter as? UnitConverterLinear,
           let rc = rhs.converter as? UnitConverterLinear {
            return lc == rc
        }
        if let lr = lhs.converter as? UnitConverterReciprocal,
           let rr = rhs.converter as? UnitConverterReciprocal {
            return lr == rr
        }
        return false
    }

    public override func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
        if let lc = converter as? UnitConverterLinear {
            hasher.combine(lc)
        } else if let lr = converter as? UnitConverterReciprocal {
            hasher.combine(lr)
        }
    }
}

#endif
