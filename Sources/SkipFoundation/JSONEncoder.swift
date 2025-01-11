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

// SKIP DECLARE: open class JSONEncoder: TopLevelEncoder<Data>
open class JSONEncoder {
    public struct OutputFormatting: OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let prettyPrinted = OutputFormatting(rawValue: UInt(1) << 0)
        public static let sortedKeys = OutputFormatting(rawValue: UInt(1) << 1)
        public static let withoutEscapingSlashes = OutputFormatting(rawValue: UInt(1) << 3)
    }

    public enum DateEncodingStrategy {
        case deferredToDate
        case secondsSince1970
        case millisecondsSince1970
        case iso8601
        case formatted(DateFormatter)
        case custom((Date, Encoder) throws -> Void)
    }

    public enum DataEncodingStrategy {
        case deferredToData
        case base64
        case custom((Data, Encoder) throws -> Void)
    }

    public enum NonConformingFloatEncodingStrategy {
        case `throw`
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    public enum KeyEncodingStrategy {
        case useDefaultKeys
        case convertToSnakeCase
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        fileprivate static func _convertToSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }
            var words: [Range<Int>] = []
            // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
            //
            // myProperty -> my_property
            // myURLProperty -> my_url_property
            //
            // We assume, per Swift naming conventions, that the first character of the key is lowercase.
            var wordStart = 0
            var searchStart = 1
            var searchEnd = stringKey.count

            func indexOfCharacterCase(upper: Bool, in string: String, searchStart: Int, searchEnd: Int) -> Int? {
                for i in searchStart..<searchEnd {
                    let c = string[i]
                    if (upper && c.isUppercase) || (!upper && !c.isUppercase) {
                        return i
                    }
                }
                return nil
            }

            // Find next uppercase character
            while let upperCaseIndex = indexOfCharacterCase(upper: true, in: stringKey, searchStart: searchStart, searchEnd: searchEnd) {
                let untilUpperCase = wordStart..<upperCaseIndex
                words.append(untilUpperCase)

                // Find next lowercase character
                searchStart = upperCaseIndex
                guard let lowerCaseIndex = indexOfCharacterCase(upper: false, in: stringKey, searchStart: searchStart, searchEnd: searchEnd) else {
                    // There are no more lower case letters. Just end here.
                    wordStart = searchStart
                    break
                }

                // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
                let nextCharacterAfterCapital = searchStart + 1
                if lowerCaseIndex == nextCharacterAfterCapital {
                    // The next character after capital is a lower case character and therefore not a word boundary.
                    // Continue searching for the next upper case for the boundary.
                    wordStart = upperCaseIndex
                } else {
                    // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                    let beforeLowerIndex = lowerCaseIndex - 1
                    words.append(upperCaseIndex..<beforeLowerIndex)

                    // Next word starts at the capital before the lowercase we just found
                    wordStart = beforeLowerIndex
                }
                searchStart = lowerCaseIndex
            }
            words.append(wordStart..<searchEnd)
            let result = words.map { range in
                return stringKey[range].lowercased()
            }.joined(separator: "_")
            return result
        }
    }

    open var outputFormatting: OutputFormatting = []
    open var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate
    open var dataEncodingStrategy: DataEncodingStrategy = .base64
    open var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw
    open var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    fileprivate struct _Options {
        let dateEncodingStrategy: DateEncodingStrategy
        let dataEncodingStrategy: DataEncodingStrategy
        let nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
        let keyEncodingStrategy: KeyEncodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    fileprivate var options: _Options {
        return _Options(dateEncodingStrategy: dateEncodingStrategy,
                        dataEncodingStrategy: dataEncodingStrategy,
                        nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
                        keyEncodingStrategy: keyEncodingStrategy,
                        userInfo: userInfo)
    }

    public init() {}

    // Our TopLevelEncoder superclass handles the encode calls. We just have to produce the encoder
    override func encoder() -> Encoder {
        return JSONEncoderImpl(options: self.options, codingPath: [])
    }

    override func output(from encoder: Encoder) -> Data {
        guard let value = (encoder as! JSONEncoderImpl).value else {
            throw EncodingError.invalidValue("?", EncodingError.Context(codingPath: [], debugDescription: "Top-level did not encode any values."))
        }
        let writer = JSONValue.Writer(options: self.outputFormatting)
        let bytes = writer.writeValue(value)
        return Data(bytes: bytes)
    }
}

