// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

/// e.g.: `String(localized: "Done", table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil)`
public func String(localized keyAndValue: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale = Locale.current, comment: String? = nil) -> String {
    let key = keyAndValue.patternFormat // interpolated string: "Hello \(name)" keyed as: "Hello %@"
    let locfmt = bundle?.localizedKotlinFormatString(forKey: key, value: nil, table: table) ?? key.kotlinFormatString
    // re-interpret the placeholder strings in the resulting localized string with the string interpolation's values
    let replaced = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
    return replaced
}

public func String(localized key: String, table: String? = nil, bundle: Bundle? = nil, locale: Locale = Locale.current, comment: String? = nil) -> String {
    return bundle?.localizedString(forKey: key, value: nil, table: table) ?? key
}

extension String {
    public typealias LocalizationValue = StringLocalizationValue
}

public struct StringLocalizationValue : ExpressibleByStringInterpolation {
    /// A type that represents a string literal.
    ///
    /// Valid types for `StringLiteralType` are `String` and `StaticString`.
    public typealias StringLiteralType = String

    fileprivate var stringInterpolation: StringLocalizationValue.StringInterpolation

    public init(_ value: String) { 
        var interp = StringLocalizationValue.StringInterpolation(literalCapacity: 0, interpolationCount: 0)
        interp.appendLiteral(value)
        self.stringInterpolation = interp
    }

    public init(stringLiteral value: String) { 
        var interp = StringLocalizationValue.StringInterpolation(literalCapacity: 0, interpolationCount: 0)
        interp.appendLiteral(value)
        self.stringInterpolation = interp
    }

    public init(stringInterpolation: StringLocalizationValue.StringInterpolation) { 
        self.stringInterpolation = stringInterpolation
    }

    /// Returns the pattern string to use for looking up localized values in the `.xcstrings` file
    public var patternFormat: String {
        stringInterpolation.pattern
    }

    public typealias StringInterpolation = ValueStringInterpolation

    public struct ValueStringInterpolation : StringInterpolationProtocol, Equatable {
        /// The type that should be used for literal segments.
        public typealias StringLiteralType = String

        let values: MutableList<Any> = mutableListOf()
        var pattern = ""

        public init(literalCapacity: Int, interpolationCount: Int) {
        }

        public mutating func appendLiteral(_ literal: String) {
            // need to escape out Java-specific format marker
            pattern += literal.replacingOccurrences(of: "%", with: "%%")
        }

        public mutating func appendInterpolation(_ string: String) {
            #if SKIP
            values.add(string)
            #endif
            pattern += "%@"
        }

        public mutating func appendInterpolation(_ int: Int) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%lld"
        }

        public mutating func appendInterpolation(_ int: Int16) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%d"
        }

        public mutating func appendInterpolation(_ int: Int64) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%lld"
        }

        public mutating func appendInterpolation(_ int: UInt) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%llu"
        }

        public mutating func appendInterpolation(_ int: UInt16) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%u"
        }

        public mutating func appendInterpolation(_ int: UInt64) {
            #if SKIP
            values.add(int)
            #endif
            pattern += "%llu"
        }

        public mutating func appendInterpolation(_ double: Double) {
            #if SKIP
            values.add(double)
            #endif
            pattern += "%lf"
        }

        public mutating func appendInterpolation(_ float: Float) {
            #if SKIP
            values.add(float)
            #endif
            pattern += "%f"
        }

        public mutating func appendInterpolation<T>(_ value: T) {
            #if SKIP
            values.add(value as Any)
            #endif
            pattern += "%@"
        }
    }
}

#endif
