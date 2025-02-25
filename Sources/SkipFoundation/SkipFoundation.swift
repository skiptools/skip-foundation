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

extension Array where Element: Hashable {
    /// Returns an array containing only the unique elements of the array, preserving the order of the first occurrence of each element.
    func distinctValues() -> [Element] {
        var seen = Set<Element>()
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
}

public typealias NSObject = java.lang.Object

public protocol NSObjectProtocol {
}

public class NSNull {
    public static let null = NSNull()
    public init() {
    }
}

/// The Objective-C BOOL type.
public struct ObjCBool {
    public var boolValue: Bool
    public init(_ value: Bool) { self.boolValue = value }
    public init(booleanLiteral value: Bool) { self.boolValue = value }
}

// MARK: Foundation Stubs

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
