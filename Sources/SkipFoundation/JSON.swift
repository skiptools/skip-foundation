// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: This is currently disabled in favor of an alternate codable implementation
#if JSON_NOSKIP

/// A unit of JSON.
public enum JSON : Hashable, CustomStringConvertible {
    case null
    case bool(JSONBool)
    case number(JSONNumber)
    case string(JSONString)
    case array(JSONArray)
    case obj(JSONObject)

    public var description: String {
        switch self {
        //case .null: return "JSON.null" // error: “Unresolved reference: NullCase”
        case .bool(let x): return "JSON.bool(\(x))"
        case .number(let x): return "JSON.number(\(x))"
        case .string(let x): return "JSON.string(\"\(x)\")"
        case .array(let x): return "JSON.array(\(x))"
        case .obj(let x): return "JSON.obj(\(x))"
        default: return "JSON.null"
        }
    }
}

public typealias JSONString = String
public typealias JSONNumber = Double
public typealias JSONBool = Bool
public typealias JSONArray = Array<JSON>
public typealias JSONObject = Dictionary<JSONKey, JSON>
public typealias JSONKey = String

struct UnknownDecodingError : Error {
}

struct UnknownEncodingError : Error {
}

extension JSON {
    /// Parses this JSON from a String.
    public static func parse(_ json: String) throws -> JSON {
        try PlatformJSONSerialization.json(from: json)
    }
}

public extension JSON {
    /// Returns the ``Bool`` value of type ``boolean``.
    var boolean: JSONBool? {
        switch self {
        case .bool(let b):
            return b
        default:
            return nil
        }
    }

    /// Returns the ``Double`` value of type ``number``.
    var number: JSONNumber? {
        switch self {
        case .number(let f):
            return f
        default:
            return nil
        }
    }

    /// Returns the ``String`` value of type ``string``.
    var string: String? {
        switch self {
        case .string(let s):
            return s
        default:
            return nil
        }
    }

    /// Returns the ``Array<JSON>`` value of type ``array``.
    var array: JSONArray? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }

    /// Returns the ``dictionary<String, JSON>`` value of type ``obj``.
    var obj: JSONObject? {
        switch self {
        case .obj(let obj):
            return obj
        default:
            return nil
        }
    }

    /// Returns the number of elements for an ``arr`` or key/values for an ``obj``
    var count: Int? {
        switch self {
        case .array(let array):
            return array.count
        case .obj(let obj):
            return obj.count
        default:
            return nil
        }
    }

    /// Get the value of the given key if this is a dictionary
    func get(key: JSONKey) -> JSON? {
        guard case .obj(let obj) = self else { return nil }
        return obj[key]
    }

    /// Get the value of the given key if this is a dictionary
    func get(index: Int) -> JSON? {
        guard case .array(let array) = self else { return nil }
        if index < 0 || index >= array.count { return nil }
        return array[index]
    }
}

/// Needed to prevent conflict with inner type referencing String as a JSON case object
public typealias NativeString = String

public extension Encodable {
    /// Creates an in-memory JSON representation of the instance's encoding.
    ///
    /// - Parameter options: the options for serializing the data
    /// - Returns: A J containing the structure of the encoded instance
    func json(options: SkipJSONEncodingOptions? = nil) throws -> JSON {
        try JSONObjectEncoder(options: options).encode(self)
    }
}

extension JSON {
    public func stringify(pretty: Bool = false) -> NativeString {
        return toJsonString(indent: pretty ? 0 : nil)
    }

    private func toJsonString(indent: Int? = nil) -> NativeString {
        switch self {
        // FIXME: Skip Null case not getting underscore
        //case .null:
        //    return "null"
        case .bool(let b):
            return b ? "true" : "false"
        case .number(let n):
            return n.description
        case .string(let s):
            return escapeString(s)
        case .array(let a):
            return toJsonString(array: a, indent: indent)
        case .obj(let o):
            return toJsonString(dictionary: o, indent: indent)
        default:
            return "null"
        }
    }

    private func toJsonString(dictionary: JSONObject, indent: Int?) -> NativeString {
        let nextIndent = indent == nil ? nil : indent! + 2

        var json = "{"
        if indent != nil { json += "\n" }

        let sortedKeys = dictionary.keys.sorted()
        let keyCount = sortedKeys.count
        for (index, key) in sortedKeys.enumerated() {
            guard let value = dictionary[key] else {
                continue
            }
            json += String(repeating: " ", count: nextIndent ?? 0)
            json += "\""
            json += key
            json += "\""
            if indent != nil { json += " " }
            json += ":"
            if indent != nil { json += " " }
            json += value.toJsonString(indent: nextIndent)
            if index < keyCount - 1 { json += "," }
            if indent != nil { json += "\n" }
        }

        json += String(repeating: " ", count: indent ?? 0)
        json += "}"
        return json
    }

    private func toJsonString(array: JSONArray, indent: Int?) -> NativeString {
        let nextIndent = indent == nil ? nil : indent! + 2
        var json = "["
        if indent != nil { json += "\n" }
        for (index, value) in array.enumerated() {
            json += String(repeating: " ", count: nextIndent ?? 0)
            json += value.toJsonString(indent: nextIndent)
            if index < array.count - 1 { json += "," }
            if indent != nil { json += "\n" }
        }
        json += String(repeating: " ", count: indent ?? 0)
        json += "]"
        return json
    }

    private func escapeString(_ str: NativeString, withoutEscapingSlashes: Bool = false) -> NativeString {
        var json = ""
        json += "\""

        for c in str {
            switch "\(c)" {
            case "\"":
                json += "\\\""
            case "\\":
                json += "\\\\"
            case "/":
                if withoutEscapingSlashes {
                    json += "/"
                } else {
                    json += "\\/"
                }
            //case 0x8:
            //    json += "\\b"
            //case 0xc:
            //    json += "\\f"
            case "\n":
                json += "\\n"
            case "\r":
                json += "\\r"
            case "\t":
                json += "\\t"
            // case 0x0...0xf:
            //     json += "\\u000\(String(cursor.pointee, radix: 16))"
            // case 0x10...0x1f:
            //     json += "\\u00\(String(cursor.pointee, radix: 16))"
            default:
                json += "\(c)"
            }
        }

        json += "\""
        return json
    }
}

public extension JSON {

    /// JSON has a string subscript when it is an object type; setting a value on a non-obj type has no effect
    subscript(key: String) -> JSON? {
        get {
            guard case .obj(let obj) = self else { return .none }
            return obj[key]
        }

//        set {
//            guard case .obj(var obj) = self else { return }
//            obj[key] = newValue
//            self = .obj(obj)
//        }
    }

