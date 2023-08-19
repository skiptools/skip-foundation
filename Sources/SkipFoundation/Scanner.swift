// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.Scanner
typealias PlatformScanner = Foundation.Scanner
#else
typealias PlatformScanner = java.util.Scanner
#endif

public class Scanner : CustomStringConvertible {
    let platformValue: PlatformScanner

    init(platformValue: PlatformScanner) {
        self.platformValue = platformValue
    }

    public init(_ string: String) {
        #if !SKIP
        self.platformValue = PlatformScanner(string: string)
        #else
        self.platformValue = PlatformScanner(string)
        #endif
    }

    public var description: String {
        return platformValue.description
    }

    public enum NumberRepresentation: Hashable {
        case decimal
        case hexadecimal
    }


//    open var string: String { get }
//    open var scanLocation: Int
//    open var charactersToBeSkipped: CharacterSet?
//    open var caseSensitive: Bool
//    open var locale: Any?
//    public var currentIndex: String.Index
//    public func scanInt(representation: Scanner.NumberRepresentation = .decimal) -> Int?
//    public func scanInt32(representation: Scanner.NumberRepresentation = .decimal) -> Int32?
//    public func scanInt64(representation: Scanner.NumberRepresentation = .decimal) -> Int64?
//    public func scanUInt64(representation: Scanner.NumberRepresentation = .decimal) -> UInt64?
//    public func scanFloat(representation: Scanner.NumberRepresentation = .decimal) -> Float?
//    public func scanDouble(representation: Scanner.NumberRepresentation = .decimal) -> Double?
//    public func scanDecimal() -> Decimal?
//    public func scanString(_ searchString: String) -> String?
//    public func scanCharacters(from set: CharacterSet) -> String?
//    public func scanUpToString(_ substring: String) -> String?
//    public func scanUpToCharacters(from set: CharacterSet) -> String?
//    public func scanCharacter() -> Character?
//    open func scanInt32(_ result: UnsafeMutablePointer<Int32>?) -> Bool
//    open func scanInt(_ result: UnsafeMutablePointer<Int>?) -> Bool
//    open func scanInt64(_ result: UnsafeMutablePointer<Int64>?) -> Bool
//    open func scanUnsignedLongLong(_ result: UnsafeMutablePointer<UInt64>?) -> Bool
//    open func scanFloat(_ result: UnsafeMutablePointer<Float>?) -> Bool
//    open func scanDouble(_ result: UnsafeMutablePointer<Double>?) -> Bool
//    open func scanHexInt32(_ result: UnsafeMutablePointer<UInt32>?) -> Bool // Optionally prefixed with "0x" or "0X"
//    open func scanHexInt64(_ result: UnsafeMutablePointer<UInt64>?) -> Bool // Optionally prefixed with "0x" or "0X"
//    open func scanHexFloat(_ result: UnsafeMutablePointer<Float>?) -> Bool // Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix.
//    open func scanHexDouble(_ result: UnsafeMutablePointer<Double>?) -> Bool // Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix.
//    open func scanString(_ string: String, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
//    open func scanCharacters(from set: CharacterSet, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
//    open func scanUpTo(_ string: String, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
//    open func scanUpToCharacters(from set: CharacterSet, into result: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool
//    open var isAtEnd: Bool { get }
//    open class func localizedScanner(with string: String) -> Any
}

#if SKIP
extension Scanner {
    public func kotlin(nocopy: Bool = false) -> java.util.Scanner {
        return platformValue
    }
}

extension java.util.Scanner {
    public func swift(nocopy: Bool = false) -> Scanner {
        return Scanner(platformValue: self)
    }
}
#endif
