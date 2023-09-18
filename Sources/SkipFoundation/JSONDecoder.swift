// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import kotlin.reflect.full.__
#endif

/// `JSONDecoder` facilitates the decoding of JSON into semantic `Decodable` types.
open class JSONDecoder {
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
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
        case custom((_ decoder: Decoder) throws -> Date)
    }

    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData

        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64

        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
    }

    /// The strategy to use for non-JSON-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`

        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy {
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
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
    }

    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    fileprivate struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    fileprivate var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        userInfo: userInfo)
    }

    /// Initializes `self` with default strategies.
    public init() {}

    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            var parser = JSONParser(bytes: data.bytes)
            let json = try parser.parse()
            return try JSONDecoderImpl(userInfo: self.userInfo, from: json, codingPath: [], options: self.options).unwrap(as: type)
        } catch let error as JSONError {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
        } catch {
            throw error
        }
    }
}

// MARK: - _JSONDecoder

fileprivate struct JSONDecoderImpl {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    let json: JSONValue
    let options: JSONDecoder._Options

    init(userInfo: [CodingUserInfoKey: Any], from json: JSONValue, codingPath: [CodingKey], options: JSONDecoder._Options) {
        self.userInfo = userInfo
        self.codingPath = codingPath
        self.json = json
        self.options = options
    }
}