private enum JSONFuture {
    case value(JSONValue)
    case encoder(JSONEncoderImpl)
    case nestedArray(RefArray)
    case nestedObject(RefObject)

    class RefArray {
        private(set) var array: [JSONFuture] = []

        init() {
        }

        func append(_ element: JSONValue) {
            self.array.append(.value(element))
        }

        func append(_ encoder: JSONEncoderImpl) {
            self.array.append(.encoder(encoder))
        }

        func appendArray() -> RefArray {
            let array = RefArray()
            self.array.append(.nestedArray(array))
            return array
        }

        func appendObject() -> RefObject {
            let object = RefObject()
            self.array.append(.nestedObject(object))
            return object
        }

        var values: [JSONValue] {
            self.array.map { future in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return JSONValue.array(array.values)
                case .nestedObject(let obj):
                    return JSONValue.object(obj.values)
                case .encoder(let encoder):
                    return encoder.value ?? .object([:])
                }
            }
        }
    }

    class RefObject {
        private(set) var dict: [String: JSONFuture] = [:]

        init() {
        }

        func set(_ value: JSONValue, for key: String) {
            self.dict[key] = .value(value)
        }

        func setArray(for key: String) -> RefArray {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedArray(let array):
                return array
            default: // .value, nil:
                let array = RefArray()
                dict[key] = .nestedArray(array)
                return array
            }
        }

        func setObject(for key: String) -> RefObject {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject(let obj):
                return obj
            case .nestedArray:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            default: // .value, nil:
                let object = RefObject()
                dict[key] = .nestedObject(object)
                return object
            }
        }

        func set(_ encoder: JSONEncoderImpl, for key: String) {
            switch self.dict[key] {
            case .encoder:
                preconditionFailure("For key \"\(key)\" an encoder has already been created.")
            case .nestedObject:
                preconditionFailure("For key \"\(key)\" a keyed container has already been created.")
            case .nestedArray:
                preconditionFailure("For key \"\(key)\" a unkeyed container has already been created.")
            default: // .value, nil:
                dict[key] = .encoder(encoder)
            }
        }

        var values: [String: JSONValue] {
            self.dict.mapValues { future in
                switch future {
                case .value(let value):
                    return value
                case .nestedArray(let array):
                    return JSONValue.array(array.values)
                case .nestedObject(let obj):
                    return JSONValue.object(obj.values)
                case .encoder(let encoder):
                    return encoder.value ?? JSONValue.object([:])
                }
            }
        }
    }
}

private final class JSONEncoderImpl: Encoder {
    let options: JSONEncoder._Options
    let codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] {
        options.userInfo
    }

    var singleValue: JSONValue?
    var array: JSONFuture.RefArray?
    var object: JSONFuture.RefObject?

    var value: JSONValue? {
        if let obj = self.object {
            return .object(obj.values)
        }
        if let arr = self.array {
            return .array(arr.values)
        }
        return self.singleValue
    }

    init(options: JSONEncoder._Options, codingPath: [CodingKey]) {
        self.options = options
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy keyType: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        if let _ = object {
            let container = JSONKeyedEncodingContainer<Key>(keyedBy: keyType, impl: self, codingPath: codingPath)
            return KeyedEncodingContainer(container)
        }
        guard self.singleValue == nil, self.array == nil else {
            preconditionFailure()
        }
        self.object = JSONFuture.RefObject()
        let container = JSONKeyedEncodingContainer<Key>(keyedBy: keyType, impl: self, codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if let _ = array {
            let container = JSONUnkeyedEncodingContainer(impl: self, codingPath: self.codingPath)
            return UnkeyedEncodingContainer(container)
        }
        guard self.singleValue == nil, self.object == nil else {
            preconditionFailure()
        }
        self.array = JSONFuture.RefArray()
        let container = JSONUnkeyedEncodingContainer(impl: self, codingPath: self.codingPath)
        return UnkeyedEncodingContainer(container)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        guard self.object == nil, self.array == nil else {
            preconditionFailure()
        }
        let container = JSONSingleValueEncodingContainer(impl: self, codingPath: self.codingPath)
        return SingleValueEncodingContainer(container)
    }
}

