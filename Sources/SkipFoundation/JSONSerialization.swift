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

open class JSONSerialization {
    public struct ReadingOptions : OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let mutableContainers = ReadingOptions(rawValue: UInt(1) << 0)
        public static let mutableLeaves = ReadingOptions(rawValue: UInt(1) << 1)
        public static let fragmentsAllowed = ReadingOptions(rawValue: UInt(1) << 2)
    }

    public struct WritingOptions : OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let prettyPrinted = WritingOptions(rawValue: UInt(1) << 0)
        public static let sortedKeys = WritingOptions(rawValue: UInt(1) << 1)
        public static let fragmentsAllowed = WritingOptions(rawValue: UInt(1) << 2)
        public static let withoutEscapingSlashes = WritingOptions(rawValue: UInt(1) << 3)
    }

    fileprivate static let maximumRecursionDepth = 512

    open class func isValidJSONObject(_ obj: Any) -> Bool {
        var recursionDepth = 0

        func isValidJSONObjectInternal(_ obj: Any?) -> Bool {
            guard recursionDepth < JSONSerialization.maximumRecursionDepth else { return false }
            recursionDepth += 1
            defer { recursionDepth -= 1 }

            // Emulate the SE-0140 behavior bridging behavior for nils
            guard let obj = obj else {
                return true
            }

            #if JSON_NOSKIP
            let isCastingWithoutBridging = (obj is _NSNumberCastingWithoutBridging)
            #else
            let isCastingWithoutBridging = false
            #endif

            if !isCastingWithoutBridging {
              if obj is String || obj is NSNull || obj is Int || obj is Bool || obj is UInt ||
                  obj is Int8 || obj is Int16 || obj is Int32 || obj is Int64 ||
                  obj is UInt8 || obj is UInt16 || obj is UInt32 || obj is UInt64 {
                  return true
              }
            }

            // object is a Double and is not NaN or infinity
            if let number = obj as? Double  {
                return number.isFinite()
            }
            // object is a Float and is not NaN or infinity
            if let number = obj as? Float  {
                return number.isFinite()
            }

            #if JSON_NOSKIP
            if let number = obj as? Decimal {
                return number.isFinite
            }
            #endif

            // object is Swift.Array
            // SKIP NOWARN
            if let array = obj as? [Any?] {
                for element in array {
                    guard isValidJSONObjectInternal(element) else {
                        return false
                    }
                }
                return true
            }

            // object is Swift.Dictionary
            // SKIP NOWARN
            if let dictionary = obj as? [String: Any?] {
                for (_, value) in dictionary {
                    guard isValidJSONObjectInternal(value) else {
                        return false
                    }
                }
                return true
            }

            #if JSON_NOSKIP
            // object is NSNumber and is not NaN or infinity
            // For better performance, this (most expensive) test should be last.
            if let number = __SwiftValue.store(obj) as? NSNumber {
                if CFNumberIsFloatType(number._cfObject) {
                    let dv = number.doubleValue
                    let invalid = dv.isInfinite || dv.isNaN
                    return !invalid
                } else {
                    return true
                }
            }
            #endif

            // invalid object
            return false
        }

        guard obj is [Any?] || obj is [AnyHashable /* String */: Any?] else {
            return false
        }

        return isValidJSONObjectInternal(obj)
    }

    internal class func _data(withJSONObject value: Any, options opt: WritingOptions, stream: Bool) throws -> Data {
        var jsonStr = [UInt8]()

        var writer = JSONWriter(
            options: opt,
            writer: { (str: String?) in
                if let str {
                    jsonStr.append(contentsOf: str.utf8)
                }
            }
        )

        #if JSON_NOSKIP
        if let container = value as? NSArray {
            try writer.serializeJSON(container._bridgeToSwift())
        } else if let container = value as? NSDictionary {
            try writer.serializeJSON(container._bridgeToSwift())
        }
        #endif

        // SKIP NOWARN
        if let container = value as? Array<Any> {
            try writer.serializeJSON(container)
        } else if let container = value as? Dictionary<AnyHashable, Any> {
            try writer.serializeJSON(container)
        } else {
            guard opt.contains(WritingOptions.fragmentsAllowed) else {
                fatalError("Top-level object was not Array or Dictionary")
            }
            try writer.serializeJSON(value)
        }

        let count = jsonStr.count
        let _ = count
        return Data(jsonStr) // Data(bytes: &jsonStr, count: count)
    }

    open class func data(withJSONObject value: Any, options opt: WritingOptions = WritingOptions(rawValue: UInt(0))) throws -> Data {
        return try _data(withJSONObject: value, options: opt, stream: false)
    }

    open class func jsonObject(with data: Data, options opt: ReadingOptions = ReadingOptions(rawValue: UInt(0))) throws -> Any {
        do {
            let bytes = data.bytes
            let (encoding, advanceBy) = JSONSerialization.detectEncoding(bytes)
            var parser: JSONParser
            if encoding == .utf8 {
                if advanceBy == 0 {
                    parser = JSONParser(bytes: bytes)
                } else {
                    parser = JSONParser(bytes: Array(bytes[advanceBy..<bytes.count]))
                }
            } else {
                guard let utf8String = String(bytes: Array(bytes[advanceBy..<bytes.count]), encoding: encoding) else {
                    throw JSONError.cannotConvertInputDataToUTF8
                }
                parser = JSONParser(bytes: Array(utf8String.utf8))
            }

            let value = try parser.parseSwiftValue()
            if !opt.contains(.fragmentsAllowed), !(value is Array<Any> || value is Dictionary<AnyHashable, Any>) {
                throw JSONError.singleFragmentFoundButNotAllowed
            }
            return value
        } catch let error as JSONError {
            switch error {
            case .cannotConvertInputDataToUTF8:
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Cannot convert input string to valid utf8 input."
                ])
            case .unexpectedEndOfFile:
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Unexpected end of file during JSON parse."
                ])
            case .unexpectedCharacter(_, let characterIndex):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Invalid value around character \(characterIndex)."
                ])
            case .expectedLowSurrogateUTF8SequenceAfterHighSurrogate:
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Unexpected end of file during string parse (expected low-surrogate code point but did not find one)."
                ])
            case .couldNotCreateUnicodeScalarFromUInt32:
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Unable to convert hex escape sequence (no high character) to UTF8-encoded character."
                ])
            case .unexpectedEscapedCharacter(_, _, let index):
                // we lower the failure index by one to match the darwin implementations counting
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Invalid escape sequence around character \(index - 1)."
                ])
            case .singleFragmentFoundButNotAllowed:
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "JSON text did not start with array or object and option to allow fragments not set."
                ])
            case .tooManyNestedArraysOrDictionaries(characterIndex: let characterIndex):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : "Too many nested arrays or dictionaries around character \(characterIndex + 1)."
                ])
            case .invalidHexDigitSequence(let string, index: let index):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : #"Invalid hex encoded sequence in "\#(string)" at \#(index)."#
                ])
            // FIXME: Unresolved reference: UnescapedControlCharacterInStringCase
            //case .unescapedControlCharacterInString(ascii: let ascii, in: _, index: let index) where ascii == UInt8(ascii: "\\"): // SKIP TODO: Kotlin does not support where conditions in case and catch matches. Consider using an if statement within the case or catch body
            //    let _ = ascii
            //    throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
            //        NSDebugDescriptionErrorKey : #"Invalid escape sequence around character \#(index)."#
            //    ])
            case .unescapedControlCharacterInString(ascii: _, in: _, index: let index):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : #"Unescaped control character around character \#(index)."#
                ])
            case .numberWithLeadingZero(index: let index):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : #"Number with leading zero around character \#(index)."#
                ])
            case .numberIsNotRepresentableInSwift(parsed: let parsed):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : #"Number \#(parsed) is not representable in Swift."#
                ])
            case .invalidUTF8Sequence(let data, characterIndex: let index):
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
                    NSDebugDescriptionErrorKey : #"Invalid UTF-8 sequence \#(data) starting from character \#(index)."#
                ])
