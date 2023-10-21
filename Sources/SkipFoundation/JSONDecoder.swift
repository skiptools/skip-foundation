// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// This code is adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which has the following license:


//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#if SKIP
import kotlin.reflect.full.__

typealias JSONDecoderValue = Any
#else
typealias JSONDecoderValue = JSONValue
#endif

// SKIP DECLARE: open class JSONDecoder: TopLevelDecoder<Data>
open class JSONDecoder {
    public enum DateDecodingStrategy {
        case deferredToDate
        case secondsSince1970
        case millisecondsSince1970
        case iso8601
        case formatted(DateFormatter)
        case custom((_ decoder: Decoder) throws -> Date)
    }

    public enum DataDecodingStrategy {
        case deferredToData
        case base64
        case custom((_ decoder: Decoder) throws -> Data)
    }

    public enum NonConformingFloatDecodingStrategy {
        case `throw`
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    public enum KeyDecodingStrategy {
        case useDefaultKeys
        case convertFromSnakeCase
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        fileprivate static func _convertFromSnakeCase(_ key: String) -> String {
            fatalError("SKIP TODO: JSON snakeCase")
        }
    }

    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    open var dataDecodingStrategy: DataDecodingStrategy = .base64
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    fileprivate struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    fileprivate var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
                        userInfo: userInfo)
    }

    public init() {}

    #if SKIP
    // Our TopLevelDecoder superclass handles the decode calls. We just have to produce the decoder
    public override func decoder(from data: Data) -> Decoder {
        do {
            var parser = JSONParser(bytes: data.bytes)
            let json = try parser.parseSwiftValue()
            return JSONDecoderImpl(userInfo: self.userInfo, from: json, codingPath: [], options: self.options)
        } catch let error as JSONError {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
        } catch {
            throw error
        }
    }
    #else
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
    #endif
}