extension JSONEncoderImpl: _SpecialTreatmentEncoder {
    var impl: JSONEncoderImpl {
        return self
    }

    func wrapUntyped(_ encodable: Encodable) throws -> JSONValue {
        switch encodable {
        case let date as Date:
            return try self.wrapDate(date, for: nil)
        case let data as Data:
            return try self.wrapData(data, for: nil)
        case let url as URL:
            return .string(url.absoluteString)
        case let decimal as Decimal:
            return .number(decimal.toPlainString())
        default:
            try encodable.encode(to: self)
            return self.value ?? .object([:])
        }
    }
}

private protocol _SpecialTreatmentEncoder {
    var codingPath: [CodingKey] { get }
    var options: JSONEncoder._Options { get }
    var impl: JSONEncoderImpl { get }
}

extension _SpecialTreatmentEncoder {
    // SKIP DECLARE: fun wrapFloat(float: Any, for_: CodingKey?): JSONValue
    func wrapFloat<F: FloatingPoint & CustomStringConvertible>(_ float: F, for additionalKey: CodingKey?) throws -> JSONValue {

        var string = float.description
        if string.hasSuffix(".0") {
            string = String(string.dropLast(2))
        }
        return .number(string)
    }

    // SKIP DECLARE: fun <E> wrapEncodable(encodable: E, for_: CodingKey?): JSONValue? where E: Any
    func wrapEncodable<E: Encodable>(_ encodable: E, for additionalKey: CodingKey?) throws -> JSONValue? {
        switch encodable {
        case let date as Date:
            return try self.wrapDate(date, for: additionalKey)
        case let data as Data:
            return try self.wrapData(data, for: additionalKey)
        case let url as URL:
            return .string(url.absoluteString)
        case let decimal as Decimal:
            return .number(decimal.toPlainString())
        default:
            let encoder = self.getEncoder(for: additionalKey)
            // SKIP REPLACE: (encodable as Encodable).encode(encoder)
            try encodable.encode(to: encoder)
            return encoder.value
        }
    }

    func wrapDate(_ date: Date, for additionalKey: CodingKey?) throws -> JSONValue {
        switch self.options.dateEncodingStrategy {
        case JSONEncoder.DateEncodingStrategy.deferredToDate:
            let encoder = self.getEncoder(for: additionalKey)
            try date.encode(to: encoder)
            return encoder.value ?? .null

        case JSONEncoder.DateEncodingStrategy.secondsSince1970:
            return .number(Int64(date.timeIntervalSince1970).description)

        case JSONEncoder.DateEncodingStrategy.millisecondsSince1970:
            return .number((Int64(date.timeIntervalSince1970) * 1000).description)

        case JSONEncoder.DateEncodingStrategy.iso8601:
            return .string(_iso8601Formatter.string(from: date))

        case JSONEncoder.DateEncodingStrategy.formatted(let formatter):
            return .string(formatter.string(from: date))

        case JSONEncoder.DateEncodingStrategy.custom(let closure):
            let encoder = self.getEncoder(for: additionalKey)
            try closure(date, encoder)
            return encoder.value ?? .object([:])
        }
    }

