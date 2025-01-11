// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias Decimal = java.math.BigDecimal
public typealias NSDecimalNumber = java.math.BigDecimal
public typealias NSNumber = java.lang.Number

public extension java.lang.Number {
    var doubleValue: Double { doubleValue() }
    var intValue: Int { intValue() }
    var longValue: Int64 { longValue() }
    var int64Value: Int64 { longValue() }
    var int32Value: Int32 { intValue() }
    var int16Value: Int16 { shortValue() }
    var int8Value: Int8 { byteValue() }
}

// Initializing an NSNumber with a numeric value just returns the instance itself
public func NSNumber(value: Int8) -> NSNumber { value as NSNumber }
public func NSNumber(value: Int16) -> NSNumber { value as NSNumber }
public func NSNumber(value: Int32) -> NSNumber { value as NSNumber }
public func NSNumber(value: Int64) -> NSNumber { value as NSNumber }
public func NSNumber(value: UInt8) -> NSNumber { value as NSNumber }
public func NSNumber(value: UInt16) -> NSNumber { value as NSNumber }
public func NSNumber(value: UInt32) -> NSNumber { value as NSNumber }
public func NSNumber(value: UInt64) -> NSNumber { value as NSNumber }
public func NSNumber(value: Float) -> NSNumber { value as NSNumber }
public func NSNumber(value: Double) -> NSNumber { value as NSNumber }

// NSNumber also accepts unlabeled values. Add an additional unused argument to satisfy the Kotlin compiler that they are different functions.
public func NSNumber(_ v: Int8, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: Int16, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: Int32, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: Int64, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: UInt8, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: UInt16, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: UInt32, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: UInt64, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: Float, unusedp: ()? = nil) -> NSNumber { v as NSNumber }
public func NSNumber(_ v: Double, unusedp: ()? = nil) -> NSNumber { v as NSNumber }

public extension java.math.BigDecimal {
//    static let zero = java.math.BigDecimal(0)
//    static let pi = java.math.BigDecimal("3.14159265358979323846264338327950288419")
//
//    @available(*, unavailable)
//    static let nan = java.math.BigDecimal(0) // BigDecimal class provides no representation of nan
}

#endif