private struct JSONDecoderImpl: Decoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let json: JSONDecoderValue
    let options: JSONDecoder._Options

    init(userInfo: [CodingUserInfoKey: Any], from json: JSONDecoderValue, codingPath: [CodingKey], options: JSONDecoder._Options) {
        self.userInfo = userInfo
        self.codingPath = codingPath
        self.json = json
        self.options = options
    }

    func container<Key>(keyedBy _keyType: Key.Type) throws ->
        KeyedDecodingContainer<Key> where Key: CodingKey
    {
        let dictionary: Dictionary<String, JSONDecoderValue>?
        let isNull: Bool
        #if SKIP
        // SKIP NOWARN
        dictionary = json as? Dictionary<String, Any>
        isNull = json is NSNull
        #else
        switch self.json {
        case .object(let dict):
            dictionary = dict
            isNull = false
        case .null:
            dictionary = nil
            isNull = true
        default:
            dictionary = nil
            isNull = false
        }
        #endif
        if let dictionary {
            let container = JSONKeyedDecodingContainer<Key>(
                keyedBy: _keyType,
                impl: self,
                codingPath: codingPath,
                dictionary: dictionary
            )
            return KeyedDecodingContainer(container)
        } else if isNull {
            throw DecodingError.valueNotFound(Dictionary<String, JSONDecoderValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead"
            ))
        } else {
            throw DecodingError.typeMismatch(Dictionary<String, JSONDecoderValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode Dictionary<String, Any> but found \(self.json) instead."
            ))
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let array: Array<JSONDecoderValue>?
        let isNull: Bool
        #if SKIP
        array = json as? Array<Any>
        isNull = json is NSNull
        #else
        switch self.json {
        case .array(let arr):
            array = arr
            isNull = false
        case .null:
            array = nil
            isNull = true
        default:
            array = nil
            isNull = false
        }
        #endif
        if let array {
            return JSONUnkeyedDecodingContainer(
                impl: self,
                codingPath: self.codingPath,
                array: array
            )
        } else if isNull {
            throw DecodingError.valueNotFound(Array<JSONDecoderValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Cannot get unkeyed decoding container -- found null value instead"
            ))
        } else {
            throw DecodingError.typeMismatch(Array<JSONDecoderValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode \(Array<Any>.self) but found \(self.json) instead."
            ))
        }
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        JSONSingleValueDecodingContainer(
            impl: self,
            codingPath: self.codingPath,
            json: self.json
        )
    }

    // SKIP DECLARE: internal fun <T> unwrap(as_: KClass<T>): T where T: Any
    func unwrap<T>(as type: T.Type) throws -> T where T: Decodable {
        if type == Date.self {
            return try self.unwrapDate() as! T
        }
        if type == Data.self {
            return try self.unwrapData() as! T
        }
        if type == URL.self {
            return try self.unwrapURL() as! T
        }
        #if !SKIP
        if type == Decimal.self {
            return try self.unwrapDecimal() as! T
        }
        if T.self is _JSONStringDictionaryDecodableMarker.Type {
            return try self.unwrapDictionary(as: T.self)
        }
        #endif

        #if SKIP
        /* SKIP INSERT:
        val decodableCompanion = type.companionObjectInstance as? DecodableCompanion<*>
        if (decodableCompanion != null) {
            return decodableCompanion.init(from = this) as T
        }
        */
        throw createTypeMismatchError(type: Decodable.self, value: self.json)
        #else
        return try T.init(from: self)
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
            let container = JSONSingleValueDecodingContainer(impl: self, codingPath: self.codingPath, json: self.json)
            let string = try container.decode(String.self)
            guard let date = _iso8601Formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
            }
            return date

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
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid URL string."))
        }
        return url
    }

    #if !SKIP
    private func unwrapDecimal() throws -> Decimal {
        guard case JSONValue.number(let numberString) = self.json else {
            throw DecodingError.typeMismatch(Decimal.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: ""))
        }
        guard let decimal = Decimal(string: numberString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: self.codingPath,
                debugDescription: "Parsed JSON number <\(numberString)> does not fit in \(Decimal.self)."))
        }
        return decimal
    }

    private func unwrapDictionary<T: Decodable>(as: T.Type) throws -> T {
        guard let dictType = T.self as? (_JSONStringDictionaryDecodableMarker & Decodable).Type else {
            preconditionFailure("Must only be called of T implements _JSONStringDictionaryDecodableMarker")
        }

        guard case JSONValue.object(let obj) = self.json else {
            throw DecodingError.typeMismatch(Dictionary<String, JSONValue>.self, DecodingError.Context(
                codingPath: self.codingPath,
                debugDescription: "Expected to decode Dictionary but found \(self.json.debugDataTypeDescription) instead."
            ))
        }

        var result = Dictionary<String, Any>()
        for (key, value) in obj {
            var newPath = self.codingPath
            newPath.append(_JSONKey(stringValue: key)!)
            let newDecoder = JSONDecoderImpl(userInfo: self.userInfo, from: value, codingPath: newPath, options: self.options)
            let _ = newDecoder
            result[key] = try dictType.elementType.createByDirectlyUnwrapping(from: newDecoder)
        }

        return result as! T
    }

    fileprivate func unwrapFloatingPoint<T: LosslessStringConvertible & BinaryFloatingPoint>(
        from value: JSONValue,
        for additionalKey: CodingKey? = nil,
        as type: T.Type) throws -> T
    {
        if case .number(let number) = value {
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
        }

        if case .string(let string) = value,
           case .convertFromString(let posInfString, let negInfString, let nanString) =
            self.options.nonConformingFloatDecodingStrategy
        {
            if string == posInfString {
                return T.infinity
            } else if string == negInfString {
                return -T.infinity
            } else if string == nanString {
                return T.nan
            }
        }

        throw self.createTypeMismatchError(type: type, for: additionalKey, value: value)
    }

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

        #if JSON_NOSKIP
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

    fileprivate func codingPath(with additionalKey: CodingKey?) -> [CodingKey] {
        var path = self.codingPath
        if let additionalKey = additionalKey {
            path.append(additionalKey)
        }
        return path
    }

    fileprivate func createTypeMismatchError(type: Any.Type, for additionalKey: CodingKey? = nil, value: Any) -> DecodingError {
        return DecodingError.typeMismatch(type, .init(
            codingPath: self.codingPath(with: additionalKey),
            debugDescription: "Expected to decode \(type) but found \(value) instead."
        ))
    }
}