    func wrapData(_ data: Data, for additionalKey: CodingKey?) throws -> JSONValue {
        switch self.options.dataEncodingStrategy {
        case JSONEncoder.DataEncodingStrategy.deferredToData:
            let encoder = self.getEncoder(for: additionalKey)
            try data.encode(to: encoder)
            return encoder.value ?? .null

        case JSONEncoder.DataEncodingStrategy.base64:
            let base64 = data.base64EncodedString()
            return .string(base64)

        case JSONEncoder.DataEncodingStrategy.custom(let closure):
            let encoder = self.getEncoder(for: additionalKey)
            try closure(data, encoder)
            return encoder.value ?? .object([:])
        }
    }

    fileprivate func getEncoder(for additionalKey: CodingKey?) -> JSONEncoderImpl {
        if let additionalKey {
            var newCodingPath = self.codingPath
            newCodingPath.append(additionalKey)
            return JSONEncoderImpl(options: self.options, codingPath: newCodingPath)
        }
        return self.impl
    }
}

typealias JSONEncoderKey = CodingKey

private struct JSONKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, _SpecialTreatmentEncoder {

    let impl: JSONEncoderImpl
    let object: JSONFuture.RefObject
    let codingPath: [CodingKey]
    let encodeKeys: Bool

    private var firstValueWritten: Bool = false
    fileprivate var options: JSONEncoder._Options {
        return self.impl.options
    }

    init(keyedBy: Any.Type, impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.object = impl.object!
        self.codingPath = codingPath
        self.encodeKeys = keyedBy != DictionaryCodingKey.self
    }

    init(keyedBy: Any.Type, impl: JSONEncoderImpl, object: JSONFuture.RefObject, codingPath: [CodingKey]) {
        self.impl = impl
        self.object = object
        self.codingPath = codingPath
        self.encodeKeys = keyedBy != DictionaryCodingKey.self
    }

    private func _converted(_ key: JSONEncoderKey) -> CodingKey {
        guard encodeKeys else {
            return key
        }
        switch self.options.keyEncodingStrategy {
        case .useDefaultKeys:
            return key
        case .convertToSnakeCase:
            let newKeyString = JSONEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
            return _JSONKey(stringValue: newKeyString, intValue: key.intValue)
        case .custom(let converter):
            return converter(codingPath + [key])
        }
    }

