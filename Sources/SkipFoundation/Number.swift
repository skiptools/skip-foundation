// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
@_implementationOnly import struct Foundation.Decimal
internal typealias Decimal = Foundation.Decimal
internal typealias NSDecimalNumber = Decimal
#else
public typealias Decimal = java.math.BigDecimal
public typealias NSDecimalNumber = java.math.BigDecimal
#endif

#if !SKIP
@_implementationOnly import class Foundation.NSNumber

public typealias NSNumber = NSNumberWrapper
public struct NSNumberWrapper : Hashable {
    internal let platformValue: Foundation.NSNumber

    init(platformValue: Foundation.NSNumber) {
        self.platformValue = platformValue
    }

    public init(value: CChar) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: UInt8) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Int16) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: UInt16) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Int32) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: UInt32) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Int64) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: UInt64) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Float) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Double) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Bool) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: Int) { self.init(platformValue: Foundation.NSNumber(value: value)) }
    public init(value: UInt) { self.init(platformValue: Foundation.NSNumber(value: value)) }

    public var int8Value: CChar { platformValue.int8Value }
    public var uint8Value: UInt8 { platformValue.uint8Value }
    public var int16Value: Int16 { platformValue.int16Value }
    public var uint16Value: UInt16 { platformValue.uint16Value }
    public var int32Value: Int32 { platformValue.int32Value }
    public var uint32Value: UInt32 { platformValue.uint32Value }
    public var int64Value: Int64 { platformValue.int64Value }
    public var uint64Value: UInt64 { platformValue.uint64Value }
    public var floatValue: Float { platformValue.floatValue }
    public var doubleValue: Double { platformValue.doubleValue }
    public var boolValue: Bool { platformValue.boolValue }
    public var intValue: Int { platformValue.intValue }
    public var uintValue: UInt { platformValue.uintValue }
    public var stringValue: String { platformValue.stringValue }
}
#else
public typealias NSNumber = java.lang.Number
#endif

#if SKIP
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

#endif