extension JSONDecoderImpl: Decoder {
    func container<Key>(keyedBy _keyType: Key.Type) throws ->
        KeyedDecodingContainer<Key> where Key: CodingKey
    {
        switch self.json {
        case .object(let dictionary):
            let container = JSONKeyedDecodingContainer<Key>(
                impl: self,
                codingPath: codingPath,
                dictionary: dictionary
            )
            return KeyedDecodingContainer(container)
        case .null:
            #if SKIP
            fatalError("SKIP TODO: Error handling")
            #else
            throw DecodingError.valueNotFound(Dictionary<String, JSONValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead"
            ))
            #endif
        default:
            #if SKIP
            fatalError("SKIP TODO: Error handling")
            #else
            throw DecodingError.typeMismatch(Dictionary<String, JSONValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode Dictionary<String, JSONValue> but found \(self.json.debugDataTypeDescription) instead."
            ))
            #endif
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch self.json {
        case .array(let array):
            return JSONUnkeyedDecodingContainer(
                impl: self,
                codingPath: self.codingPath,
                array: array
            )
        case .null:
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            throw DecodingError.valueNotFound(Dictionary<String, JSONValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get unkeyed decoding container -- found null value instead"
            ))
            #endif
        default:
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            throw DecodingError.typeMismatch([JSONValue].self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode \([JSONValue].self) but found \(self.json.debugDataTypeDescription) instead."
            ))
            #endif
        }
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        JSONSingleValueDecodingContainer(
            impl: self,
            codingPath: self.codingPath,
            json: self.json
        )
    }

    // MARK: Special case handling

    func unwrap<T: Decodable>(as type: T.Type) throws -> T {
        if type == Date.self {
            return try self.unwrapDate() as! T
        }
        if type == Data.self {
            return try self.unwrapData() as! T
        }
        if type == URL.self {
            return try self.unwrapURL() as! T
        }
        if type == Decimal.self {
            return try self.unwrapDecimal() as! T
        }
        //if T.self is _JSONStringDictionaryDecodableMarker.Type {
        //    return try self.unwrapDictionary(as: T.self)
        //}

        #if !SKIP
        return try T.init(from: self)
        #else
        // SKIP NOWARN
        let co = (type as KClass).companionObjectInstance as DecodableCompanion<T>
        // TODO: Skip removed explicit `.init` call and turns it into a constructor, but we actually want "init" here since it is in the protocol
        // SKIP REPLACE: return co.init(from = this)
        return co.init(from: self)
        #endif
    }

    private func unwrapDate() throws -> Date {
        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            return try Date(from: self)

        case .secondsSince1970:
            let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double)

        case .millisecondsSince1970:
            let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
                let string = try container.decode(String.self)
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case .formatted(let formatter):
            let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
            let string = try container.decode(String.self)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            return date

        case .custom(let closure):
            return try closure(self)
        }
    }

    private func unwrapData() throws -> Data {
        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            return try Data(from: self)

        case .base64:
            let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
            let string = try container.decode(String.self)

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

        case .custom(let closure):
            return try closure(self)
        }
    }

    private func unwrapURL() throws -> URL {
        let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
        let string = try container.decode(String.self)

        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Invalid URL string."))
        }
        return url
    }

    private func unwrapDecimal() throws -> Decimal {
        guard case JSONValue.number(let numberString) = self.json else {
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            throw DecodingError.typeMismatch(Decimal.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: ""))
            #endif
        }

        #if SKIP
        fatalError("SKIP TODO: JSONDecoder")
        #else
        guard let decimal = Decimal(string: numberString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(numberString)> does not fit in \(Decimal.self)."))
        }
        return decimal
        #endif
    }

    private func unwrapDictionary<T: Decodable>(as: T.Type) throws -> T {
        //guard let dictType = T.self as? (_JSONStringDictionaryDecodableMarker & Decodable).Type else {
        //    preconditionFailure("Must only be called of T implements _JSONStringDictionaryDecodableMarker")
        //}

        guard case JSONValue.object(let obj) = self.json else {
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            throw DecodingError.typeMismatch(Dictionary<String, JSONValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode Dictionary but found \(self.json.debugDataTypeDescription) instead."
            ))
            #endif
        }

        let result = Dictionary<String, Any>()

        for (key, value) in obj {
            var newPath = self.codingPath
            newPath.append(_JSONKey(stringValue: key)!)
            let newDecoder = JSONDecoderImpl(userInfo: self.userInfo, from: value, codingPath: newPath, options: self.options)
            let _ = newDecoder
            //result[key] = try dictType.elementType.createByDirectlyUnwrapping(from: newDecoder)

//            newDecoder.unwrap(as: URL.self)
//            if Self.self == URL.self
//                || Self.self == Date.self
//                || Self.self == Data.self
//                || Self.self == Decimal.self
//                //|| Self.self is _JSONStringDictionaryDecodableMarker.Type
//            {
//                return try decoder.unwrap(as: Self.self)
//            }
//
//            return try T.init(from: newDecoder)
        }

        return result as! T
    }

    fileprivate func unwrapFloatingPoint<T: LosslessStringConvertible & BinaryFloatingPoint>(
        from value: JSONValue,
        for additionalKey: CodingKey? = nil,
        as type: T.Type) throws -> T
    {
        if case .number(let number) = value {
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            guard let floatingPoint = T(number), floatingPoint.isFinite else {
                var path = self.codingPath
                if let additionalKey = additionalKey {
                    path.append(additionalKey)
                }
                throw DecodingError.dataCorrupted(.init(
                    codingPath: path,
                    debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
            }

            return floatingPoint
            #endif
        }

        if case .string(let string) = value,
           case .convertFromString(let posInfString, let negInfString, let nanString) =
            self.options.nonConformingFloatDecodingStrategy
        {
            #if !SKIP
            if string == posInfString {
                return T.infinity
            } else if string == negInfString {
                return -T.infinity
            } else if string == nanString {
                return T.nan
            }
            #else
            fatalError("SKIP TODO: Float.nan/infinity")
            #endif
        }

        #if SKIP
        fatalError("SKIP TODO: JSONDecoder error")
        #else
        throw self.createTypeMismatchError(type: type, for: additionalKey, value: value)
        #endif
    }

    #if !SKIP
    fileprivate func unwrapFixedWidthInteger<T: FixedWidthInteger>(
        from value: JSONValue,
        for additionalKey: CodingKey? = nil,
        as type: T.Type) throws -> T
    {
        guard case JSONValue.number(let number) = value else {
            throw self.createTypeMismatchError(type: type, for: additionalKey, value: value)
        }

        // this is the fast pass. Number directly convertible to Integer
        if let integer = T(number) {
            return integer
        }

        #if !SKIP
        // this is the really slow path... If the fast path has failed. For example for "34.0" as
        // an integer, we try to go through NSNumber
        if let nsNumber = NSNumber.fromJSONNumber(number) {
            if type == UInt8.self, NSNumber(value: nsNumber.uint8Value) == nsNumber {
                return nsNumber.uint8Value as! T
            }
            if type == Int8.self, NSNumber(value: nsNumber.int8Value) == nsNumber {
                return nsNumber.int8Value as! T
            }
            if type == UInt16.self, NSNumber(value: nsNumber.uint16Value) == nsNumber {
                return nsNumber.uint16Value as! T
            }
            if type == Int16.self, NSNumber(value: nsNumber.int16Value) == nsNumber {
                return nsNumber.int16Value as! T
            }
            if type == UInt32.self, NSNumber(value: nsNumber.uint32Value) == nsNumber {
                return nsNumber.uint32Value as! T
            }
            if type == Int32.self, NSNumber(value: nsNumber.int32Value) == nsNumber {
                return nsNumber.int32Value as! T
            }
            if type == UInt64.self, NSNumber(value: nsNumber.uint64Value) == nsNumber {
                return nsNumber.uint64Value as! T
            }
            if type == Int64.self, NSNumber(value: nsNumber.int64Value) == nsNumber {
                return nsNumber.int64Value as! T
            }
            if type == UInt.self, NSNumber(value: nsNumber.uintValue) == nsNumber {
                return nsNumber.uintValue as! T
            }
            if type == Int.self, NSNumber(value: nsNumber.intValue) == nsNumber {
                return nsNumber.intValue as! T
            }
        }
        #endif

        var path = self.codingPath
        if let additionalKey = additionalKey {
            path.append(additionalKey)
        }
        throw DecodingError.dataCorrupted(.init(
            codingPath: path,
            debugDescription: "Parsed JSON number <\(number)> does not fit in type."))
    }
    #endif

    fileprivate func createTypeMismatchError(type: Any.Type, for additionalKey: CodingKey? = nil, value: JSONValue) -> DecodingError {
        var path = self.codingPath
        if let additionalKey = additionalKey {
            path.append(additionalKey)
        }

        return DecodingError.typeMismatch(type, .init(
            codingPath: path,
            debugDescription: "Expected to decode \(type) but found \(value.debugDataTypeDescription) instead."
        ))
    }
}

#if !SKIP // Kotlin does not support static members in protocols
extension Decodable {
    fileprivate static func createByDirectlyUnwrapping(from decoder: JSONDecoderImpl) throws -> Self {
        if Self.self == URL.self
            || Self.self == Date.self
            || Self.self == Data.self
            || Self.self == Decimal.self
            //|| Self.self is _JSONStringDictionaryDecodableMarker.Type
        {
            return try decoder.unwrap(as: Self.self)
        }

        return try Self.init(from: decoder)
    }
}
#endif

private struct JSONSingleValueDecodingContainer: SingleValueDecodingContainer {
    let impl: JSONDecoderImpl
    let value: JSONValue
    let codingPath: [CodingKey]

    init(impl: JSONDecoderImpl, codingPath: [CodingKey], json: JSONValue) {
        self.impl = impl
        self.codingPath = codingPath
        self.value = json
    }

    func decodeNil() -> Bool {
        self.value == .null
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case JSONValue.bool(let bool) = self.value else {
            #if SKIP
            fatalError("SKIP TODO: JSONDecoder")
            #else
            throw self.impl.createTypeMismatchError(type: Bool.self, value: self.value)
            #endif
        }

        return bool
    }

    func decode(_ type: String.Type) throws -> String {
        guard case JSONValue.string(let string) = self.value else {
            #if SKIP
            fatalError("SKIP TODO: createTypeMismatchError")
            #else
            throw self.impl.createTypeMismatchError(type: String.self, value: self.value)
            #endif
        }

        return string
    }

    func decode(_ type: Double.Type) throws -> Double {
        try checkOptional(Double(numericString()))
    }

    func decode(_ type: Float.Type) throws -> Float {
        try checkOptional(Float(numericString()))
    }

    #if !SKIP // Int == Int32
    func decode(_ type: Int.Type) throws -> Int {
        try checkOptional(Int(numericString()))
    }
    #endif

    func decode(_ type: Int8.Type) throws -> Int8 {
        try checkOptional(Int8(numericString()))
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try checkOptional(Int16(numericString()))
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try checkOptional(Int32(numericString()))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try checkOptional(Int64(numericString()))
    }

    #if !SKIP // Int == Int32
    func decode(_ type: UInt.Type) throws -> UInt {
        try checkOptional(UInt(numericString()))
    }
    #endif

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try checkOptional(UInt8(numericString()))
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try checkOptional(UInt16(numericString()))
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try checkOptional(UInt32(numericString()))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try checkOptional(UInt64(numericString()))
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try self.impl.unwrap(as: type)
    }

    private func numericString() throws -> String {
        guard case JSONValue.number(let numberString) = value else {
            #if SKIP
            fatalError("Type mismatch")
            #else
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath, debugDescription: "Expected to decode number but found \(value) instead."
            ))
            #endif
        }
        return numberString
    }
}