    mutating func encodeNil(forKey key: JSONEncoderKey) throws {
        self.object.set(JSONValue.null, for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Bool, forKey key: JSONEncoderKey) throws {
        self.object.set(JSONValue.bool(value), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: String, forKey key: JSONEncoderKey) throws {
        self.object.set(JSONValue.string(value), for: self._converted(key).stringValue)
    }

    mutating func encode(_ value: Double, forKey key: JSONEncoderKey) throws {
        try encodeFloatingPoint(value, key: self._converted(key))
    }

    mutating func encode(_ value: Float, forKey key: JSONEncoderKey) throws {
        try encodeFloatingPoint(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int8, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int16, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int32, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: Int64, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt8, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt16, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt32, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    mutating func encode(_ value: UInt64, forKey key: JSONEncoderKey) throws {
        try encodeFixedWidthInteger(value, key: self._converted(key))
    }

    // SKIP DECLARE: override fun <T> encode(value: T?, forKey: CodingKey) where T: Any
    mutating func encode<T>(_ value: T?, forKey key: JSONEncoderKey) throws where T: Encodable {
        let convertedKey = self._converted(key)
        if value == nil {
            self.object.set(JSONValue.null, for: convertedKey.stringValue)
        } else {
            let encoded = try self.wrapEncodable(value, for: convertedKey)
            // SKIP NOWARN
            self.object.set(encoded ?? .object([:]), for: convertedKey.stringValue)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy nestedKeyType: NestedKey.Type, forKey key: JSONEncoderKey) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let convertedKey = self._converted(key)
        let newPath = self.codingPath + [convertedKey]
        let object = self.object.setObject(for: convertedKey.stringValue)
        let nestedContainer = JSONKeyedEncodingContainer<NestedKey>(keyedBy: nestedKeyType, impl: impl, object: object, codingPath: newPath)
        return KeyedEncodingContainer(nestedContainer)
    }

    mutating func nestedUnkeyedContainer(forKey key: JSONEncoderKey) -> UnkeyedEncodingContainer {
        let convertedKey = self._converted(key)
        let newPath = self.codingPath + [convertedKey]
        let array = self.object.setArray(for: convertedKey.stringValue)
        let nestedContainer = JSONUnkeyedEncodingContainer(impl: impl, array: array, codingPath: newPath)
        return UnkeyedEncodingContainer(nestedContainer)
    }

    mutating func superEncoder() -> Encoder {
        let newEncoder: JSONEncoderImpl = self.getEncoder(for: _JSONKey._super)
        self.object.set(newEncoder, for: _JSONKey._super.stringValue)
        return newEncoder
    }

    mutating func superEncoder(forKey key: JSONEncoderKey) -> Encoder {
        let convertedKey = self._converted(key)
        let newEncoder = self.getEncoder(for: convertedKey)
        self.object.set(newEncoder, for: convertedKey.stringValue)
        return newEncoder
    }

    // SKIP DECLARE: private fun encodeFloatingPoint(float: Any, key: CodingKey)
    private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F, key: CodingKey) throws {
        let value = try self.wrapFloat(float, for: key)
        self.object.set(value, for: key.stringValue)
    }

    // SKIP DECLARE: private fun encodeFixedWidthInteger(value: Any, key: CodingKey)
    private mutating func encodeFixedWidthInteger<N: FixedWidthInteger & CustomStringConvertible>(_ value: N, key: CodingKey) throws {
        self.object.set(JSONValue.number(value.description), for: key.stringValue)
    }
}

private struct JSONUnkeyedEncodingContainer: UnkeyedEncodingContainerProtocol, _SpecialTreatmentEncoder {
    let impl: JSONEncoderImpl
    let array: JSONFuture.RefArray
    let codingPath: [CodingKey]

    var count: Int {
        self.array.array.count
    }
    private var firstValueWritten: Bool = false
    fileprivate var options: JSONEncoder._Options {
        return self.impl.options
    }

    init(impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.array = impl.array!
        self.codingPath = codingPath
    }

    init(impl: JSONEncoderImpl, array: JSONFuture.RefArray, codingPath: [CodingKey]) {
        self.impl = impl
        self.array = array
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        self.array.append(JSONValue.null)
    }

    mutating func encode(_ value: Bool) throws {
        self.array.append(JSONValue.bool(value))
    }

    mutating func encode(_ value: String) throws {
        self.array.append(JSONValue.string(value))
    }

    mutating func encode(_ value: Double) throws {
        try encodeFloatingPoint(value)
    }

    mutating func encode(_ value: Float) throws {
        try encodeFloatingPoint(value)
    }

    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }

    // SKIP DECLARE: override fun <T> encode(value: T) where T: Any
    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let key = _JSONKey(stringValue: "Index \(self.count)", intValue: self.count)
        let encoded = try self.wrapEncodable(value, for: key)
        self.array.append(encoded ?? JSONValue.object([:]))
    }

    mutating func nestedContainer<NestedKey>(keyedBy nestedKeyType: NestedKey.Type) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let newPath = self.codingPath + [_JSONKey(index: self.count)]
        let object = self.array.appendObject()
        let nestedContainer = JSONKeyedEncodingContainer<NestedKey>(keyedBy: nestedKeyType, impl: impl, object: object, codingPath: newPath)
        return KeyedEncodingContainer(nestedContainer)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let newPath = self.codingPath + [_JSONKey(index: self.count)]
        let array = self.array.appendArray()
        let nestedContainer = JSONUnkeyedEncodingContainer(impl: impl, array: array, codingPath: newPath)
        return UnkeyedEncodingContainer(nestedContainer)
    }

    mutating func superEncoder() -> Encoder {
        let encoder: JSONEncoderImpl = self.getEncoder(for: _JSONKey(index: self.count))
        self.array.append(encoder)
        return encoder
    }