    /// JSON has a save indexed subscript when it is an array type; setting a value on a non-array type has no effect
    subscript(index: Int) -> JSON? {
        get {
            guard case .array(let array) = self else { return .none }
            if index < 0 || index >= array.count { return .none }
            return array[index]
        }

//        set {
//            guard case .arr(var arr) = self else { return }
//            if index < 0 || index >= arr.count { return }
//            arr[index] = newValue ?? JSON.nul
//            self = .arr(arr)
//        }
    }
}


#if !SKIP // TODO: Encodable support
extension JSON : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let x): try container.encode(x)
        case .number(let x): try container.encode(x)
        case .string(let x): try container.encode(x)
        case .obj(let x): try container.encode(x)
        case .array(let x): try container.encode(x)
        }
    }
}
#endif


#if !SKIP // TODO: Decodable support
extension JSON : Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        func decode<T: Decodable>() throws -> T { try container.decode(T.self) }
        if container.decodeNil() {
            self = .null
        } else {
            do {
                self = try .bool(container.decode(Bool.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .number(container.decode(Double.self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try .string(container.decode(String.self))
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try .array(decode())
                        } catch DecodingError.typeMismatch {
                            do {
                                self = try .obj(decode())
                            } catch DecodingError.typeMismatch {
                                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                                throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                            }
                        }
                    }
                }
            }
        }
    }
}
#endif


#if !SKIP // TODO: ExpressibleByLiteral support

extension JSON : ExpressibleByNilLiteral {
    /// Creates ``null`` JSON
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSON : ExpressibleByBooleanLiteral {
    /// Creates boolean JSON
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSON : ExpressibleByFloatLiteral {
    /// Creates numeric JSON
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSON : ExpressibleByIntegerLiteral {
    /// Creates numeric JSON
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSON : ExpressibleByArrayLiteral {
    /// Creates an array of JSON
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON : ExpressibleByStringLiteral {
    /// Creates String JSON
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON : ExpressibleByDictionaryLiteral {
    /// Creates a dictionary of `String` to `JSON`
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var d: Dictionary<String, JSON> = [:]
        for (k, v) in elements { d[k] = v }
        self = .obj(d)
    }
}

#endif


// MARK: JSONNumber constructors

#if SKIP
func JSONNumber(_ value: Int8) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: Int16) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: Int32) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: Int64) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: UInt8) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: UInt16) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: UInt32) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: UInt64) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: Float) -> JSONNumber { value.toDouble() }
func JSONNumber(_ value: Double) -> JSONNumber { value }
#endif


// MARK: Foundation type imports constructors

#if !SKIP
@_implementationOnly import struct Foundation.Date
@_implementationOnly import struct Foundation.Data
@_implementationOnly import struct Foundation.URL
@_implementationOnly import struct Foundation.Decimal
@_implementationOnly import class Foundation.NSDate
@_implementationOnly import class Foundation.NSData
@_implementationOnly import class Foundation.NSURL
@_implementationOnly import class Foundation.NSDecimalNumber
@_implementationOnly import class Foundation.JSONDecoder
@_implementationOnly import class Foundation.JSONEncoder
@_implementationOnly import class Foundation.ISO8601DateFormatter
#endif


// MARK: JSONDecoder

#if SKIP
public typealias JSONDecoder = SkipJSONDecoder
#endif

open class SkipJSONDecoder {

    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy : Sendable {

        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate

        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970

        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970

        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)

        /// Decode the `Date` as a custom value decoded by the given closure.
        @preconcurrency case custom(@Sendable (_ decoder: Decoder) throws -> Date)
    }

    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy : Sendable {

        /// Defer to `Data` for decoding.
        case deferredToData

        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64

        /// Decode the `Data` as a custom value decoded by the given closure.
        @preconcurrency case custom(@Sendable (_ decoder: Decoder) throws -> Data)
    }

    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy : Sendable {

        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`

        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy : Sendable {

        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
        ///
        /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from snake case to camel case:
        /// 1. Capitalizes the word starting after each `_`
        /// 2. Removes all `_`
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
        case convertFromSnakeCase

        /// Provide a custom conversion from the key in the encoded JSON to the keys specified by the decoded types.
        /// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
        @preconcurrency case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }

    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: SkipJSONDecoder.DateDecodingStrategy = .deferredToDate

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: SkipJSONDecoder.DataDecodingStrategy = .base64

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: SkipJSONDecoder.NonConformingFloatDecodingStrategy = .throw

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: SkipJSONDecoder.KeyDecodingStrategy = .useDefaultKeys

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    /// Set to `true` to allow parsing of JSON5. Defaults to `false`.
    open var allowsJSON5: Bool = false

    /// Set to `true` to assume the data is a top level Dictionary (no surrounding "{ }" required). Defaults to `false`. Compatible with both JSON5 and non-JSON5 mode.
    open var assumesTopLevelDictionary: Bool = false

    /// Initializes `self` with default strategies.
    public init() {
    }

    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        fatalError("TODO: SkipJSONDecoder.decode")
    }
}

//@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//extension SkipJSONDecoder : TopLevelDecoder {
//
//    /// The type this decoder accepts.
//    public typealias Input = Data
//}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension SkipJSONDecoder : @unchecked Sendable {
}


// MARK: JSONEncoder

#if SKIP
public typealias JSONEncoder = SkipJSONEncoder
#endif

open class SkipJSONEncoder {

    /// The formatting of the output JSON data.
    public struct OutputFormatting : OptionSet, Sendable {

        /// The format's default value.
        public let rawValue: UInt

        /// Creates an OutputFormatting value with the given raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Produce human-readable JSON with indented output.
        public static let prettyPrinted: SkipJSONEncoder.OutputFormatting = OutputFormatting(rawValue: UInt(1 << 0))

        /// Produce JSON with dictionary keys sorted in lexicographic order.
        @available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
        public static let sortedKeys: SkipJSONEncoder.OutputFormatting = OutputFormatting(rawValue: UInt(1 << 1))

        /// By default slashes get escaped ("/" → "\/", "http://apple.com/" → "http:\/\/apple.com\/")
        /// for security reasons, allowing outputted JSON to be safely embedded within HTML/XML.
        /// In contexts where this escaping is unnecessary, the JSON is known to not be embedded,
        /// or is intended only for display, this option avoids this escaping.
        @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
        public static let withoutEscapingSlashes: SkipJSONEncoder.OutputFormatting = OutputFormatting(rawValue: UInt(1 << 3))

//        /// The type of the elements of an array literal.
//        public typealias ArrayLiteralElement = SkipJSONEncoder.OutputFormatting
//
//        /// The element type of the option set.
//        ///
//        /// To inherit all the default implementations from the `OptionSet` protocol,
//        /// the `Element` type must be `Self`, the default.
//        public typealias Element = JSONEncoder.OutputFormatting
//
//        /// The raw type that can be used to represent all values of the conforming
//        /// type.
//        ///
//        /// Every distinct value of the conforming type has a corresponding unique
//        /// value of the `RawValue` type, but there may be values of the `RawValue`
//        /// type that don't have a corresponding value of the conforming type.
//        public typealias RawValue = UInt
    }

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy : Sendable {

        /// Defer to `Date` for choosing an encoding. This is the default strategy.
        case deferredToDate

        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970

        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)

        /// Encode the `Date` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        @preconcurrency case custom(@Sendable (Date, Encoder) throws -> Void)
    }

    /// The strategy to use for encoding `Data` values.
    public enum DataEncodingStrategy : Sendable {

        /// Defer to `Data` for choosing an encoding.
        case deferredToData

        /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
        case base64

        /// Encode the `Data` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        @preconcurrency case custom(@Sendable (Data, Encoder) throws -> Void)
    }

    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatEncodingStrategy : Sendable {

        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`

        /// Encode the values using the given representation strings.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    /// The strategy to use for automatically changing the value of keys before encoding.
    public enum KeyEncodingStrategy : Sendable {

        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to JSON payload.
        ///
        /// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
        /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from camel case to snake case:
        /// 1. Splits words at the boundary of lower-case to upper-case
        /// 2. Inserts `_` between words
        /// 3. Lowercases the entire string
        /// 4. Preserves starting and ending `_`.
        ///
        /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
        ///
        /// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
        case convertToSnakeCase

        /// Provide a custom conversion to the key in the encoded JSON from the keys specified by the encoded types.
        /// The full path to the current encoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before encoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the result.
        @preconcurrency case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
    }

    /// The output format to produce. Defaults to `[]`.
    open var outputFormatting: SkipJSONEncoder.OutputFormatting = []

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    open var dateEncodingStrategy: SkipJSONEncoder.DateEncodingStrategy = .deferredToDate

    /// The strategy to use in encoding binary data. Defaults to `.base64`.
    open var dataEncodingStrategy: SkipJSONEncoder.DataEncodingStrategy = .base64

    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatEncodingStrategy: SkipJSONEncoder.NonConformingFloatEncodingStrategy = .throw

    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
    open var keyEncodingStrategy: SkipJSONEncoder.KeyEncodingStrategy = .useDefaultKeys

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    /// Initializes `self` with default strategies.
    public init() {
    }

    /// Encodes the given top-level value and returns its JSON representation.
    ///
    /// - parameter value: The value to encode.
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    open func encode<T>(_ value: T) throws -> Foundation.Data where T : Encodable {
        try value.json().stringify(pretty: outputFormatting.contains([SkipJSONEncoder.OutputFormatting.prettyPrinted])).data(using: String.Encoding.utf8)!
    }
}

