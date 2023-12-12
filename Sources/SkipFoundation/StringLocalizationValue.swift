// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if !SKIP
//public typealias PlatformStringLocalizationValue = String.LocalizationValue
#else
internal typealias PlatformStringLocalizationValue = String.LocalizationValue
#endif

#if SKIP

/// e.g.: `String(localized: "Done", table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil)`
public func String(localized keyAndValue: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale = Locale.current, comment: String? = nil) -> String {
    let key = keyAndValue.patternFormat // interpolated string: "Hello \(name)" keyed as: "Hello %@"
    let localized = bundle?.localizedString(forKey: key, value: nil, table: table) ?? key

    // re-interpret the placeholder strings in the resulting localized string with the string interpolation's values
    let replaced = String(format: localized, keyAndValue.stringInterpolation.values)
    return replaced
}

extension String {
    public typealias LocalizationValue = StringLocalizationValue
}
#endif

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
        stringInterpolation.pattern.joined(separator: "")
    }

    public typealias StringInterpolation = ValueStringInterpolation

    public struct ValueStringInterpolation : StringInterpolationProtocol {
        /// The type that should be used for literal segments.
        public typealias StringLiteralType = String

        var values: [Any] = []
        var pattern: [String] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
        }

        public mutating func appendLiteral(_ literal: String) { 
            pattern.append(literal)
        }

        public mutating func appendInterpolation(_ string: String) { 
            values.append(string)
            pattern.append("%@")
        }

        public mutating func appendInterpolation<T>(_ value: T) {
            values.append(value as Any)
            switch value {
            case _ as Int: pattern.append("%lld")
            case _ as Int16: pattern.append("%d")
            //case _ as Int32: pattern.append("%d") // Int32==Int in Kotlin
            case _ as Int64: pattern.append("%lld")
            case _ as UInt: pattern.append("%llu")
            case _ as UInt16: pattern.append("%u")
            //case _ as UInt32: pattern.append("%u") // UInt32==UInt in Kotlin
            case _ as UInt64: pattern.append("%llu")
            case _ as Double: pattern.append("%lf")
            case _ as Float: pattern.append("%f")
            default: pattern.append("%@")
            }
        }
    }
}