    // SKIP DECLARE: private fun encodeFixedWidthInteger(value: Any)
    private mutating func encodeFixedWidthInteger<N: FixedWidthInteger & CustomStringConvertible>(_ value: N) throws {
        self.array.append(JSONValue.number(value.description))
    }

    // SKIP DECLARE: private fun encodeFloatingPoint(float: Any)
    private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
        let value: JSONValue = try self.wrapFloat(float, for: _JSONKey(index: self.count))
        self.array.append(value)
    }
}

private struct JSONSingleValueEncodingContainer: SingleValueEncodingContainerProtocol, _SpecialTreatmentEncoder {
    let impl: JSONEncoderImpl
    let codingPath: [CodingKey]

    private var firstValueWritten: Bool = false
    fileprivate var options: JSONEncoder._Options {
        return self.impl.options
    }

    init(impl: JSONEncoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.codingPath = codingPath
    }

    mutating func encodeNil() throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .null
    }

    mutating func encode(_ value: Bool) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .bool(value)
    }

    mutating func encode(_ value: Int8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Int64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt8) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt16) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt32) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: UInt64) throws {
        try encodeFixedWidthInteger(value)
    }

    mutating func encode(_ value: Float) throws {
        try encodeFloatingPoint(value)
    }

    mutating func encode(_ value: Double) throws {
        try encodeFloatingPoint(value)
    }

    mutating func encode(_ value: String) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = .string(value)
    }

    // SKIP DECLARE: override fun <T> encode(value: T) where T: Any
    mutating func encode<T: Encodable>(_ value: T) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = try self.wrapEncodable(value, for: nil)
    }

    mutating func nestedContainer<NestedKey>(keyedBy nestedKeyType: NestedKey.Type) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        self.preconditionCanEncodeNewValue()
        return impl.container(keyedBy: nestedKeyType)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.preconditionCanEncodeNewValue()
        return impl.unkeyedContainer()
    }

    func preconditionCanEncodeNewValue() {
        precondition(self.impl.singleValue == nil, "Attempt to encode value through single value container when previously value already encoded.")
    }

    // SKIP DECLARE: private fun encodeFixedWidthInteger(value: Any)
    private mutating func encodeFixedWidthInteger<N: FixedWidthInteger & CustomStringConvertible>(_ value: N) throws {
        self.preconditionCanEncodeNewValue()
        self.impl.singleValue = JSONValue.number(value.description)
    }

    // SKIP DECLARE: private fun encodeFloatingPoint(float: Any)
    private mutating func encodeFloatingPoint<F: FloatingPoint & CustomStringConvertible>(_ float: F) throws {
        self.preconditionCanEncodeNewValue()
        let value = try self.wrapFloat(float, for: nil)
        self.impl.singleValue = value
    }
}