//@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//extension SkipJSONEncoder : TopLevelEncoder {
//
//    /// The type this encoder produces.
//    public typealias Output = Data
//}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension SkipJSONEncoder : @unchecked Sendable {
}

#if SKIP
public typealias JSONDecodingOptions = SkipJSONDecodingOptions
#endif

/// A set of options for decoding an entity from a `JSON` instance.
open class SkipJSONDecodingOptions {
    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: SkipJSONDecoder.DateDecodingStrategy

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: SkipJSONDecoder.DataDecodingStrategy

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: SkipJSONDecoder.NonConformingFloatDecodingStrategy

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: SkipJSONDecoder.KeyDecodingStrategy

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any]

    public init(dateDecodingStrategy: SkipJSONDecoder.DateDecodingStrategy = .deferredToDate, dataDecodingStrategy: SkipJSONDecoder.DataDecodingStrategy = .base64, nonConformingFloatDecodingStrategy: SkipJSONDecoder.NonConformingFloatDecodingStrategy = .throw, keyDecodingStrategy: SkipJSONDecoder.KeyDecodingStrategy = .useDefaultKeys, userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.dataDecodingStrategy = dataDecodingStrategy
        self.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
        self.userInfo = userInfo
    }
}

#if SKIP
public typealias JSONEncodingOptions = SkipJSONEncodingOptions
#endif

/// A set of options for encoding an entity from a `JSON` instance.
open class SkipJSONEncodingOptions {
    /// The output format to produce. Defaults to `[]`.
    open var outputFormatting: SkipJSONEncoder.OutputFormatting

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    open var dateEncodingStrategy: SkipJSONEncoder.DateEncodingStrategy

    /// The strategy to use in encoding binary data. Defaults to `.base64`.
    open var dataEncodingStrategy: SkipJSONEncoder.DataEncodingStrategy

    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatEncodingStrategy: SkipJSONEncoder.NonConformingFloatEncodingStrategy

    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
    open var keyEncodingStrategy: SkipJSONEncoder.KeyEncodingStrategy

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey : Any]

    public init(outputFormatting: SkipJSONEncoder.OutputFormatting = .sortedKeys, dateEncodingStrategy: SkipJSONEncoder.DateEncodingStrategy = .deferredToDate, dataEncodingStrategy: SkipJSONEncoder.DataEncodingStrategy = .base64, nonConformingFloatEncodingStrategy: SkipJSONEncoder.NonConformingFloatEncodingStrategy = .throw, keyEncodingStrategy: SkipJSONEncoder.KeyEncodingStrategy = .useDefaultKeys, userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.outputFormatting = outputFormatting
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.userInfo = userInfo
    }
}


#if !SKIP // TODO: JSONDecoder support

extension Decodable {
    /// Initialized this instance from a JSON string
    public static func decode<T: Decodable, S: Sequence>(fromJSON json: S, decoder: @autoclosure () -> JSONDecoder = JSONDecoder(), allowsJSON5: Bool = true, dataDecodingStrategy: JSONDecoder.DataDecodingStrategy? = nil, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil, nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy? = nil, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> T where S.Element == UInt8 {
        let decoder = decoder()
        #if !os(Linux) && !os(Android) && !os(Windows)
        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            //decoder.allowsJSON5 = allowsJSON5
        }
        #endif

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }

        if let dataDecodingStrategy = dataDecodingStrategy {
            decoder.dataDecodingStrategy = dataDecodingStrategy
        }

        if let nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy {
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
        }

        if let keyDecodingStrategy = keyDecodingStrategy {
            decoder.keyDecodingStrategy = keyDecodingStrategy
        }

        if let userInfo = userInfo {
            decoder.userInfo = userInfo
        }

        return try decoder.decode(T.self, from: Foundation.Data(json))
    }
}
#endif


// MARK: Internal JSON Encoding / Decoding