private func checkOptional<T>(_ value: T?) throws -> T {
    guard let value = value else {
        fatalError("SKIP TODO: empty value for optional")
    }
    return value
}


#if SKIP
internal typealias DecoderKey = CodingKey
#endif

fileprivate struct JSONKeyedDecodingContainer<Key : CodingKey>: KeyedDecodingContainerProtocol {
    #if !SKIP
    internal typealias DecoderKey = Key
    #endif
    let impl: JSONDecoderImpl
    let codingPath: [CodingKey]
    let dictionary: Dictionary<String, JSONValue>

    init(impl: JSONDecoderImpl, codingPath: [CodingKey], dictionary: Dictionary<String, JSONValue>) {
        self.impl = impl
        self.codingPath = codingPath

        switch impl.options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.dictionary = dictionary
        case .convertFromSnakeCase:
            // Convert the snake case keys in the container to camel case.
            // If we hit a duplicate key after conversion, then we'll use the first one we saw.
            // Effectively an undefined behavior with JSON dictionaries.
            //var converted = Dictionary<String, JSONValue>()
            //converted.reserveCapacity(dictionary.count)
            //dictionary.forEach { (key, value) in
            //    converted[JSONDecoder.KeyDecodingStrategy._convertFromSnakeCase(key)] = value
            //}
            //self.dictionary = converted
            fatalError("SKIP TODO: JSON snakeCase")
        case .custom(let converter):
            var converted = Dictionary<String, JSONValue>()
            #if !SKIP
            converted.reserveCapacity(dictionary.count)
            #endif
            for (key, value) in dictionary {
                var pathForKey = codingPath
                pathForKey.append(_JSONKey(stringValue: key)!)
                converted[converter(pathForKey).stringValue] = value
            }
            self.dictionary = converted
        }
    }

    var allKeys: [DecoderKey] {
        #if !SKIP
        self.dictionary.keys.compactMap { Key(stringValue: $0) }
        #else
        fatalError("SKIP TODO: allKeys")
        #endif
    }

    func contains(_ key: DecoderKey) -> Bool {
        if let _ = dictionary[key.stringValue] {
            return true
        }
        return false
    }

    func decodeNil(forKey key: DecoderKey) throws -> Bool {
        let value = try getValue(forKey: key)
        return value == .null
    }

    func decode(_ type: Bool.Type, forKey key: DecoderKey) throws -> Bool {
        let value = try getValue(forKey: key)

        guard case JSONValue.bool(let bool) = value else {
            #if SKIP
            fatalError("SKIP TODO: JSON errors")
            #else
            throw createTypeMismatchError(type: Bool.self, forKey: key, value: value)
            #endif
        }

        return bool
    }

    func decode(_ type: String.Type, forKey key: DecoderKey) throws -> String {
        let value = try getValue(forKey: key)

        guard case JSONValue.string(let string) = value else {
            #if SKIP
            fatalError("SKIP TODO: JSON errors")
            #else
            throw createTypeMismatchError(type: String.self, forKey: key, value: value)
            #endif
        }

        return string
    }

    func decode(_ type: Double.Type, forKey key: DecoderKey) throws -> Double {
        try checkOptional(Double(numericString(key: key)))
    }

    func decode(_ type: Float.Type, forKey key: DecoderKey) throws -> Float {
        try checkOptional(Float(numericString(key: key)))
    }

    #if !SKIP // Int == Int32
    func decode(_ type: Int.Type, forKey key: DecoderKey) throws -> Int {
        try checkOptional(Int(numericString(key: key)))
    }
    #endif

    func decode(_ type: Int8.Type, forKey key: DecoderKey) throws -> Int8 {
        try checkOptional(Int8(numericString(key: key)))
    }

    func decode(_ type: Int16.Type, forKey key: DecoderKey) throws -> Int16 {
        try checkOptional(Int16(numericString(key: key)))
    }

    func decode(_ type: Int32.Type, forKey key: DecoderKey) throws -> Int32 {
        try checkOptional(Int32(numericString(key: key)))
    }

    func decode(_ type: Int64.Type, forKey key: DecoderKey) throws -> Int64 {
        try checkOptional(Int64(numericString(key: key)))
    }

    #if !SKIP // Int == Int32
    func decode(_ type: UInt.Type, forKey key: DecoderKey) throws -> UInt {
        try checkOptional(UInt(numericString(key: key)))
    }
    #endif

    func decode(_ type: UInt8.Type, forKey key: DecoderKey) throws -> UInt8 {
        try checkOptional(UInt8(numericString(key: key)))
    }

    func decode(_ type: UInt16.Type, forKey key: DecoderKey) throws -> UInt16 {
        try checkOptional(UInt16(numericString(key: key)))
    }

    func decode(_ type: UInt32.Type, forKey key: DecoderKey) throws -> UInt32 {
        try checkOptional(UInt32(numericString(key: key)))
    }

    func decode(_ type: UInt64.Type, forKey key: DecoderKey) throws -> UInt64 {
        try checkOptional(UInt64(numericString(key: key)))
    }

    func decode<T>(_ type: T.Type, forKey key: DecoderKey) throws -> T where T: Decodable {
        let newDecoder = try decoderForKey(key)
        //return try newDecoder.unwrap(as: T.self)
        return try newDecoder.unwrap(as: type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: DecoderKey) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
        try decoderForKey(key).container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: DecoderKey) throws -> UnkeyedDecodingContainer {
        try decoderForKey(key).unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        return decoderForKeyNoThrow(_JSONKey._super)
    }

    func superDecoder(forKey key: DecoderKey) throws -> Decoder {
        return decoderForKeyNoThrow(key)
    }

    @inline(__always) private func decoderForKey<LocalKey: CodingKey>(_ key: LocalKey) throws -> JSONDecoderImpl {
        let value = try getValue(forKey: key)
        var newPath = self.codingPath
        newPath.append(key)

        return JSONDecoderImpl(
            userInfo: self.impl.userInfo,
            from: value,
            codingPath: newPath,
            options: self.impl.options
        )
    }

    @inline(__always) private func decoderForKeyNoThrow<LocalKey: CodingKey>(_ key: LocalKey) -> JSONDecoderImpl {
        var value: JSONValue
        do {
            value = try getValue(forKey: key)
        } catch {
            // if there no value for this key then return a null value
            value = JSONValue.null
        }
        var newPath = self.codingPath
        newPath.append(key)

        return JSONDecoderImpl(
            userInfo: self.impl.userInfo,
            from: value,
            codingPath: newPath,
            options: self.impl.options
        )
    }

    @inline(__always) private func getValue<LocalKey: CodingKey>(forKey key: LocalKey) throws -> JSONValue {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, .init(
                codingPath: self.codingPath,
                debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
            ))
        }

        return value
    }

    @inline(__always) private func createTypeMismatchError(type: Any.Type, forKey key: CodingKey, value: JSONValue) -> DecodingError {
        let codingPath = self.codingPath + [key]
        return DecodingError.typeMismatch(type, .init(
            codingPath: codingPath, debugDescription: "Expected to decode \(type) but found \(value.debugDataTypeDescription) instead."
        ))
    }