// SKIP NOWARN
extension JSONValue {
    fileprivate struct Writer {
        let options: JSONEncoder.OutputFormatting

        init(options: JSONEncoder.OutputFormatting) {
            self.options = options
        }

        func writeValue(_ value: JSONValue) -> [UInt8] {
            var bytes = [UInt8]()
            if self.options.contains(JSONEncoder.OutputFormatting.prettyPrinted) {
                self.writeValuePretty(value, into: &bytes)
            }
            else {
                self.writeValue(value, into: &bytes)
            }
            return bytes
        }

        private func writeValue(_ value: JSONValue, into bytes: inout [UInt8]) {
            switch value {
            case JSONValue.null:
                bytes.append(contentsOf: UInt8Array_null)
            case JSONValue.bool(let b):
                if b {
                    bytes.append(contentsOf: UInt8Array_true)
                } else {
                    bytes.append(contentsOf: UInt8Array_false)
                }
            case JSONValue.string(let string):
                self.encodeString(string, to: &bytes)
            case JSONValue.number(let string):
                bytes.append(contentsOf: string.utf8)
            case JSONValue.array(let array):
                var iterator = array.makeIterator()
                bytes.append(UInt8_openbracket)
                // we don't like branching, this is why we have this extra
                if let first = iterator.next() {
                    self.writeValue(first, into: &bytes)
                }
                while let item = iterator.next() {
                    bytes.append(UInt8_comma)
                    self.writeValue(item, into:&bytes)
                }
                bytes.append(UInt8_closebracket)
            case JSONValue.object(let dict):
                if options.contains(JSONEncoder.OutputFormatting.sortedKeys) {
                    let sorted = Array(dict).sorted { $0.key < $1.key }
                    self.writeObject(sorted, into: &bytes)
                } else {
                    self.writeObject(Array(dict), into: &bytes)
                }
            }
        }

        private func writeObject(_ object: [(key: String, value: JSONValue)], into bytes: inout [UInt8], depth: Int = 0) {
            var iterator = object.makeIterator()
            bytes.append(UInt8_openbrace)
            if let (key, value) = iterator.next() {
                self.encodeString(key, to: &bytes)
                bytes.append(UInt8_colon)
                self.writeValue(value, into: &bytes)
            }
            while true {
                if let (key, value) = iterator.next() {
                    bytes.append(UInt8_comma)
                    // key
                    self.encodeString(key, to: &bytes)
                    bytes.append(UInt8_colon)

                    self.writeValue(value, into: &bytes)
                } else {
                    break
                }
            }
            bytes.append(UInt8_closebrace)
        }

        private func addInset(to bytes: inout [UInt8], depth: Int) {
            for _ in 0..<depth {
                bytes.append(UInt8_space)
                bytes.append(UInt8_space)
            }
        }

        private func writeValuePretty(_ value: JSONValue, into bytes: inout [UInt8], depth: Int = 0) {
            switch value {
            case .null:
                bytes.append(contentsOf: UInt8Array_null)
            case .bool(let b):
                if b == true {
                    bytes.append(contentsOf: UInt8Array_true)
                } else {
                    bytes.append(contentsOf: UInt8Array_false)
                }
            case .string(let string):
                self.encodeString(string, to: &bytes)
            case .number(let string):
                bytes.append(contentsOf: string.utf8)
            case .array(let array):
                var iterator = array.makeIterator()
                bytes.append(contentsOf: [UInt8_openbracket, UInt8_newline])
                if let first = iterator.next() {
                    self.addInset(to: &bytes, depth: depth + 1)
                    self.writeValuePretty(first, into: &bytes, depth: depth + 1)
                }
                while let item = iterator.next() {
                    bytes.append(contentsOf: [UInt8_comma, UInt8_newline])
                    self.addInset(to: &bytes, depth: depth + 1)
                    self.writeValuePretty(item, into: &bytes, depth: depth + 1)
                }
                bytes.append(UInt8_newline)
                self.addInset(to: &bytes, depth: depth)
                bytes.append(UInt8_closebracket)
            case .object(let dict):
                if options.contains(JSONEncoder.OutputFormatting.sortedKeys) {
                    let sorted = Array(dict).sorted { $0.key < $1.key }
                    self.writePrettyObject(sorted, into: &bytes, depth: depth)
                } else {
                    self.writePrettyObject(Array(dict), into: &bytes, depth: depth)
                }
            }
        }

        private func writePrettyObject(_ object: [(key: String, value: JSONValue)], into bytes: inout [UInt8], depth: Int = 0) {
            var iterator = object.makeIterator()
            bytes.append(contentsOf: [UInt8_openbrace, UInt8_newline])
            if let (key, value) = iterator.next() {
                self.addInset(to: &bytes, depth: depth + 1)
                self.encodeString(key, to: &bytes)
                bytes.append(contentsOf: [UInt8_space, UInt8_colon, UInt8_space])
                self.writeValuePretty(value, into: &bytes, depth: depth + 1)
            }
            while true {
                if  let (key, value) = iterator.next() {
                    bytes.append(contentsOf: [UInt8_comma, UInt8_newline])
                    self.addInset(to: &bytes, depth: depth + 1)
                    // key
                    self.encodeString(key, to: &bytes)
                    bytes.append(contentsOf: [UInt8_space, UInt8_colon, UInt8_space])
                    // value
                    self.writeValuePretty(value, into: &bytes, depth: depth + 1)
                } else {
                    break
                }
            }
            bytes.append(UInt8_newline)
            self.addInset(to: &bytes, depth: depth)
            bytes.append(UInt8_closebrace)
        }

        private func encodeString(_ string: String, to bytes: inout [UInt8]) {
            bytes.append(UInt8(ascii: "\""))
            let stringBytes = string.utf8
            var startCopyIndex = stringBytes.startIndex
            var nextIndex = startCopyIndex

            while nextIndex != stringBytes.endIndex {
                switch stringBytes[nextIndex] {
                case UInt8(0) ..< UInt8(32), UInt8(ascii: "\""), UInt8(ascii: "\\"):
                    // All Unicode characters may be placed within the
                    // quotation marks, except for the characters that MUST be escaped:
                    // quotation mark, reverse solidus, and the control characters (U+0000
                    // through U+001F).
                    // https://tools.ietf.org/html/rfc8259#section-7

                    // copy the current range over
                    bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
                    switch stringBytes[nextIndex] {
                    case UInt8(ascii: "\""): // quotation mark
                        bytes.append(contentsOf: [UInt8_backslash, UInt8_quote])
                    case UInt8(ascii: "\\"): // reverse solidus
                        bytes.append(contentsOf: [UInt8_backslash, UInt8_backslash])
                    case UInt8(0x08): // backspace
                        // SKIP NOWARN
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "b")] as [UInt8])
                    case UInt8(0x0C): // form feed
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "f")])
                    case UInt8(0x0A): // line feed
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "n")])
                    case UInt8(0x0D): // carriage return
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "r")])
                    case UInt8(0x09): // tab
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "t")])
                    default:
                        func valueToAscii(_ value: UInt8) -> UInt8 {
                            switch value {
                            case UInt8(0) ... UInt8(9):
                                return UInt8(value + UInt8(ascii: "0"))
                            case UInt8(10) ... UInt8(15):
                                return UInt8(value - UInt8(10) + UInt8(ascii: "a"))
                            default:
                                preconditionFailure()
                            }
                        }
                        bytes.append(UInt8(ascii: "\\"))
                        bytes.append(UInt8(ascii: "u"))
                        bytes.append(UInt8(ascii: "0"))
                        bytes.append(UInt8(ascii: "0"))
                        let first = stringBytes[nextIndex] / UInt8(16)
                        let remaining = stringBytes[nextIndex] % UInt8(16)
                        bytes.append(valueToAscii(UInt8(first)))
                        bytes.append(valueToAscii(UInt8(remaining)))
                    }

                    nextIndex = stringBytes.index(after: nextIndex)
                    startCopyIndex = nextIndex
                case UInt8(ascii: "/"):
                    if options.contains(JSONEncoder.OutputFormatting.withoutEscapingSlashes) == false {
                        bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
                        bytes.append(contentsOf: [UInt8_backslash, UInt8(ascii: "/")])
                        nextIndex = stringBytes.index(after: nextIndex)
                        startCopyIndex = nextIndex
                    } else {
                        nextIndex = stringBytes.index(after: nextIndex)
                    }
                default:
                    nextIndex = stringBytes.index(after: nextIndex)
                }
            }
            bytes.append(contentsOf: stringBytes[startCopyIndex ..< nextIndex])
            bytes.append(UInt8(ascii: "\""))
        }
    }
}


internal struct _JSONKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    internal init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    public var rawValue: String {
        stringValue
    }

    internal static let _super = _JSONKey(stringValue: "super")!
}

internal var _iso8601Formatter: DateFormatter = {
    let formatter = ISO8601DateFormatter()
//    formatter.formatOptions = ISO8601DateFormatter.Options.withInternetDateTime
    return formatter
}()

#endif