extension _JSONContainer {
    func addElement(_ element: _JSONContainer) throws {
        guard let arr = self.json.array else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an array"))
        }
        #if SKIP // “inferred type is List<JSON> but JSONArray /* = Array<JSON> */ was expected”
        var newArray = arr
        newArray.append(element.json)
        self.json = JSON.array(newArray)
        #else
        self.json = JSON.array(arr + [element.json])
        #endif
    }

    func insertElement(_ element: _JSONContainer, at index: Int) throws {
        guard var arr = self.json.array else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an array"))
        }
        arr.insert(element.json, at: index)
        self.json = JSON.array(arr)
    }

    func setProperty(_ key: String, _ element: _JSONContainer) throws {
        guard var obj = self.json.obj else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Element was not an object"))
        }
        obj[key] = element.json
        self.json = JSON.obj(obj)
    }
}

#if canImport(Combine)
import Combine
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private protocol TopLevelJSONEncoder : TopLevelEncoder {
}
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private protocol TopLevelJSONDecoder : TopLevelDecoder {
}
#else
private protocol TopLevelJSONEncoder {
}
private protocol TopLevelJSONDecoder {
}
#endif

//extension Decodable {
//    /// Creates an instance from an encoded intermediate representation.
//    ///
//    /// A `JSON` can be created from JSON, YAML, Plists, or other similar data formats.
//    /// This intermediate representation can then be used to instantiate a compatible `Decodable` instance.
//    ///
//    /// - Parameters:
//    ///   - json: the JSON to load the instance from
//    ///   - options: the options for deserializing the data such as the decoding strategies for dates and data.
//    public init(json: JSON, options: JSONDecodingOptions? = nil) throws {
//        try self = JSONObjectDecoder(options: options).decode(Self.self, from: json)
//    }
//}

internal final class JSONObjectEncoder : TopLevelJSONEncoder {
    let options: SkipJSONEncodingOptions

    /// Initializes `self` with default strategies.
    public init(options: SkipJSONEncodingOptions? = nil) {
        self.options = options ?? SkipJSONEncodingOptions()
    }

    /// Encodes the given top-level value and returns its script object representation.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: A new `Data` value containing the encoded script object data.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    public func encode<Value: Encodable>(_ value: Value) throws -> JSON {
        try encodeToTopLevelContainer(value)
    }

    /// Encodes the given top-level value and returns its script-type representation.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    /// - Returns: A new top-level array or dictionary representing the value.
    /// - Throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - Throws: An error if any value throws an error during encoding.
    internal func encodeToTopLevelContainer<Value: Encodable>(_ value: Value) throws -> JSON {
        let encoder = JSONElementEncoder(options: options)
        guard let topLevel = try encoder.box_(value) else {
            #if !SKIP
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level \(Value.self) did not encode any values."))
            #else // no reified parameters
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level value did not encode any values."))
            #endif
        }

        return topLevel.json
    }
}


/// `JSONObjectDecoder` facilitates the decoding of `J` values into `Decodable` types.
internal final class JSONObjectDecoder : TopLevelJSONDecoder {
    let options: SkipJSONDecodingOptions

    /// Initializes `self` with default strategies.
    public init(options: SkipJSONDecodingOptions? = nil) {
        self.options = options ?? SkipJSONDecodingOptions()
    }

    /// Decodes a top-level value of the given type from the given script representation.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    /// - Returns: A value of the requested type.
    /// - Throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not a valid script object.
    /// - Throws: An error if any value throws an error during decoding.
    public func decode<T: Decodable>(_ type: T.Type, from data: JSON) throws -> T {
        try decode(type, fromTopLevel: data)
    }

    /// Decodes a top-level value of the given type from the given script object container (top-level array or dictionary).
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - container: The top-level script container.
    /// - Returns: A value of the requested type.
    /// - Throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not a valid script object.
    /// - Throws: An error if any value throws an error during decoding.
    internal func decode<T: Decodable>(_ type: T.Type, fromTopLevel container: JSON) throws -> T {
        let decoder = _JSONDecoder(options: options, referencing: container)
        guard let value = try decoder.unbox(container, as: type) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }

        return value
    }
}


fileprivate class JSONElementEncoder: Encoder {
    fileprivate let options: SkipJSONEncodingOptions

    /// The encoder's storage.
    fileprivate var storage: _JSONEncodingStorage

    /// The path to the current point in encoding.
    fileprivate(set) public var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    /// Initializes `self` with the given top-level encoder options.
    fileprivate init(options: SkipJSONEncodingOptions, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _JSONEncodingStorage()
        self.codingPath = codingPath
    }

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    fileprivate var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }

    public func container<Key: CodingKey>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: _JSONContainer
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer(options)
        } else {
            guard let container = self.storage.containers.last else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = _JSONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: _JSONContainer
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            do {
                topContainer = try storage.pushUnkeyedContainer(options)
            } catch {
                fatalError("Failed to pushUnkeyedContainer: \(error)")
            }
        } else {
            guard let container = self.storage.containers.last else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        return _JSONUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

fileprivate final class _JSONContainer {
    var json: JSON
    init(json: JSON) {
        self.json = json
    }
}

// MARK: - Encoding Storage and Containers
fileprivate struct _JSONEncodingStorage {
    /// The container stack.
    /// Elements may be any one of the script types
    private(set) fileprivate var containers: [_JSONContainer] = []

    /// Initializes `self` with no containers.
    fileprivate init() {}

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func pushKeyedContainer(_ options: SkipJSONEncodingOptions) -> _JSONContainer {
        let dictionary = _JSONContainer(json: JSON.obj([:]))
        self.containers.append(dictionary)
        return dictionary
    }

    fileprivate mutating func pushUnkeyedContainer(_ options: SkipJSONEncodingOptions) throws -> _JSONContainer {
        let array = _JSONContainer(json: JSON.array([]))
        self.containers.append(array)
        return array
    }

    fileprivate mutating func push(container: __owned _JSONContainer) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> _JSONContainer {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.popLast()!
    }
}

fileprivate struct _JSONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    /// A reference to the encoder we're writing to.
    private let encoder: JSONElementEncoder

    /// A reference to the container we're writing to.
    private var container: _JSONContainer

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    public var count: Int {
        container.json.count ?? 0
    }

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: JSONElementEncoder, codingPath: [CodingKey], wrapping container: _JSONContainer) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    public mutating func encodeNil() throws { try container.addElement(_JSONContainer(json: JSON.null)) }
    public mutating func encode(_ value: Bool) throws { try container.addElement(encoder.box(value)) }
    #if !SKIP // Int and Int32 are the same in Skip
    public mutating func encode(_ value: Int) throws { try container.addElement(encoder.box(value)) }
    #endif
    public mutating func encode(_ value: Int8) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int16) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int32) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Int64) throws { try container.addElement(encoder.box(value)) }
    #if !SKIP // Int and Int32 are the same in Skip
    public mutating func encode(_ value: UInt) throws { try container.addElement(encoder.box(value)) }
    #endif
    public mutating func encode(_ value: UInt8) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Float) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: Double) throws { try container.addElement(encoder.box(value)) }
    public mutating func encode(_ value: String) throws { try container.addElement(encoder.box(value)) }

    public mutating func encode<T: Encodable>(_ value: T) throws {
        self.encoder.codingPath.append(_JSONKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        try self.container.addElement(self.encoder.box(value))
    }

    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(_JSONKey(index: self.count))
        defer { self.codingPath.removeLast() }

        let dictionary = _JSONContainer(json: JSON.obj([:]))
        try? self.container.addElement(dictionary)

        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_JSONKey(index: self.count))
        defer { self.codingPath.removeLast() }

        do {
            let array = _JSONContainer(json: JSON.array([]))
            try self.container.addElement(array)
            return _JSONUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
        } catch {
            fatalError("Failed to pushUnkeyedContainer: \(error)")
        }
    }

    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: self.container.json.count ?? 0, wrapping: self.container)
    }
}

