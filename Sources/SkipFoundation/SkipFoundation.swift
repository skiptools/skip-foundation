// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

/// A runtime check for whether we are running in a JVM, which is based on whether Ints are 32 or 64 bit
public let isJVM = Int.max == Int32.max

internal func SkipFoundationInternalModuleName() -> String {
    return "SkipFoundation"
}

public func SkipFoundationPublicModuleName() -> String {
    return "SkipFoundation"
}

/// A shim that pretends to return any `T`, but just crashes with a fatal error.
func SkipCrash<T>(_ reason: String) -> T {
    fatalError("skipme: \(reason)")
}

// MARK: Foundation Adapter Types

#if SKIP
public typealias NSObject = java.lang.Object
public typealias NSString = kotlin.String

public protocol NSObjectProtocol {
}
#endif

#if !SKIP

internal extension RawRepresentable {
    /// Creates a `RawRepresentable` with another `RawRepresentable` that has the same underlying type
    func rekey<NewKey : RawRepresentable>() -> NewKey? where NewKey.RawValue == RawValue {
        NewKey(rawValue: rawValue)
    }
}

internal extension Dictionary where Key : RawRepresentable {
    /// Remaps a dictionary to another key type with a compatible raw value
    func rekey<NewKey : Hashable & RawRepresentable>() -> [NewKey: Value] where NewKey.RawValue == Key.RawValue {
        Dictionary<NewKey, Value>(uniqueKeysWithValues: map {
            (NewKey(rawValue: $0.rawValue)!, $1)
        })
    }
}
#endif


#if !SKIP
@_implementationOnly import struct Foundation.Decimal
internal typealias Decimal = Foundation.Decimal
internal typealias NSDecimalNumber = Decimal
#else
public typealias Decimal = java.math.BigDecimal
public typealias NSDecimalNumber = java.math.BigDecimal
#endif

#if !SKIP
public typealias PlatformStringEncoding = StringEncoding
#else
internal typealias PlatformStringEncoding = String.Encoding
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


#if !SKIP
@_implementationOnly import class Foundation.NSNull
internal typealias NSNull = Foundation.NSNull
#else
public class NSNull {
    public static let null = NSNull()
    public init() {
    }
}
#endif

/// The Objective-C BOOL type.
public struct ObjCBool {
    public var boolValue: Bool
    public init(_ value: Bool) { self.boolValue = value }
    public init(booleanLiteral value: Bool) { self.boolValue = value }
}

public enum ComparisonResult : Int {
    case ascending = -1
    case same = 0
    case descending = 1
}


#if SKIP

//public extension NSObjectProtocol {
//    public var description: String { "\(self)" }
//    public func isEqual(_ other: Any?) -> Bool { other === self }
//}

public func NSString(string: String) -> NSString { string }

public extension java.lang.Number {
    var doubleValue: Double { doubleValue() }
    var intValue: Int { intValue() }
    var longValue: Int64 { longValue() }
    var int64Value: Int64 { longValue() }
    var int32Value: Int32 { intValue() }
    var int16Value: Int16 { shortValue() }
    var int8Value: Int8 { byteValue() }
}

/// Initializing an NSNumber with a numeric value just returns the instance itself
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
/// NSNumber also accepts unlabeled values. Add an additional unused argument to satisfy the Kotlin compiler that they are different functions.
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

// MARK: Foundation Stubs

internal protocol SocketPort {
}

internal protocol AttributedString {
}

internal protocol NotificationCenter {
}

internal protocol PersonNameComponents {
}

internal protocol Operation {
}

internal protocol OperationQueue {
}

internal class XMLParser {
}

internal protocol XMLParserDelegate {
}

internal class URLCache {
    public enum StoragePolicy {
        case allowed
        case allowedInMemoryOnly
        case notAllowed
    }
}

internal protocol CachedURLResponse {
}

internal func strlen(_ string: String) -> Int {
    return string.count
}

internal func strncmp(_ str1: String, _ str2: String) -> Int {
    return str1.toLowerCase() == str2.toLowerCase() ? 0 : 1
}

internal func NSLog(_ message: String) {
    //logger.info(message)
    print(message)
}

public class NSCoder : NSObject {
}

internal protocol NSRange {
}

internal class NSArray : NSObject {
}

internal class NSMutableArray : NSArray {
}

internal class NSDateComponents : NSArray {
}

internal class NSPredicate : NSObject {
}

internal class NSTextCheckingResult : NSObject {
}

internal protocol NSBinarySearchingOptions {
}

// MARK: Foundation Placeholders

internal protocol DateIntervalFormatter {
}

internal struct EnergyFormatter {
}

internal struct LengthFormatter {
}

internal struct MassFormatter {
}

internal protocol HTTPCookieStorage {
}

#endif