//            default:
//                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
//                    NSDebugDescriptionErrorKey : "."
//                ])
            }
        } catch {
            throw NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [
                NSDebugDescriptionErrorKey : "JSON parse error: \(error)"
            ])
        }
    }

#if JSON_NOSKIP
#if !os(WASI)
    /* Write JSON data into a stream. The stream should be opened and configured. The return value is the number of bytes written to the stream, or 0 on error. All other behavior of this method is the same as the dataWithJSONObject:options:error: method.
     */
    open class func writeJSONObject(_ obj: Any, toStream stream: OutputStream, options opt: WritingOptions) throws -> Int {
        let jsonData = try _data(withJSONObject: obj, options: opt, stream: true)
        return jsonData.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) -> Int in
            let ptr = rawBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let res: Int = stream.write(ptr, maxLength: rawBuffer.count)
            /// TODO: If the result here is negative the error should be obtained from the stream to propagate as a throw
            return res
        }
    }

    /* Create a JSON object from JSON data stream. The stream should be opened and configured. All other behavior of this method is the same as the JSONObjectWithData:options:error: method.
     */
    open class func jsonObject(with stream: InputStream, options opt: ReadingOptions = []) throws -> Any {
        var data = Data()
        guard stream.streamStatus == .open || stream.streamStatus == .reading else {
            fatalError("Stream is not available for reading")
        }
        repeat {
            let buffer = try [UInt8](unsafeUninitializedCapacity: 1024) { buf, initializedCount in
                let bytesRead = stream.read(buf.baseAddress!, maxLength: buf.count)
                initializedCount = bytesRead
                guard bytesRead >= 0 else {
                    throw stream.streamError!
                }
            }
            data.append(buffer, count: buffer.count)
        } while stream.hasBytesAvailable
        return try jsonObject(with: data, options: opt)
    }