extension JSONElementEncoder: SingleValueEncodingContainer {
    private func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    public func encodeNil() throws {
        assertCanEncodeNewValue()
        self.storage.push(container: _JSONContainer(json: JSON.null))
    }

    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    #if !SKIP // Int and Int32 are the same in Skip
    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    #endif

    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    #if !SKIP // Int and Int32 are the same in Skip
    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }
    #endif

    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        self.storage.push(container: self.box(value))
    }

    public func encode<T: Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try self.storage.push(container: self.box(value))
    }
}

extension JSONElementEncoder {

    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool) -> _JSONContainer {
        _JSONContainer(json: JSON.bool(value))
    }

    #if !SKIP // Int and Int32 are the same in Skip
    fileprivate func box(_ value: Int) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    #endif
    fileprivate func box(_ value: Int8) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: Int16) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: Int32) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: Int64) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    #if !SKIP // Int and Int32 are the same in Skip
    fileprivate func box(_ value: UInt) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    #endif
    fileprivate func box(_ value: UInt8) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: UInt16) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: UInt32) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: UInt64) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: Float) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: Double) -> _JSONContainer {
        _JSONContainer(json: JSON.number(JSONNumber(value)))
    }
    fileprivate func box(_ value: String) -> _JSONContainer {
        _JSONContainer(json: JSON.string(value))
    }

    #if !SKIP // TODO: Date
    fileprivate func box(_ date: Date) throws -> _JSONContainer {
        switch self.options.dateEncodingStrategy {
        case SkipJSONEncoder.DateEncodingStrategy.deferredToDate:
            // Must be called with a surrounding with(pushedKey:) call.
            // Dates encode as single-value objects; this can't both throw and push a container, so no need to catch the error.
            try date.platformValue.encode(to: self)
            return _JSONContainer(json: self.storage.popContainer().json)

        case SkipJSONEncoder.DateEncodingStrategy.secondsSince1970:
            return _JSONContainer(json: JSON.number(date.timeIntervalSince1970))

        case SkipJSONEncoder.DateEncodingStrategy.millisecondsSince1970:
            return _JSONContainer(json: JSON.number(1000.0 * date.timeIntervalSince1970))

        case SkipJSONEncoder.DateEncodingStrategy.iso8601:
            #if !SKIP
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return _JSONContainer(json: JSON.string(_iso8601Formatter.string(from: date.platformValue)))
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            #else
            fatalError("ISO8601DateFormatter is unavailable on this platform.")
            #endif

        case SkipJSONEncoder.DateEncodingStrategy.formatted(let formatter):
            return _JSONContainer(json: JSON.string(formatter.string(from: date)))

        case SkipJSONEncoder.DateEncodingStrategy.custom(let closure):
            let depth = self.storage.count
            do {
                try closure(date, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return _JSONContainer(json: JSON.obj([:]))
            }

            // We can pop because the closure encoded something.
            return self.storage.popContainer()

//        @unknown default:
//            return .init(json: JSON.string(_iso8601Formatter.string(from: date)))
        }
    }
    #endif


    #if !SKIP // TODO: Data
    func box(_ data: Data) throws -> _JSONContainer {
        switch self.options.dataEncodingStrategy {
        case SkipJSONEncoder.DataEncodingStrategy.deferredToData:
            // Must be called with a surrounding with(pushedKey:) call.
            let depth = self.storage.count
            do {
                try data.platformValue.encode(to: self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                // This shouldn't be possible for Data (which encodes as an array of bytes), but it can't hurt to catch a failure.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            return self.storage.popContainer()

        case SkipJSONEncoder.DataEncodingStrategy.base64:
            return .init(json: JSON.string(data.base64EncodedString()))

        case SkipJSONEncoder.DataEncodingStrategy.custom(let closure):
            let depth = self.storage.count
            do {
                try closure(data, self)
            } catch {
                // If the value pushed a container before throwing, pop it back off to restore state.
                if self.storage.count > depth {
                    let _ = self.storage.popContainer()
                }

                throw error
            }

            guard self.storage.count > depth else {
                // The closure didn't encode anything. Return the default keyed container.
                return .init(json: JSON.obj([:]))
            }

            // We can pop because the closure encoded something.
            return self.storage.popContainer()
        //@unknown default:
        //    return .init(json: JSON.string(data.base64EncodedString()))
        }
    }
    #endif

    fileprivate func box<T: Encodable>(_ value: T) throws -> _JSONContainer {
        return try self.box_(value) ?? .init(json: JSON.obj([:]))
    }

    fileprivate func box_<T: Encodable>(_ value: T) throws -> _JSONContainer? {
        let type = type(of: value)
        #if !SKIP // TODO: Date support
        if type == Date.self || type == NSDate.self {
            return try self.box((value as! Date))
        }
        #endif

        #if !SKIP // TODO: Data support
        if type == Foundation.Data.self || type == NSData.self {
            return try self.box((value as! Foundation.Data))
        }
        #endif

        #if !SKIP // TODO: URL support
        if type == URL.self || type == NSURL.self {
            return .init(json: JSON.string((value as! URL).absoluteString))
        }
        #endif

        #if !SKIP // TODO: Decimal support?
        if type == Decimal.self || type == NSDecimalNumber.self {
            return .init(json: JSON.number((value as! NSDecimalNumber).doubleValue))
        }
        #endif

        // The value should request a container from the JSONElementEncoder.
        let depth = self.storage.count
        do {
            try value.encode(to: self)
        } catch let error {
            // If the value pushed a container before throwing, pop it back off to restore state.
            if self.storage.count > depth {
                let _ = self.storage.popContainer()
            }

            throw error
        }

        // The top container should be a new container.
        guard self.storage.count > depth else {
            return nil
        }

        return self.storage.popContainer()
    }
}

#if SKIP // typealias gymnastics to work around the lack of reified types
typealias EncodingContainerKey = CodingKey
#endif

fileprivate struct _JSONKeyedEncodingContainer<_EncodingContainerKey: CodingKey>: KeyedEncodingContainerProtocol {
    #if !SKIP
    typealias EncodingContainerKey = _EncodingContainerKey
    #endif

    /// A reference to the encoder we're writing to.
    private let encoder: JSONElementEncoder

    /// A reference to the container we're writing to.
    private var container: _JSONContainer

    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: JSONElementEncoder, codingPath: [CodingKey], wrapping container: _JSONContainer) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    public mutating func encodeNil(forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.null))
    }

    public mutating func encode(_ value: Bool, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.bool(value)))
    }

    #if !SKIP // Int and Int32 are the same in Skip
    public mutating func encode(_ value: Int, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }
    #endif

    public mutating func encode(_ value: Int8, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: Int16, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: Int32, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: Int64, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    #if !SKIP // Int and Int32 are the same in Skip
    public mutating func encode(_ value: UInt, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }
    #endif

    public mutating func encode(_ value: UInt8, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: UInt16, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: UInt32, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: UInt64, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: String, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.string(value)))
    }

    public mutating func encode(_ value: Float, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(JSONNumber(value))))
    }

    public mutating func encode(_ value: Double, forKey key: EncodingContainerKey) throws {
        try container.setProperty(key.stringValue, _JSONContainer(json: JSON.number(value)))
    }

    public mutating func encode<T: Encodable>(_ value: T, forKey key: EncodingContainerKey) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        try container.setProperty(key.stringValue, self.encoder.box(value))
    }

    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: EncodingContainerKey) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = _JSONContainer(json: JSON.obj([:]))
        _ = try? self.container.setProperty(key.stringValue, dictionary)

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = _JSONKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer(forKey key: EncodingContainerKey) -> UnkeyedEncodingContainer {
        do {
            let array = _JSONContainer(json: JSON.array([]))
            try container.setProperty(key.stringValue, array)

            self.codingPath.append(key)
            defer { self.codingPath.removeLast() }
            return _JSONUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
        } catch {
            fatalError("Failed to nestedUnkeyedContainer: \(error)")
        }
    }

    public mutating func superEncoder() -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: _JSONKey.superKey, wrapping: self.container)
    }

    public mutating func superEncoder(forKey key: EncodingContainerKey) -> Encoder {
        return _JSONReferencingEncoder(referencing: self.encoder, at: key, wrapping: self.container)
    }
}


