// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class Scanner: KotlinConverting<java.util.Scanner> {
    let platformValue: java.util.Scanner

    public init(platformValue: java.util.Scanner) {
        self.platformValue = platformValue
    }

    public init(_ string: String) {
        self.platformValue = java.util.Scanner(string)
    }

    public var description: String {
        return platformValue.description
    }

    @available(*, unavailable)
    public var string: String {
        fatalError()
    }

    @available(*, unavailable)
    public var charactersToBeSkipped: CharacterSet? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var caseSensitive: Bool {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var locale: Any? {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public var currentIndex: Int {
        get {
            fatalError()
        }
        set {
        }
    }

    @available(*, unavailable)
    public func scanInt(representation: Scanner.NumberRepresentation = .decimal) -> Int? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanInt32(representation: Scanner.NumberRepresentation = .decimal) -> Int32? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanInt64(representation: Scanner.NumberRepresentation = .decimal) -> Int64? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanUInt64(representation: Scanner.NumberRepresentation = .decimal) -> UInt64? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanFloat(representation: Scanner.NumberRepresentation = .decimal) -> Float? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanDouble(representation: Scanner.NumberRepresentation = .decimal) -> Double? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanDecimal() -> Decimal? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanString(_ searchString: String) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanCharacters(from set: CharacterSet) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanUpToString(_ substring: String) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanUpToCharacters(from set: CharacterSet) -> String? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanCharacter() -> Character? {
        fatalError()
    }

    @available(*, unavailable)
    public func scanInt(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanInt64(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanUnsignedLongLong(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanHexInt64(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanHexFloat(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanHexDouble(_ result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanString(_ string: String, into result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func scanCharacters(from set: CharacterSet, into result: Any?) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public var isAtEnd: Bool {
        fatalError()
    }

    @available(*, unavailable)
    public static func localizedScanner(with string: String) -> Any {
        fatalError()
    }

    public enum NumberRepresentation: Hashable {
        case decimal
        case hexadecimal
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.Scanner {
        return platformValue
    }
}

#endif