#endif
#endif

    private static func detectEncoding(_ bytes: [UInt8]) -> (String.Encoding, Int) {
        // According to RFC8259, the text encoding in JSON must be UTF8 in nonclosed systems
        // https://tools.ietf.org/html/rfc8259#section-8.1
        // However, since Darwin Foundation supports utf16 and utf32, so should Swift Foundation.

        // First let's check if we can determine the encoding based on a leading Byte Ordering Mark
        // (BOM).
        if bytes.count >= 4 {
            if bytes.starts(with: Self.utf8BOM) {
                return (.utf8, 3)
            }
            if bytes.starts(with: Self.utf32BigEndianBOM) {
                return (.utf32BigEndian, 4)
            }
            if bytes.starts(with: Self.utf32LittleEndianBOM) {
                return (.utf32LittleEndian, 4)
            }
            if bytes.starts(with: [UInt8(0xFF), UInt8(0xFE)]) {
                return (.utf16LittleEndian, 2)
            }
            if bytes.starts(with: [UInt8(0xFE), UInt8(0xFF)]) {
                return (.utf16BigEndian, 2)
            }
        }

        // If there is no BOM present, we might be able to determine the encoding based on
        // occurences of null bytes.
        if bytes.count >= 4 {
            if bytes[0] == UInt8(0) && bytes[1] == UInt8(0) && bytes[2] == UInt8(0) {
                return (.utf32BigEndian, 0)
            } else if bytes[1] == UInt8(0) && bytes[2] == UInt8(0) && bytes[3] == UInt8(0) {
                return (.utf32LittleEndian, 0)
            } else if bytes[0] == UInt8(0) && bytes[2] == UInt8(0) {
                return (.utf16BigEndian, 0)
            } else if bytes[1] == UInt8(0) && bytes[3] == UInt8(0) {
                return (.utf16LittleEndian, 0)
            }
        }
        else if bytes.count >= 2 {
            if bytes[0] == UInt8(0) {
                return (.utf16BigEndian, 0)
            } else if bytes[1] == UInt8(0) {
                return (.utf16LittleEndian, 0)
            }
        }
        return (.utf8, 0)
    }

    // These static properties don't look very nice, but we need them to
    // workaround: https://bugs.swift.org/browse/SR-14102
    private static let utf8BOM: [UInt8] = [UInt8(0xEF), UInt8(0xBB), UInt8(0xBF)]
    private static let utf32BigEndianBOM: [UInt8] = [UInt8(0x00), UInt8(0x00), UInt8(0xFE), UInt8(0xFF)]
    private static let utf32LittleEndianBOM: [UInt8] = [UInt8(0xFF), UInt8(0xFE), UInt8(0x00), UInt8(0x00)]
    private static let utf16BigEndianBOM: [UInt8] = [UInt8(0xFF), UInt8(0xFE)]
    private static let utf16LittleEndianBOM: [UInt8] = [UInt8(0xFE), UInt8(0xFF)]
}