/// `_JSONReferencingEncoder` is a special subclass of JSONElementEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in `superEncoder()`, which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
fileprivate final class _JSONReferencingEncoder: JSONElementEncoder {
    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an array container.
        case array(_JSONContainer, Int)

        /// Referencing a specific key in a dictionary container.
        case dictionary(_JSONContainer, String)
    }

    /// The encoder we're referencing.
    private let encoder: JSONElementEncoder

    /// The container reference itself.
    private let reference: Reference

    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: JSONElementEncoder, at index: Int, wrapping array: _JSONContainer) {
        self.encoder = encoder
        self.reference = .array(array, index)
        #if SKIP // “Cannot access 'encoder' before superclass constructor has been called”
        super.init(options: referencing.options, codingPath: referencing.codingPath)
        #else
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        #endif
        self.codingPath.append(_JSONKey(index: index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: JSONElementEncoder, at key: CodingKey, wrapping dictionary: _JSONContainer) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        #if SKIP // “Cannot access 'encoder' before superclass constructor has been called”
        super.init(options: referencing.options, codingPath: referencing.codingPath)
        #else
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        #endif

        self.codingPath.append(key)
    }

    fileprivate override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }

    #if !SKIP // TODO: deinit? Replace with manual resource management?
    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: _JSONContainer
        switch self.storage.count {
        case 0: value = _JSONContainer(json: JSON.obj([:]))
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case .array(let array, let index):
            try? array.insertElement(value, at: index)

        case .dictionary(let dictionary, let key):
            try? dictionary.setProperty(key, value)
        }
    }
    #endif
}


fileprivate final class _JSONDecoder: Decoder {
    let options: SkipJSONDecodingOptions

    /// The decoder's storage.
    fileprivate var storage: _JSONDecodingStorage

    /// The path to the current point in encoding.
    fileprivate(set) public var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return self.options.userInfo
    }

    /// Initializes `self` with the given top-level container and options.
    fileprivate init(options: SkipJSONDecodingOptions, referencing container: JSON, at codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _JSONDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
    }

    public func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(self.storage.topContainer == .null) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let obj = self.storage.topContainer.obj else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Dictionary<String, Any>.self, reality: self.storage.topContainer)
        }

        let container = _JSONKeyedDecodingContainer<Key>(referencing: self, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(self.storage.topContainer == .null) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        guard let arr = self.storage.topContainer.array else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
        }

        return _JSONUnkeyedDecodingContainer(referencing: self, wrapping: arr)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