private struct JSONSingleValueDecodingContainer: SingleValueDecodingContainer {
    let impl: JSONDecoderImpl
    let value: JSONDecoderValue
    let codingPath: [CodingKey]

    init(impl: JSONDecoderImpl, codingPath: [CodingKey], json: JSONDecoderValue) {
        self.impl = impl
        self.codingPath = codingPath
        self.value = json
    }

    func decodeNil() -> Bool {
        return decodeAsNil(value, impl: impl)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try decodeAsBool(value, impl: impl)
    }

    func decode(_ type: String.Type) throws -> String {
        return try decodeAsString(value, impl: impl)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try decodeAsDouble(value, impl: impl)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try decodeAsFloat(value, impl: impl)
    }

    #if !SKIP // Same as Int32
    func decode(_ type: Int.Type) throws -> Int {
        return try decodeAsInt(value, impl: impl)
    }
    #endif

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeAsInt8(value, impl: impl)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeAsInt16(value, impl: impl)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeAsInt32(value, impl: impl)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeAsInt64(value, impl: impl)
    }

    #if !SKIP // Same as UInt32
    func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeAsUInt(value, impl: impl)
    }
    #endif

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeAsUInt8(value, impl: impl)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeAsUInt16(value, impl: impl)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeAsUInt32(value, impl: impl)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeAsUInt64(value, impl: impl)
    }

    // SKIP DECLARE: override fun <T> decode(type: KClass<T>): T where T: Any
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        return try self.impl.unwrap(as: type)
    }
}

#if SKIP
internal typealias JSONDecoderKey = CodingKey
#endif