//MARK: - JSONSerializer
private struct JSONWriter {

    var indent = 0
    let pretty: Bool
    let sortedKeys: Bool
    let withoutEscapingSlashes: Bool
    let writer: (String?) -> Void

    init(options: JSONSerialization.WritingOptions, writer: @escaping (String?) -> Void) {
        pretty = options.contains(.prettyPrinted)
        sortedKeys = options.contains(.sortedKeys)
        withoutEscapingSlashes = options.contains(.withoutEscapingSlashes)
        self.writer = writer
    }

    mutating func serializeJSON(_ object: Any?) throws {

        var toSerialize = object

        #if JSON_NOSKIP
        if let number = toSerialize as? _NSNumberCastingWithoutBridging {
            toSerialize = number._swiftValueOfOptimalType
        }
        #endif

        guard let obj = toSerialize else {
            try serializeNull()
            return
        }

        // For better performance, the most expensive conditions to evaluate should be last.
        switch (obj) {
        case let str as String:
            try serializeString(str)
        case let boolValue as Bool:
            writer(boolValue.description)
        case let num as Int:
            writer(num.description)
        case let num as Int8:
            writer(num.description)
        case let num as Int16:
            writer(num.description)
        case let num as Int32:
            writer(num.description)
        case let num as Int64:
            writer(num.description)
        case let num as UInt:
            writer(num.description)
        case let num as UInt8:
            writer(num.description)
        case let num as UInt16:
            writer(num.description)
        case let num as UInt32:
            writer(num.description)
        case let num as UInt64:
            writer(num.description)
        case let array as Array<Any?>:
            try serializeArray(array as Array<Any?>)
        case let dict as Dictionary<AnyHashable, Any?>:
            try serializeDictionary(dict as Dictionary<AnyHashable, Any?>)
        case let num as Float:
            try serializeFloat(Double(num))
        case let num as Double:
            try serializeFloat(num)
        case is NSNull:
            try serializeNull()
        #if JSON_NOSKIP
        case let num as Decimal:
            writer(num.description)
        case let num as NSDecimalNumber:
            writer(num.description)
        case _ where __SwiftValue.store(obj) is NSNumber:
            let num = __SwiftValue.store(obj) as! NSNumber
            writer(num.description)
        #endif
        default:
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [NSDebugDescriptionErrorKey : "Invalid object cannot be serialized"])
        }
    }

    func serializeString(_ str: String) throws {
        writer("\"")
        for scalar in str { // TODO: str.unicodeScalars {
            switch scalar {
                case "\"":
                    writer("\\\"") // U+0022 quotation mark
                case "\\":
                    writer("\\\\") // U+005C reverse solidus
                case "/":
                    if !withoutEscapingSlashes { writer("\\") }
                    writer("/") // U+002F solidus
//                case "\u{8}":
//                    writer("\\b") // U+0008 backspace
//                case "\u{c}":
//                    writer("\\f") // U+000C form feed
                case "\n":
                    writer("\\n") // U+000A line feed
                case "\r":
                    writer("\\r") // U+000D carriage return
                case "\t":
                    writer("\\t") // U+0009 tab
                // TODO
//                case "\u{0}"..."\u{f}":
//                    writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
//                case "\u{10}"..."\u{1f}":
//                    writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
                default:
                    writer(String(scalar))
            }
        }
        writer("\"")
    }

    private func serializeFloat(_ num: Double) throws {
        guard num.isFinite else {
             throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [NSDebugDescriptionErrorKey : "Invalid number value (\(num)) in JSON write"])
        }
        var str = num.description
        if str.hasSuffix(".0") {
            // SKIP NOWARN
            str = String(str.dropLast(2))
        }
        writer(str)
    }

    mutating func serializeArray(_ array: [Any?]) throws {
        writer("[")
        if pretty {
            writer("\n")
            incIndent()
        }

        var first = true
        for elem in array {
            if first {
                first = false
            } else if pretty {
                writer(",\n")
            } else {
                writer(",")
            }
            if pretty {
                writeIndent()
            }
            try serializeJSON(elem)
        }
        if pretty {
            writer("\n")
            decAndWriteIndent()
        }
        writer("]")
    }

    mutating func serializeDictionary(_ dict: Dictionary<AnyHashable, Any?>) throws {
        writer("{")
        if pretty {
            writer("\n")
            incIndent()
            if dict.count > 0 {
                writeIndent()
            }
        }

        var first = true

        func serializeDictionaryElement(key: AnyHashable, value: Any?) throws {
            if first {
                first = false
            } else if pretty {
                writer(",\n")
                writeIndent()
            } else {
                writer(",")
            }

            if let key = key as? String {
                try serializeString(key)
            } else {
                throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [NSDebugDescriptionErrorKey : "NSDictionary key must be NSString"])
            }
            pretty ? writer(" : ") : writer(":")
            try serializeJSON(value)
        }

        if sortedKeys {
            let elems = try dict.sorted(by: { a, b in
                guard let a = a.key as? String,
                    let b = b.key as? String else {
                        throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [NSDebugDescriptionErrorKey : "NSDictionary key must be NSString"])
                }
                #if JSON_NOSKIP
                let options: NSString.CompareOptions = [.numeric, .caseInsensitive, .forcedOrdering]
                let range: Range<String.Index>  = a.startIndex..<a.endIndex
                let locale = NSLocale.system

                return a.compare(b, options: options, range: range, locale: locale) == .orderedAscending
                #else
                return a < b
                #endif
            })
            for elem in elems {
                try serializeDictionaryElement(key: elem.key, value: elem.value)
            }
        } else {
            for (key, value) in dict {
                try serializeDictionaryElement(key: key, value: value)
            }
        }

        if pretty {
            writer("\n")
            decAndWriteIndent()
        }
        writer("}")
    }

    func serializeNull() throws {
        writer("null")
    }

    let indentAmount = 2

    mutating func incIndent() {
        indent += indentAmount
    }

    mutating func incAndWriteIndent() {
        indent += indentAmount
        writeIndent()
    }

    mutating func decAndWriteIndent() {
        indent -= indentAmount
        writeIndent()
    }

    func writeIndent() {
        for _ in 0..<indent {
            writer(" ")
        }
    }
}

public enum JSONValue: Equatable {
    case string(String)
    case number(String)
    case bool(Bool)
    case null

    case array([JSONValue])
    case object([String: JSONValue])

    public var isValue: Bool {
        switch self {
        case .array, .object:
            return false
        case .null, .number, .string, .bool:
            return true
        }
    }

    public var isContainer: Bool {
        switch self {
        case .array, .object:
            return true
        case .null, .number, .string, .bool:
            return false
        }
    }

    public var debugDataTypeDescription: String {
        switch self {
        case .array:
            return "an array"
        case .bool:
            return "bool"
        case .number:
            return "a number"
        case .string:
            return "a string"
        case .object:
            return "a dictionary"
        case .null:
            return "null"
        }
    }
}

#endif