fileprivate struct _JSONDecodingStorage {
    /// The container stack.
    /// Elements may be any one of the script types
    private(set) fileprivate var containers: [JSON] = []

    /// Initializes `self` with no containers.
    fileprivate init() {}

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate var topContainer: JSON {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }

    fileprivate mutating func push(container: __owned JSON) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() {
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
}

#if SKIP // typealias gymnastics to work around the lack of reified types and inner typealiases
typealias DecodingContainerKey = CodingKey
#endif

fileprivate struct _JSONKeyedDecodingContainer<_DecodingContainerKey: CodingKey>: KeyedDecodingContainerProtocol {
    #if !SKIP
    typealias DecodingContainerKey = _DecodingContainerKey
    #endif

    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder

    /// A reference to the container we're reading from.
    private let container: [String: JSON]

    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: [String: JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }

    public var allKeys: [DecodingContainerKey] {
        #if SKIP // needs static initializers
        fatalError("TODO: static initializers")
        #else
        return self.container.keys.compactMap { .init(stringValue: $0) }
        #endif
    }

    public func contains(_ key: DecodingContainerKey) -> Bool {
        return self.container[key.stringValue] != nil
    }

    public func decodeNil(forKey key: DecodingContainerKey) throws -> Bool {
        (self.container[key.stringValue] == .null) != false
    }

    public func decode(_ type: Bool.Type, forKey key: DecodingContainerKey) throws -> Bool {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Bool.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    #if !SKIP // Int = Int32 in Kotlin
    public func decode(_ type: Int.Type, forKey key: DecodingContainerKey) throws -> Int {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }
    #endif

    public func decode(_ type: Int8.Type, forKey key: DecodingContainerKey) throws -> Int8 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int8.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int16.Type, forKey key: DecodingContainerKey) throws -> Int16 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int16.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int32.Type, forKey key: DecodingContainerKey) throws -> Int32 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int32.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Int64.Type, forKey key: DecodingContainerKey) throws -> Int64 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Int64.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    #if !SKIP // Int = Int32 in Kotlin
    public func decode(_ type: UInt.Type, forKey key: DecodingContainerKey) throws -> UInt {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }
    #endif

    public func decode(_ type: UInt8.Type, forKey key: DecodingContainerKey) throws -> UInt8 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt8.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt16.Type, forKey key: DecodingContainerKey) throws -> UInt16 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt16.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt32.Type, forKey key: DecodingContainerKey) throws -> UInt32 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt32.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: UInt64.Type, forKey key: DecodingContainerKey) throws -> UInt64 {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: UInt64.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Float.Type, forKey key: DecodingContainerKey) throws -> Float {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        guard let value = try self.decoder.unbox(entry, as: Float.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: Double.Type, forKey key: DecodingContainerKey) throws -> Double {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: Double.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode(_ type: String.Type, forKey key: DecodingContainerKey) throws -> String {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: String.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: DecodingContainerKey) throws -> T {
        guard let entry = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }

        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = try self.decoder.unbox(entry, as: type) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }

        return value
    }

    public func nestedContainer<NestedKey : CodingKey>(keyedBy type: NestedKey.Type, forKey key: DecodingContainerKey) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let obj = value.obj else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Dictionary<String, Any>.self, reality: value)
        }

        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public func nestedUnkeyedContainer(forKey key: DecodingContainerKey) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested unkeyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let array = value.array else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
        }

        return _JSONUnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
    }

    private func _superDecoder(forKey key: __owned CodingKey) throws -> Decoder {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value: JSON = self.container[key.stringValue] ?? .null
        return _JSONDecoder(options: self.decoder.options, referencing: value, at: self.decoder.codingPath)
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _JSONKey.superKey)
    }

    public func superDecoder(forKey key: DecodingContainerKey) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _JSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    /// A reference to the decoder we're reading from.
    private let decoder: _JSONDecoder

    /// A reference to the container we're reading from.
    private let container: [JSON]

    /// The path of coding keys taken to get to this point in decoding.
    private(set) public var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    private(set) public var currentIndex: Int

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _JSONDecoder, wrapping container: [JSON]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }

    public var count: Int? {
        return self.container.count
    }

    public var isAtEnd: Bool {
        return self.currentIndex >= self.count!
    }

    public mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        if self.container[self.currentIndex] == .null {
            self.currentIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    #if !SKIP // Int = Int32 in Kotlin
    public mutating func decode(_ type: Int.Type) throws -> Int {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }
    #endif

    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    #if !SKIP // Int = Int32 in Kotlin
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }
    #endif

    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Float.Type) throws -> Float {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: Double.Type) throws -> Double {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode(_ type: String.Type) throws -> String {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }

        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: type) else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_JSONKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }

        self.currentIndex += 1
        return decoded
    }

    public mutating func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard value != .null else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let obj = value.obj else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Dictionary<String, JSON>.self, reality: value)
        }

        self.currentIndex += 1
        let container = _JSONKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: obj)
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested unkeyed container -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        guard !(value == .null) else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let arr = value.array else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
        }

        self.currentIndex += 1
        return _JSONUnkeyedDecodingContainer(referencing: self.decoder, wrapping: arr)
    }

    public mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(_JSONKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !self.isAtEnd else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(codingPath: self.codingPath,
                                                                                  debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }

        let value = self.container[self.currentIndex]
        self.currentIndex += 1
        return _JSONDecoder(options: self.decoder.options, referencing: value, at: self.decoder.codingPath)
    }
}

extension _JSONDecoder: SingleValueDecodingContainer {
    private func expectNonNull<T: Any>(_ type: T.Type) throws {
        if storage.topContainer == JSON.null {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    public func decodeNil() -> Bool {
        storage.topContainer == JSON.null
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }

    #if !SKIP // Int = Int32 in Kotlin
    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }
    #endif

    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    #if !SKIP // Int = Int32 in Kotlin
    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }
    #endif

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return .init(try self.unboxNumber(self.storage.topContainer))
    }

    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try self.unbox(self.storage.topContainer, as: type)!
    }
}

#if !SKIP
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
internal var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = ISO8601DateFormatter.Options.withInternetDateTime
    return formatter
}()
#endif

extension _JSONDecoder {
    /// Returns the given value unboxed from a container.
    fileprivate func unbox(_ value: JSON, as type: Bool.Type) throws -> Bool? {
        guard let bool = value.boolean else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return bool
    }