//        @inline(__always) private func decodeFixedWidthInteger<T: FixedWidthInteger>(key: Self.Key) throws -> T {
//            let value = try getValue(forKey: key)
//            return try self.impl.unwrapFixedWidthInteger(from: value, for: key, as: T.self)
//        }

    private func numericString(key: DecoderKey) throws -> String {
        let value = try getValue(forKey: key)
        guard case JSONValue.number(let numberString) = value else {
            #if SKIP
            fatalError("Type mismatch")
            #else
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
                codingPath: codingPath, debugDescription: "Expected to decode number but found \(value) instead."
            ))
            #endif
        }
        return numberString
    }
}

fileprivate struct JSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let impl: JSONDecoderImpl
    let codingPath: [CodingKey]
    let array: [JSONValue]

    var count: Int? { self.array.count }
    var isAtEnd: Bool { self.currentIndex >= (self.count ?? 0) }
    var currentIndex = 0

    init(impl: JSONDecoderImpl, codingPath: [CodingKey], array: [JSONValue]) {
        self.impl = impl
        self.codingPath = codingPath
        self.array = array
    }

    mutating func decodeNil() throws -> Bool {
        #if SKIP
        fatalError("SKIP TODO")
        #else
        if try self.getNextValue(ofType: Never.self) == JSONValue.null {
            self.currentIndex += 1
            return true
        }

        // The protocol states:
        //   If the value is not null, does not increment currentIndex.
        return false
        #endif
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        #if SKIP
        fatalError("SKIP TODO")
        #else
        let value = try self.getNextValue(ofType: Bool.self)
        guard case JSONValue.bool(let bool) = value else {
            throw impl.createTypeMismatchError(type: type, for: _JSONKey(index: currentIndex), value: value)
        }

        self.currentIndex += 1
        return bool
        #endif
    }

    mutating func decode(_ type: String.Type) throws -> String {
        #if SKIP
        fatalError("SKIP TODO: decode")
        #else
        let value = try self.getNextValue(ofType: String.self)
        guard case JSONValue.string(let string) = value else {
            throw impl.createTypeMismatchError(type: type, for: _JSONKey(index: currentIndex), value: value)
        }

        self.currentIndex += 1
        return string
        #endif
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        try decodeFloatingPoint()
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        try decodeFloatingPoint()
    }

    #if !SKIP // Int == Int32
    mutating func decode(_ type: Int.Type) throws -> Int {
        try decodeFixedWidthInteger()
    }
    #endif

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeFixedWidthInteger()
    }

    #if !SKIP // Int == Int32
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try decodeFixedWidthInteger()
    }
    #endif

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeFixedWidthInteger()
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeFixedWidthInteger()
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        #if SKIP
        fatalError("SKIP TODO: decode")
        #else
        let newDecoder = try decoderForNextElement(ofType: type)
        let result = try newDecoder.unwrap(as: type)

        // Because of the requirement that the index not be incremented unless
        // decoding the desired result type succeeds, it can not be a tail call.
        // Hopefully the compiler still optimizes well enough that the result
        // doesn't get copied around.
        self.currentIndex += 1
        return result
        #endif
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
        #if SKIP
        fatalError("SKIP TODO: nestedContainer")
        #else
        let decoder = try decoderForNextElement(ofType: KeyedDecodingContainer<NestedKey>.self)
        let container = try decoder.container(keyedBy: type)

        self.currentIndex += 1
        return container
        #endif
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        #if SKIP
        fatalError("SKIP TODO: nestedUnkeyedContainer")
        #else
        let decoder = try decoderForNextElement(ofType: UnkeyedDecodingContainer.self)
        let container = try decoder.unkeyedContainer()

        self.currentIndex += 1
        return container
        #endif
    }

    mutating func superDecoder() throws -> Decoder {
        #if SKIP
        fatalError("SKIP TODO: superDecoder")
        #else
        let decoder = try decoderForNextElement(ofType: Decoder.self)
        self.currentIndex += 1
        return decoder
        #endif
    }

    #if !SKIP
    private mutating func decoderForNextElement<T>(ofType: T.Type) throws -> JSONDecoderImpl {
        let value = try self.getNextValue(ofType: ofType)
        let newPath = self.codingPath + [_JSONKey(index: self.currentIndex)]

        return JSONDecoderImpl(
            userInfo: self.impl.userInfo,
            from: value,
            codingPath: newPath,
            options: self.impl.options
        )
    }
    #endif

    #if !SKIP
    //@inline(__always)
    private func getNextValue<T>(ofType: T.Type) throws -> JSONValue {
        #if SKIP
        fatalError("SKIP TODO: getNextValue")
        #else
        guard !self.isAtEnd else {
            var message = "Unkeyed container is at end."
            if ofType == JSONUnkeyedDecodingContainer.self {
                message = "Cannot get nested unkeyed container -- unkeyed container is at end."
            }
            if ofType == Decoder.self {
                message = "Cannot get superDecoder() -- unkeyed container is at end."
            }

            var path = self.codingPath
            path.append(_JSONKey(index: self.currentIndex))

            throw DecodingError.valueNotFound(
                ofType,
                DecodingError.Context(codingPath: path,
                      debugDescription: message,
                      underlyingError: nil))
        }
        return self.array[self.currentIndex]
        #endif
    }
    #endif

    #if !SKIP
    @inline(__always) private mutating func decodeFixedWidthInteger<T: FixedWidthInteger>() throws -> T {
        let value = try self.getNextValue(ofType: T.self)
        let key = _JSONKey(index: self.currentIndex)
        let result = try self.impl.unwrapFixedWidthInteger(from: value, for: key, as: T.self)
        self.currentIndex += 1
        return result
    }
    #else
    private mutating func decodeFixedWidthInteger<T>() throws -> T {
        fatalError("SKIP TODO: decodeFixedWidthInteger")
    }
    #endif

    #if !SKIP
    @inline(__always) private mutating func decodeFloatingPoint<T: LosslessStringConvertible & BinaryFloatingPoint>() throws -> T {
        let value = try self.getNextValue(ofType: T.self)
        let key = _JSONKey(index: self.currentIndex)
        let result = try self.impl.unwrapFloatingPoint(from: value, for: key, as: T.self)
        self.currentIndex += 1
        return result
    }
    #else
    private mutating func decodeFloatingPoint<T>() throws -> T {
        fatalError("SKIP TODO: decodeFloatingPoint")
    }
    #endif
}

//fileprivate protocol _JSONStringDictionaryDecodableMarker {
//    static var elementType: Decodable.Type { get }
//}

//extension Dictionary: _JSONStringDictionaryDecodableMarker where Key == String, Value: Decodable {
//    static var elementType: Decodable.Type { return Value.self }
//}
