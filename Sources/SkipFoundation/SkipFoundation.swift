// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

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

#if SKIP
public func NSLog(_ message: String) {
    print(message)
}
#endif

#if SKIP
public typealias NSObject = java.lang.Object

public protocol NSObjectProtocol {
}
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

/// The Objective-C BOOL type.
public struct ObjCBool {
    public var boolValue: Bool
    public init(_ value: Bool) { self.boolValue = value }
    public init(booleanLiteral value: Bool) { self.boolValue = value }
}

// MARK: Foundation Stubs

#if SKIP

internal struct EnergyFormatter {
}

internal struct LengthFormatter {
}

internal struct MassFormatter {
}

internal protocol SocketPort {
}

internal protocol PersonNameComponents {
}

public class NSCoder : NSObject {
}

internal protocol NSRange {
}

internal class NSArray : NSObject {
}

internal class NSMutableArray : NSArray {
}

internal class NSPredicate : NSObject {
}

internal class NSTextCheckingResult : NSObject {
}

internal protocol NSBinarySearchingOptions {
}

#endif