fileprivate struct JSONKeyedDecodingContainer<Key : CodingKey>: KeyedDecodingContainerProtocol {
    #if !SKIP
    internal typealias JSONDecoderKey = Key
    #endif
    let impl: JSONDecoderImpl
    let codingPath: [CodingKey]
    let dictionary: Dictionary<String, JSONDecoderValue>

    init(keyedBy: Any.Type, impl: JSONDecoderImpl, codingPath: [CodingKey], dictionary: Dictionary<String, JSONDecoderValue>) {
        self.impl = impl
        self.codingPath = codingPath
        #if SKIP
        let decodeKeys = keyedBy == DictionaryCodingKey.self
        #else
        let decodeKeys = keyedBy != Int.self // Always true; used to prevent compiler warning
        #endif
        if decodeKeys {
            switch impl.options.keyDecodingStrategy {
            case .useDefaultKeys:
                self.dictionary = dictionary
            case .convertFromSnakeCase:
                // Convert the snake case keys in the container to camel case.
                // If we hit a duplicate key after conversion, then we'll use the first one we saw.
                // Effectively an undefined behavior with JSON dictionaries.
                var converted = Dictionary<String, JSONDecoderValue>()
                dictionary.forEach { entry in
                    converted[JSONDecoder.KeyDecodingStrategy._convertFromSnakeCase(entry.key)] = entry.value
                }
                self.dictionary = converted
            case .custom(let converter):
                var converted = Dictionary<String, JSONDecoderValue>()
                for (key, value) in dictionary {
                    var pathForKey = codingPath
                    pathForKey.append(_JSONKey(stringValue: key)!)
                    converted[converter(pathForKey).stringValue] = value
                }
                self.dictionary = converted
            }
        } else {
            self.dictionary = dictionary
        }
    }

    var allKeys: [JSONDecoderKey] {
        self.dictionary.keys.compactMap {
            #if SKIP
            _JSONKey(stringValue: $0)
            #else
            JSONDecoderKey(stringValue: $0)
            #endif
        }
    }

    func contains(_ key: JSONDecoderKey) -> Bool {
        if let _ = dictionary[key.stringValue] {
            return true
        }
        return false
    }

    func decodeNil(forKey key: JSONDecoderKey) throws -> Bool {
        let value = try getValue(forKey: key)
        return decodeAsNil(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Bool.Type, forKey key: JSONDecoderKey) throws -> Bool {
        let value = try getValue(forKey: key)
        return try decodeAsBool(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: String.Type, forKey key: JSONDecoderKey) throws -> String {
        let value = try getValue(forKey: key)
        return try decodeAsString(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Double.Type, forKey key: JSONDecoderKey) throws -> Double {
        let value = try getValue(forKey: key)
        return try decodeAsDouble(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Float.Type, forKey key: JSONDecoderKey) throws -> Float {
        let value = try getValue(forKey: key)
        return try decodeAsFloat(value, forKey: key, impl: self.impl)
    }

    #if !SKIP // Same as Int32
    func decode(_ type: Int.Type, forKey key: JSONDecoderKey) throws -> Int {
        let value = try getValue(forKey: key)
        return try decodeAsInt(value, forKey: key, impl: self.impl)
    }
    #endif

    func decode(_ type: Int8.Type, forKey key: JSONDecoderKey) throws -> Int8 {
        let value = try getValue(forKey: key)
        return try decodeAsInt8(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Int16.Type, forKey key: JSONDecoderKey) throws -> Int16 {
        let value = try getValue(forKey: key)
        return try decodeAsInt16(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Int32.Type, forKey key: JSONDecoderKey) throws -> Int32 {
        let value = try getValue(forKey: key)
        return try decodeAsInt32(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: Int64.Type, forKey key: JSONDecoderKey) throws -> Int64 {
        let value = try getValue(forKey: key)
        return try decodeAsInt64(value, forKey: key, impl: self.impl)
    }

    #if !SKIP // Same as UInt32
    func decode(_ type: UInt.Type, forKey key: JSONDecoderKey) throws -> UInt {
        let value = try getValue(forKey: key)
        return try decodeAsUInt(value, forKey: key, impl: self.impl)
    }
    #endif

    func decode(_ type: UInt8.Type, forKey key: JSONDecoderKey) throws -> UInt8 {
        let value = try getValue(forKey: key)
        return try decodeAsUInt8(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: UInt16.Type, forKey key: JSONDecoderKey) throws -> UInt16 {
        let value = try getValue(forKey: key)
        return try decodeAsUInt16(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: UInt32.Type, forKey key: JSONDecoderKey) throws -> UInt32 {
        let value = try getValue(forKey: key)
        return try decodeAsUInt32(value, forKey: key, impl: self.impl)
    }

    func decode(_ type: UInt64.Type, forKey key: JSONDecoderKey) throws -> UInt64 {
        let value = try getValue(forKey: key)
        return try decodeAsUInt64(value, forKey: key, impl: self.impl)
    }

    // SKIP DECLARE: override fun <T> decode(type: KClass<T>, forKey: CodingKey): T where T: Any
    func decode<T>(_ type: T.Type, forKey key: JSONDecoderKey) throws -> T where T: Decodable {
        let newDecoder = try decoderForKey(key)
        return try newDecoder.unwrap(as: type)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: JSONDecoderKey) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try decoderForKey(key).container(keyedBy: type)
    }

    func nestedUnkeyedContainer(forKey key: JSONDecoderKey) throws -> UnkeyedDecodingContainer {
        try decoderForKey(key).unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        return decoderForKeyNoThrow(_JSONKey._super)
    }

    func superDecoder(forKey key: JSONDecoderKey) throws -> Decoder {
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
        var value: JSONDecoderValue
        do {
            value = try getValue(forKey: key)
        } catch {
            // if there no value for this key then return a null value
            #if SKIP
            value = NSNull.null
            #else
            value = JSONValue.null
            #endif
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

    private func getValue(forKey key: any CodingKey) throws -> JSONDecoderValue {
        guard let value = dictionary[key.stringValue] else {
            throw DecodingError.keyNotFound(key, .init(
                codingPath: self.codingPath,
                debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."
            ))
        }
        return value
    }
}

fileprivate struct JSONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    let impl: JSONDecoderImpl
    let codingPath: [CodingKey]
    let array: [JSONDecoderValue]

    var count: Int? { self.array.count }
    var isAtEnd: Bool { self.currentIndex >= (self.count ?? 0) }
    var currentIndex = 0

    init(impl: JSONDecoderImpl, codingPath: [CodingKey], array: [JSONDecoderValue]) {
        self.impl = impl
        self.codingPath = codingPath
        self.array = array
    }

    mutating func decodeNil() throws -> Bool {
        let value = try getNextValue(ofType: Never.self)
        if decodeAsNil(value, impl: self.impl) {
            self.currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let value = try self.getNextValue(ofType: Bool.self)
        let ret = try decodeAsBool(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: String.Type) throws -> String {
        let value = try self.getNextValue(ofType: String.self)
        let ret = try decodeAsString(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        let value = try self.getNextValue(ofType: Double.self)
        let ret = try decodeAsDouble(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        let value = try self.getNextValue(ofType: Float.self)
        let ret = try decodeAsFloat(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    #if !SKIP // Same as Int32
    mutating func decode(_ type: Int.Type) throws -> Int {
        let value = try self.getNextValue(ofType: Int.self)
        let ret = try decodeAsInt(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }
    #endif

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        let value = try self.getNextValue(ofType: Int8.self)
        let ret = try decodeAsInt8(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        let value = try self.getNextValue(ofType: Int16.self)
        let ret = try decodeAsInt16(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        let value = try self.getNextValue(ofType: Int32.self)
        let ret = try decodeAsInt32(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        let value = try self.getNextValue(ofType: Int64.self)
        let ret = try decodeAsInt64(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    #if !SKIP // Same as UInt32
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        let value = try self.getNextValue(ofType: UInt.self)
        let ret = try decodeAsUInt(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }
    #endif

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        let value = try self.getNextValue(ofType: UInt8.self)
        let ret = try decodeAsUInt8(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        let value = try self.getNextValue(ofType: UInt16.self)
        let ret = try decodeAsUInt16(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        let value = try self.getNextValue(ofType: UInt32.self)
        let ret = try decodeAsUInt32(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        let value = try self.getNextValue(ofType: UInt64.self)
        let ret = try decodeAsUInt64(value, forKey: _JSONKey(index: currentIndex), impl: self.impl)
        self.currentIndex += 1
        return ret
    }

    // SKIP DECLARE: override fun <T> decode(type: KClass<T>): T where T: Any
    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let newDecoder = try decoderForNextElement(ofType: type)
        let result = try newDecoder.unwrap(as: type)
        self.currentIndex += 1
        return result
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
        -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
    {
        let decoder = try decoderForNextElement(ofType: KeyedDecodingContainer<NestedKey>.self)
        let container = try decoder.container(keyedBy: type)
        self.currentIndex += 1
        return container
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let decoder = try decoderForNextElement(ofType: UnkeyedDecodingContainer.self)
        let container = try decoder.unkeyedContainer()
        self.currentIndex += 1
        return container
    }

    mutating func superDecoder() throws -> Decoder {
        let decoder = try decoderForNextElement(ofType: Decoder.self)
        self.currentIndex += 1
        return decoder
    }

    private mutating func decoderForNextElement<T>(ofType: T.Type) throws -> JSONDecoderImpl where T: Any {
        let value = try self.getNextValue(ofType: ofType)
        let newPath = self.codingPath + [_JSONKey(index: self.currentIndex)]

        return JSONDecoderImpl(
            userInfo: self.impl.userInfo,
            from: value,
            codingPath: newPath,
            options: self.impl.options
        )
    }

    private func getNextValue<T>(ofType: T.Type) throws -> JSONDecoderValue where T: Any {
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
    }

    #if !SKIP
    @inline(__always) private mutating func decodeFixedWidthInteger<T: FixedWidthInteger>() throws -> T {
        let value = try self.getNextValue(ofType: T.self)
        let key = _JSONKey(index: self.currentIndex)
        let result = try self.impl.unwrapFixedWidthInteger(from: value, for: key, as: T.self)
        self.currentIndex += 1
        return result
    }

    @inline(__always) private mutating func decodeFloatingPoint<T: LosslessStringConvertible & BinaryFloatingPoint>() throws -> T {
        let value = try self.getNextValue(ofType: T.self)
        let key = _JSONKey(index: self.currentIndex)
        let result = try self.impl.unwrapFloatingPoint(from: value, for: key, as: T.self)
        self.currentIndex += 1
        return result
    }
    #endif
}

private func decodeAsNil(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) -> Bool {
    #if SKIP
    return value is NSNull
    #else
    return value == .null
    #endif
}

private func decodeAsBool(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Bool {
    let bool: Bool?
    #if SKIP
    bool = value as? Bool
    #else
    if case JSONValue.bool(let b) = value {
        bool = b
    } else {
        bool = nil
    }
    #endif
    guard let bool else {
        throw impl.createTypeMismatchError(type: Bool.self, for: key, value: value)
    }
    return bool
}

private func decodeAsString(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> String {
    let string: String?
    #if SKIP
    string = value is NSNull ? nil : value.toString()
    #else
    if case JSONValue.string(let s) = value {
        string = s
    } else {
        string = nil
    }
    #endif
    guard let string else {
        throw impl.createTypeMismatchError(type: String.self, value: value)
    }
    return string
}

private func decodeAsDouble(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Double {
    return try checkNumericOptional(Double(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsFloat(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Float {
    return try checkNumericOptional(Float(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsInt(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Int {
    return try checkNumericOptional(Int(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsInt8(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Int8 {
    return try checkNumericOptional(Int8(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsInt16(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Int16 {
    return try checkNumericOptional(Int16(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsInt32(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Int32 {
    return try checkNumericOptional(Int32(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsInt64(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Int64 {
    return try checkNumericOptional(Int64(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsUInt(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> UInt {
    return try checkNumericOptional(UInt(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsUInt8(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> UInt8 {
    return try checkNumericOptional(UInt8(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsUInt16(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> UInt16 {
    return try checkNumericOptional(UInt16(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsUInt32(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> UInt32 {
    return try checkNumericOptional(UInt32(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

private func decodeAsUInt64(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> UInt64 {
    return try checkNumericOptional(UInt64(decodeNumeric(value, forKey: key, impl: impl)), forKey: key, impl: impl)
}

#if SKIP
private func decodeNumeric(value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> Number {
    guard let number = value as? Number else {
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
            codingPath: impl.codingPath(with: key), debugDescription: "Expected to decode number but found \(value) instead."
        ))
    }
    return number
}
#else
private func decodeNumeric(_ value: JSONDecoderValue, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> String {
    guard case JSONValue.number(let numberString) = value else {
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(
            codingPath: impl.codingPath(with: key), debugDescription: "Expected to decode number but found \(value) instead."
        ))
    }
    return numberString
}
#endif

private func checkNumericOptional<T>(_ value: T?, forKey key: CodingKey? = nil, impl: JSONDecoderImpl) throws -> T {
    guard let value else {
        throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: impl.codingPath(with: key), debugDescription: "Unable to parse as expected numeric type"))
    }
    return value
}

#if !SKIP
fileprivate protocol _JSONStringDictionaryDecodableMarker {
    static var elementType: Decodable.Type { get }
}

extension Dictionary: _JSONStringDictionaryDecodableMarker where Key == String, Value: Decodable {
    static var elementType: Decodable.Type { return Value.self }
}

extension Decodable {
    fileprivate static func createByDirectlyUnwrapping(from decoder: JSONDecoderImpl) throws -> Self {
        if Self.self == URL.self
            || Self.self == Date.self
            || Self.self == Data.self
            || Self.self == Decimal.self
            || Self.self is _JSONStringDictionaryDecodableMarker.Type
        {
            return try decoder.unwrap(as: Self.self)
        }

        return try Self.init(from: decoder)
    }
}
#endif