    fileprivate func unboxNumber(_ value: JSON) throws -> Double {
        guard let num = value.number else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: Double.self, reality: value)
        }
        return num
    }

    fileprivate func unbox(_ value: JSON, as type: Float.Type) throws -> Float? {
        try Float(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: Double.Type) throws -> Double? {
        try unboxNumber(value)
    }

    fileprivate func unbox(_ value: JSON, as type: Int8.Type) throws -> Int8? {
        try Int8(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: Int16.Type) throws -> Int16? {
        try Int16(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: Int32.Type) throws -> Int32? {
        try Int32(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: Int64.Type) throws -> Int64? {
        try Int64(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: UInt8.Type) throws -> UInt8? {
        try UInt8(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: UInt16.Type) throws -> UInt16? {
        try UInt16(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: UInt32.Type) throws -> UInt32? {
        try UInt32(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: UInt64.Type) throws -> UInt64? {
        try UInt64(unboxNumber(value))
    }

    fileprivate func unbox(_ value: JSON, as type: String.Type) throws -> String? {
        guard let str = value.string else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }

        return str
    }

    #if !SKIP
    fileprivate func unbox(_ value: JSON, as type: Date.Type) throws -> Date? {
        switch options.dateDecodingStrategy {
        case SkipJSONDecoder.DateDecodingStrategy.deferredToDate:
            return try Date(platformValue: PlatformDate(from: self))

        case SkipJSONDecoder.DateDecodingStrategy.secondsSince1970:
            guard let number = value.number else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date secondsSince1970."))
            }

            return Date(timeIntervalSince1970: number)

        case SkipJSONDecoder.DateDecodingStrategy.millisecondsSince1970:
            guard let number = value.number else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date millisecondsSince1970."))
            }

            return Date(timeIntervalSince1970: number / 1000.0)

        case SkipJSONDecoder.DateDecodingStrategy.iso8601:
            #if !SKIP
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                guard let string = value.string,
                      let date = _iso8601Formatter.date(from: string) else {
                    // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return Date(platformValue: date)
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            #else
            fatalError("ISO8601DateFormatter is unavailable on this platform.")
            #endif

        case SkipJSONDecoder.DateDecodingStrategy.formatted(let formatter):
            guard let string = value.string else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
            }
            guard let date = formatter.date(from: string) else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            return date

        case SkipJSONDecoder.DateDecodingStrategy.custom(let closure):
            return try closure(self)

        //@unknown default:
        //    // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
        //    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unhandled date decoding strategy."))
        }
    }
    #endif

    #if !SKIP
    fileprivate func unbox(_ value: JSON, as type: Foundation.Data.Type) throws -> Foundation.Data? {
        switch options.dataDecodingStrategy {
        case SkipJSONDecoder.DataDecodingStrategy.deferredToData:
            return try Foundation.Data(from: self)

        case SkipJSONDecoder.DataDecodingStrategy.base64:
            guard let string = value.string else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected data to be Base64."))
            }

            guard let data = Foundation.Data(base64Encoded: string) else {
                // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

        case SkipJSONDecoder.DataDecodingStrategy.custom(let closure):
            return try closure(self).platformValue

        //@unknown default:
        //    // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
        //    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unhandled data decoding strategy."))
        }
    }
    #endif

    #if !SKIP
    fileprivate func unbox(_ value: JSON, as type: URL.Type) throws -> URL? {
        guard let string = value.string else {
            // SKIP REPLACE: throw UnknownDecodingError() as Throwable // until errors are ported
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected URL string."))
        }

        return URL(string: string)
    }
    #endif

    fileprivate func unbox<T: Decodable>(_ value: JSON, as type: T.Type) throws -> T? {
        #if !SKIP
        if type == Foundation.Date.self || type == NSDate.self {
            return try self.unbox(value, as: Foundation.Date.self) as? T
        }
        #endif

        #if !SKIP
        if type == Foundation.Data.self || type == NSData.self {
            return try self.unbox(value, as: Foundation.Data.self) as? T
        }
        #endif

        #if !SKIP
        if type == Foundation.URL.self || type == NSURL.self {
            return try self.unbox(value, as: Foundation.URL.self) as? T
        }
        #endif

        self.storage.push(container: value)
        defer { self.storage.popContainer() }
        #if SKIP // needs static initializers
        fatalError("TODO: static initializers")
        #else
        return try type.init(from: self)
        #endif
    }
}

#if !SKIP // “Unresolved reference: Context”
extension DecodingError {
    /// Returns a `.typeMismatch` error describing the expected type.
    ///
    /// - Parameters:
    ///   - path: The path of `CodingKey`s taken to decode a value of this type.
    ///   - expectation: The type expected to be encountered.
    ///   - reality: The value that was encountered instead of the expected type.
    /// - Returns: A `DecodingError` with the appropriate path and debug description.
    internal static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
        let description = "Expected to decode \(expectation) but found \(type(of: reality)) instead."
        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
    }
}
#endif

fileprivate struct _JSONKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    fileprivate init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    fileprivate static let superKey = _JSONKey(stringValue: "super")!

    var rawValue: String {
        stringValue
    }
}

private let debugJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    } else {
        encoder.outputFormatting = [.sortedKeys]
    }
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

private let debugJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.dataDecodingStrategy = .base64
    return decoder
}()

private let prettyJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    } else {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

/// An encoder that replicates JSON Canonical form [JSON Canonicalization Scheme (JCS)](https://tools.ietf.org/id/draft-rundgren-json-canonicalization-scheme-05.html)
let canonicalJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys] // must not use .withoutEscapingSlashes
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

#if !SKIP
extension Encodable {
    /// Encode this instance as JSON data.
    /// - Parameters:
    ///   - encoder: the encoder to use, defaulting to a stock `JSONEncoder`
    ///   - outputFormatting: formatting options, defaulting to `.sortedKeys` and `.withoutEscapingSlashes`
    ///   - dateEncodingStrategy: the strategy for decoding `Date` instances
    ///   - dataEncodingStrategy: the strategy for decoding `Data` instances
    ///   - nonConformingFloatEncodingStrategy: the strategy for handling non-conforming floats
    ///   - keyEncodingStrategy: the strategy for encoding keys
    ///   - userInfo: additional user info to pass to the encoder
    /// - Returns: the JSON-encoded `Data`
    internal func toJSONString(encoder: () -> JSONEncoder = { JSONEncoder() }, outputFormatting: JSONEncoder.OutputFormatting? = nil, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil, dataEncodingStrategy: JSONEncoder.DataEncodingStrategy? = nil, nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy? = nil, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy? = nil, userInfo: [CodingUserInfoKey : Any]? = nil) throws -> String {
        let formatting: JSONEncoder.OutputFormatting
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            formatting = outputFormatting ?? [JSONEncoder.OutputFormatting.sortedKeys, JSONEncoder.OutputFormatting.withoutEscapingSlashes]
        } else {
            formatting = outputFormatting ?? [JSONEncoder.OutputFormatting.sortedKeys]
        }

        let encoder = encoder()
        //if let formatting = formatting {
            encoder.outputFormatting = formatting
        //}

        if let dateEncodingStrategy = dateEncodingStrategy {
            encoder.dateEncodingStrategy = dateEncodingStrategy
        }

        if let dataEncodingStrategy = dataEncodingStrategy {
            encoder.dataEncodingStrategy = dataEncodingStrategy
        }

        if let nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy {
            encoder.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        }

        if let keyEncodingStrategy = keyEncodingStrategy {
            encoder.keyEncodingStrategy = keyEncodingStrategy
        }

        if let userInfo = userInfo {
            encoder.userInfo = userInfo
        }

        let data = try encoder.encode(self)
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}
#endif

extension Decodable where Self : Encodable {

    #if !SKIP // “Kotlin does not support static members in protocols”
    /// Parses this codable into the given data structure, along with a raw `JSON`
    /// that will be used to verify that the codable instance contains all the expected properties.
    ///
    /// - Parameters:
    ///   - data: the data to parse by the Codable and the JSON
    ///   - encoder: the custom encoder to use, or `nil` to use the system default
    ///   - decoder: the custom decoder to use, or `nil` to use the system default
    /// - Returns: a tuple with both the parsed codable instance, as well as an optional `difference` JSON that will be nil if the codability was an exact match
    public static func codableComplete(data: Foundation.Data, encoder: JSONEncoder? = nil, decoder: JSONDecoder? = nil) throws -> (instance: Self, difference: JSON?) {
        let item = try (decoder ?? debugJSONDecoder).decode(Self.self, from: data)
        let itemJSON = try item.toJSONString(encoder: { encoder ?? canonicalJSONEncoder })

        // parse into a generic JSON and ensure that both the items are serialized the same
        let raw = try (decoder ?? debugJSONDecoder).decode(JSON.self, from: data)
        let rawJSON = try raw.toJSONString(encoder: { encoder ?? canonicalJSONEncoder })

        return (instance: item, difference: itemJSON == rawJSON ? JSON?.none : raw)
    }
    #endif
}

#endif

