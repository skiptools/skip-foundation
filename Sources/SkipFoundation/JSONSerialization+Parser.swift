// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
internal class JSONParser {
    var reader: org.json.JSONTokener

    init(bytes: [UInt8]) {
        self.reader = org.json.JSONTokener(String(data: Data(bytes), encoding: .utf8) ?? "")
    }

    public func parse() throws -> JSONValue {
        try createJSONValue(from: reader.nextValue())
    }

    public func parseSwift() throws -> Any {
        try createSwiftValue(from: reader.nextValue())
    }

    /// https://developer.android.com/reference/org/json/JSONTokener#nextValue()
    /// a JSONObject, JSONArray, String, Boolean, Integer, Long, Double or JSONObject#NULL.
    func createSwiftValue(from token: Any) throws -> Any {
        if token === nil || token === org.json.JSONObject.NULL {
            return NSNull.null
        } else {
            switch token {
            case let bd as java.math.BigDecimal: // happens with org.json package, but not Android's version
                if let dbl = Double(bd.toString()) {
                    return dbl
                } else {
                    throw JSONError.numberIsNotRepresentableInSwift(parsed: bd.toString())
                }
            case let obj as org.json.JSONObject:
                var dict = Dictionary<String, Any>()
                for key in obj.keys() {
                    dict[key] = createSwiftValue(from: obj.get(key))
                }
                return dict
            case let arr as org.json.JSONArray:
                var array = Array<Any>()
                for i in 0..<arr.length() {
                    array.append(createSwiftValue(from: arr.get(i)))
                }
                return array
            default:
                return token
            }
        }
    }

    //~~~ TODO: Remove?
    func createJSONValue(from token: Any) -> JSONValue {
        if token === nil || token === org.json.JSONObject.NULL {
            return JSONValue.null
        } else {
            switch token {
            case let str as String:
                return JSONValue.string(str)
            case let lng as Long:
                return JSONValue.number(lng.toString())
            case let int as Integer:
                return JSONValue.number(int.toString())
            case let dbl as Double:
                return JSONValue.number(dbl.toString())
            case let bd as java.math.BigDecimal: // happens with org.json package, but not Android's version
                return JSONValue.number(bd.toString())
            case let bol as Boolean:
                return JSONValue.bool(bol)
            case let obj as org.json.JSONObject:
                var dict = Dictionary<String, JSONValue>()
                for key in obj.keys() {
                    dict[key] = createJSONValue(from: obj.get(key))
                }
                return JSONValue.object(dict)
            case let arr as org.json.JSONArray:
                var array = Array<JSONValue>()
                for i in 0..<arr.length() {
                    array.append(createJSONValue(from: arr.get(i)))
                }
                return JSONValue.array(array)
            default:
                fatalError("Unhandled JSON type: \(type(of: token))")
            }
        }
    }
}

/// Mimics the constructor `UInt8(ascii:)`
func UByte(ascii: String) -> UInt8 {
    ascii.first().toByte().toUByte()
}

/// Mimics the constructor `UInt8(ascii:)`
func UInt8(ascii: String) -> UInt8 {
    ascii.first().toByte().toUByte()
}
#endif

internal let UInt8_space: UInt8 = UInt8(ascii: " ")
internal let UInt8_return: UInt8 = UInt8(ascii: "\r")
internal let UInt8_newline: UInt8 = UInt8(ascii: "\n")
internal let UInt8_tab: UInt8 = UInt8(ascii: "\t")

internal let UInt8_colon: UInt8 = UInt8(ascii: ":")
internal let UInt8_comma: UInt8 = UInt8(ascii: ",")

internal let UInt8_openbrace: UInt8 = UInt8(ascii: "{")
internal let UInt8_closebrace: UInt8 = UInt8(ascii: "}")

internal let UInt8_openbracket: UInt8 = UInt8(ascii: "[")
internal let UInt8_closebracket: UInt8 = UInt8(ascii: "]")

internal let UInt8_quote: UInt8 = UInt8(ascii: "\"")
internal let UInt8_backslash: UInt8 = UInt8(ascii: "\\")

internal let UInt8Array_true: Array<UInt8> = [UInt8(ascii: "t"), UInt8(ascii: "r"), UInt8(ascii: "u"), UInt8(ascii: "e")]
internal let UInt8Array_false: Array<UInt8> = [UInt8(ascii: "f"), UInt8(ascii: "a"), UInt8(ascii: "l"), UInt8(ascii: "s"), UInt8(ascii: "e")]
internal let UInt8Array_null: Array<UInt8> = [UInt8(ascii: "n"), UInt8(ascii: "u"), UInt8(ascii: "l"), UInt8(ascii: "l")]

enum JSONError: Error, Equatable {
    case cannotConvertInputDataToUTF8
    case unexpectedCharacter(ascii: UInt8, characterIndex: Int)
    case unexpectedEndOfFile
    case tooManyNestedArraysOrDictionaries(characterIndex: Int)
    case invalidHexDigitSequence(String, index: Int)
    case unexpectedEscapedCharacter(ascii: UInt8, in: String, index: Int)
    case unescapedControlCharacterInString(ascii: UInt8, in: String, index: Int)
    case expectedLowSurrogateUTF8SequenceAfterHighSurrogate(in: String, index: Int)
    case couldNotCreateUnicodeScalarFromUInt32(in: String, index: Int, unicodeScalarValue: UInt32)
    case numberWithLeadingZero(index: Int)
    case numberIsNotRepresentableInSwift(parsed: String)
    case singleFragmentFoundButNotAllowed
    case invalidUTF8Sequence(Data, characterIndex: Int)
}

#if !SKIP

// This code is adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which has the following license:


//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//


internal struct JSONParser {
    var reader: DocumentReader
    var depth: Int = 0

    init(bytes: [UInt8]) {
        self.reader = DocumentReader(array: bytes)
    }

    mutating func parse() throws -> JSONValue {
        try reader.consumeWhitespace()
        let value = try self.parseValue()
        #if DEBUG
        defer {
            guard self.depth == 0 else {
                preconditionFailure("Expected to end parsing with a depth of 0")
            }
        }
        #endif

        // ensure only white space is remaining
        var whitespace = 0
        while let next = reader.peek(offset: whitespace) {
            switch next {
            case UInt8_space, UInt8_tab, UInt8_return, UInt8_newline:
                whitespace += 1
                continue
            default:
                throw JSONError.unexpectedCharacter(ascii: next, characterIndex: reader.readerIndex + whitespace)
            }
        }

        return value
    }

    // MARK: Generic Value Parsing

    mutating func parseValue() throws -> JSONValue {
        var whitespace = 0
        while let byte = reader.peek(offset: whitespace) {
            switch byte {
            case UInt8(ascii: "\""):
                reader.moveReaderIndex(forwardBy: whitespace)
                return .string(try reader.readString())
            case UInt8_openbrace:
                reader.moveReaderIndex(forwardBy: whitespace)
                let object = try parseObject()
                return .object(object)
            case UInt8_openbracket:
                reader.moveReaderIndex(forwardBy: whitespace)
                let array = try parseArray()
                return .array(array)
            case UInt8(ascii: "f"), UInt8(ascii: "t"):
                reader.moveReaderIndex(forwardBy: whitespace)
                let bool = try reader.readBool()
                return .bool(bool)
            case UInt8(ascii: "n"):
                reader.moveReaderIndex(forwardBy: whitespace)
                try reader.readNull()
                return .null
            case UInt8(ascii: "-"), UInt8(ascii: "0") ... UInt8(ascii: "9"):
                reader.moveReaderIndex(forwardBy: whitespace)
                let number = try self.reader.readNumber()
                return .number(number)
            case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab:
                whitespace += 1
                continue
            default:
                throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: self.reader.readerIndex)
            }
        }

        throw JSONError.unexpectedEndOfFile
    }


    // MARK: - Parse Array -

    mutating func parseArray() throws -> [JSONValue] {
        precondition(self.reader.read() == UInt8_openbracket)
        guard self.depth < 512 else {
            throw JSONError.tooManyNestedArraysOrDictionaries(characterIndex: self.reader.readerIndex - 1)
        }
        self.depth += 1
        defer { depth -= 1 }

        // parse first value or end immediatly
        switch try reader.consumeWhitespace() {
        case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab:
            preconditionFailure("Expected that all white space is consumed")
        case UInt8_closebracket:
            // if the first char after whitespace is a closing bracket, we found an empty array
            self.reader.moveReaderIndex(forwardBy: 1)
            return []
        default:
            break
        }

        var array = [JSONValue]()
        array.reserveCapacity(10)

        // parse values
        while true {
            let value = try parseValue()
            array.append(value)

            // consume the whitespace after the value before the comma
            let ascii = try reader.consumeWhitespace()
            switch ascii {
            case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab:
                preconditionFailure("Expected that all white space is consumed")
            case UInt8_closebracket:
                reader.moveReaderIndex(forwardBy: 1)
                return array
            case UInt8_comma:
                // consume the comma
                reader.moveReaderIndex(forwardBy: 1)
                // consume the whitespace before the next value
                if try reader.consumeWhitespace() == UInt8_closebracket {
                    // the foundation json implementation does support trailing commas
                    reader.moveReaderIndex(forwardBy: 1)
                    return array
                }
                continue
            default:
                throw JSONError.unexpectedCharacter(ascii: ascii, characterIndex: reader.readerIndex)
            }
        }
    }

    // MARK: - Object parsing -

    mutating func parseObject() throws -> [String: JSONValue] {
        precondition(self.reader.read() == UInt8_openbrace)
        guard self.depth < 512 else {
            throw JSONError.tooManyNestedArraysOrDictionaries(characterIndex: self.reader.readerIndex - 1)
        }
        self.depth += 1
        defer { depth -= 1 }

        // parse first value or end immediatly
        switch try reader.consumeWhitespace() {
        case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab:
            preconditionFailure("Expected that all white space is consumed")
        case UInt8_closebrace:
            // if the first char after whitespace is a closing bracket, we found an empty array
            self.reader.moveReaderIndex(forwardBy: 1)
            return [:]
        default:
            break
        }

        var object = Dictionary<String, JSONValue>()
        object.reserveCapacity(20)

        while true {
            let key = try reader.readString()
            let colon = try reader.consumeWhitespace()
            guard colon == UInt8_colon else {
                throw JSONError.unexpectedCharacter(ascii: colon, characterIndex: reader.readerIndex)
            }
            reader.moveReaderIndex(forwardBy: 1)
            try reader.consumeWhitespace()
            object[key] = try self.parseValue()

            let commaOrBrace = try reader.consumeWhitespace()
            switch commaOrBrace {
            case UInt8_closebrace:
                reader.moveReaderIndex(forwardBy: 1)
                return object
            case UInt8_comma:
                reader.moveReaderIndex(forwardBy: 1)
                if try reader.consumeWhitespace() == UInt8_closebrace {
                    // the foundation json implementation does support trailing commas
                    reader.moveReaderIndex(forwardBy: 1)
                    return object
                }
                continue
            default:
                throw JSONError.unexpectedCharacter(ascii: commaOrBrace, characterIndex: reader.readerIndex)
            }
        }
    }
}

extension JSONParser {

    struct DocumentReader {
        let array: [UInt8]

        private(set) var readerIndex: Int = 0

        private var readableBytes: Int {
            self.array.endIndex - self.readerIndex
        }

        var isEOF: Bool {
            self.readerIndex >= self.array.endIndex
        }


        init(array: [UInt8]) {
            self.array = array
        }

        subscript<R: RangeExpression<Int>>(bounds: R) -> ArraySlice<UInt8> {
            self.array[bounds]
        }

        mutating func read() -> UInt8? {
            guard self.readerIndex < self.array.endIndex else {
                self.readerIndex = self.array.endIndex
                return nil
            }

            defer { self.readerIndex += 1 }

            return self.array[self.readerIndex]
        }

        func peek(offset: Int = 0) -> UInt8? {
            guard self.readerIndex + offset < self.array.endIndex else {
                return nil
            }

            return self.array[self.readerIndex + offset]
        }

        mutating func moveReaderIndex(forwardBy offset: Int) {
            self.readerIndex += offset
        }

        @discardableResult
        mutating func consumeWhitespace() throws -> UInt8 {
            var whitespace = 0
            while let ascii = self.peek(offset: whitespace) {
                switch ascii {
                case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab:
                    whitespace += 1
                    continue
                default:
                    self.moveReaderIndex(forwardBy: whitespace)
                    return ascii
                }
            }

            throw JSONError.unexpectedEndOfFile
        }

        mutating func readString() throws -> String {
            try self.readUTF8StringTillNextUnescapedQuote()
        }

        mutating func readNumber() throws -> String {
            try self.parseNumber()
        }

        mutating func readBool() throws -> Bool {
            switch self.read() {
            case UInt8(ascii: "t"):
                guard self.read() == UInt8(ascii: "r"),
                      self.read() == UInt8(ascii: "u"),
                      self.read() == UInt8(ascii: "e")
                else {
                    guard !self.isEOF else {
                        throw JSONError.unexpectedEndOfFile
                    }

                    throw JSONError.unexpectedCharacter(ascii: self.peek(offset: -1)!, characterIndex: self.readerIndex - 1)
                }

                return true
            case UInt8(ascii: "f"):
                guard self.read() == UInt8(ascii: "a"),
                      self.read() == UInt8(ascii: "l"),
                      self.read() == UInt8(ascii: "s"),
                      self.read() == UInt8(ascii: "e")
                else {
                    guard !self.isEOF else {
                        throw JSONError.unexpectedEndOfFile
                    }

                    throw JSONError.unexpectedCharacter(ascii: self.peek(offset: -1)!, characterIndex: self.readerIndex - 1)
                }

                return false
            default:
                preconditionFailure("Expected to have `t` or `f` as first character")
            }
        }

        mutating func readNull() throws {
            guard self.read() == UInt8(ascii: "n"),
                  self.read() == UInt8(ascii: "u"),
                  self.read() == UInt8(ascii: "l"),
                  self.read() == UInt8(ascii: "l")
            else {
                guard !self.isEOF else {
                    throw JSONError.unexpectedEndOfFile
                }

                throw JSONError.unexpectedCharacter(ascii: self.peek(offset: -1)!, characterIndex: self.readerIndex - 1)
            }
        }

        // MARK: - Private Methods -

        // MARK: String

        enum EscapedSequenceError: Swift.Error {
            case expectedLowSurrogateUTF8SequenceAfterHighSurrogate(index: Int)
            case unexpectedEscapedCharacter(ascii: UInt8, index: Int)
            case couldNotCreateUnicodeScalarFromUInt32(index: Int, unicodeScalarValue: UInt32)
        }

        private mutating func readUTF8StringTillNextUnescapedQuote() throws -> String {
            guard self.read() == UInt8_quote else {
                throw JSONError.unexpectedCharacter(ascii: self.peek(offset: -1)!, characterIndex: self.readerIndex - 1)
            }
            var stringStartIndex = self.readerIndex
            var copy = 0
            var output: String?

            while let byte = peek(offset: copy) {
                switch byte {
                case UInt8(ascii: "\""):
                    self.moveReaderIndex(forwardBy: copy + 1)
                    guard var result = output else {
                        // if we don't have an output string we create a new string
                        return try makeString(at: stringStartIndex ..< stringStartIndex + copy)
                    }
                    // if we have an output string we append
                    result += try makeString(at: stringStartIndex ..< stringStartIndex + copy)
                    return result

                case 0 ... 31:
                    // All Unicode characters may be placed within the
                    // quotation marks, except for the characters that must be escaped:
                    // quotation mark, reverse solidus, and the control characters (U+0000
                    // through U+001F).
                    var string = output ?? ""
                    let errorIndex = self.readerIndex + copy
                    string += try makeString(at: stringStartIndex ... errorIndex)
                    throw JSONError.unescapedControlCharacterInString(ascii: byte, in: string, index: errorIndex)

                case UInt8(ascii: "\\"):
                    self.moveReaderIndex(forwardBy: copy)
                    if output != nil {
                        output! += try makeString(at: stringStartIndex ..< stringStartIndex + copy)
                    } else {
                        output = try makeString(at: stringStartIndex ..< stringStartIndex + copy)
                    }

                    let escapedStartIndex = self.readerIndex

                    do {
                        let escaped = try parseEscapeSequence()
                        output! += escaped
                        stringStartIndex = self.readerIndex
                        copy = 0
                    } catch EscapedSequenceError.unexpectedEscapedCharacter(let ascii, let failureIndex) {
                        output! += try makeString(at: escapedStartIndex ..< self.readerIndex)
                        throw JSONError.unexpectedEscapedCharacter(ascii: ascii, in: output!, index: failureIndex)
                    } catch EscapedSequenceError.expectedLowSurrogateUTF8SequenceAfterHighSurrogate(let failureIndex) {
                        output! += try makeString(at: escapedStartIndex ..< self.readerIndex)
                        throw JSONError.expectedLowSurrogateUTF8SequenceAfterHighSurrogate(in: output!, index: failureIndex)
                    } catch EscapedSequenceError.couldNotCreateUnicodeScalarFromUInt32(let failureIndex, let unicodeScalarValue) {
                        output! += try makeString(at: escapedStartIndex ..< self.readerIndex)
                        throw JSONError.couldNotCreateUnicodeScalarFromUInt32(
                            in: output!, index: failureIndex, unicodeScalarValue: unicodeScalarValue
                        )
                    }

                default:
                    copy += 1
                    continue
                }
            }

            throw JSONError.unexpectedEndOfFile
        }

        private func makeString<R: RangeExpression<Int>>(at range: R) throws -> String {
            let raw = array[range]
            guard let str = String(bytes: raw, encoding: String.Encoding.utf8) else {
                throw JSONError.invalidUTF8Sequence(Data(raw), characterIndex: range.relative(to: array).lowerBound)
            }
            return str
        }

        private mutating func parseEscapeSequence() throws -> String {
            precondition(self.read() == UInt8_backslash, "Expected to have an backslash first")
            guard let ascii = self.read() else {
                throw JSONError.unexpectedEndOfFile
            }

            switch ascii {
            case UInt8(0x22): return "\""
            case UInt8(0x5C): return "\\"
            case UInt8(0x2F): return "/"
            case UInt8(0x62): return "\u{08}" // \b
            case UInt8(0x66): return "\u{0C}" // \f
            case UInt8(0x6E): return "\u{0A}" // \n
            case UInt8(0x72): return "\u{0D}" // \r
            case UInt8(0x74): return "\u{09}" // \t
            case UInt8(0x75):
                let character = try parseUnicodeSequence()
                return String(character)
            default:
                throw EscapedSequenceError.unexpectedEscapedCharacter(ascii: ascii, index: self.readerIndex - 1)
            }
        }

        private mutating func parseUnicodeSequence() throws -> Unicode.Scalar {
            // we build this for utf8 only for now.
            let bitPattern = try parseUnicodeHexSequence()

            // check if high surrogate
            let isFirstByteHighSurrogate = bitPattern & 0xFC00 // nil everything except first six bits
            if isFirstByteHighSurrogate == 0xD800 {
                // if we have a high surrogate we expect a low surrogate next
                let highSurrogateBitPattern = bitPattern
                guard let (escapeChar) = self.read(),
                      let (uChar) = self.read()
                else {
                    throw JSONError.unexpectedEndOfFile
                }

                guard escapeChar == UInt8(ascii: #"\"#), uChar == UInt8(ascii: "u") else {
                    throw EscapedSequenceError.expectedLowSurrogateUTF8SequenceAfterHighSurrogate(index: self.readerIndex - 1)
                }

                let lowSurrogateBitBattern = try parseUnicodeHexSequence()
                let isSecondByteLowSurrogate = lowSurrogateBitBattern & 0xFC00 // nil everything except first six bits
                guard isSecondByteLowSurrogate == 0xDC00 else {
                    // we are in an escaped sequence. for this reason an output string must have
                    // been initialized
                    throw EscapedSequenceError.expectedLowSurrogateUTF8SequenceAfterHighSurrogate(index: self.readerIndex - 1)
                }

                let highValue = UInt32(highSurrogateBitPattern - 0xD800) * 0x400
                let lowValue = UInt32(lowSurrogateBitBattern - 0xDC00)
                let unicodeValue = highValue + lowValue + 0x10000
                guard let unicode = Unicode.Scalar(unicodeValue) else {
                    throw EscapedSequenceError.couldNotCreateUnicodeScalarFromUInt32(
                        index: self.readerIndex, unicodeScalarValue: unicodeValue
                    )
                }
                return unicode
            }

            #if !JSON_NOSKIP // Cannot convert value of type 'UInt16' to expected argument type 'UnicodeScalarValue' (aka 'UInt32')
            fatalError("SKIP TODO: Unicode.Scalar(bitPattern)")
            #else
            guard let unicode = Unicode.Scalar(bitPattern) else {
                throw EscapedSequenceError.couldNotCreateUnicodeScalarFromUInt32(
                    index: self.readerIndex, unicodeScalarValue: UInt32(bitPattern)
                )
            }
            return unicode
            #endif
        }

        private mutating func parseUnicodeHexSequence() throws -> UInt16 {
            // As stated in RFC-8259 an escaped unicode character is 4 HEXDIGITs long
            // https://tools.ietf.org/html/rfc8259#section-7
            let startIndex = self.readerIndex
            guard let firstHex = self.read(),
                  let secondHex = self.read(),
                  let thirdHex = self.read(),
                  let forthHex = self.read()
            else {
                throw JSONError.unexpectedEndOfFile
            }

            guard let first = DocumentReader.hexAsciiTo4Bits(firstHex),
                  let second = DocumentReader.hexAsciiTo4Bits(secondHex),
                  let third = DocumentReader.hexAsciiTo4Bits(thirdHex),
                  let forth = DocumentReader.hexAsciiTo4Bits(forthHex)
            else {
                #if !JSON_NOSKIP // Initializer 'init(decoding:as:)' requires the types 'UInt8' and 'Unicode.UTF8.CodeUnit' be equivalent
                fatalError("TODO: String(decoding:)")
                #else
                let hexString = String(decoding: [firstHex, secondHex, thirdHex, forthHex], as: Unicode.UTF8.self)
                throw JSONError.invalidHexDigitSequence(hexString, index: startIndex)
                #endif
            }
            let firstByte = UInt16(first) << 4 | UInt16(second)
            let secondByte = UInt16(third) << 4 | UInt16(forth)

            let bitPattern = UInt16(firstByte) << 8 | UInt16(secondByte)

            return bitPattern
        }

        private static func hexAsciiTo4Bits(_ ascii: UInt8) -> UInt8? {
            switch ascii {
            case UInt8(48) ... UInt8(57):
                return ascii - UInt8(48) as UInt8?
            case UInt8(65) ... UInt8(70):
                // uppercase letters
                return ascii - UInt8(55) as UInt8?
            case UInt8(97) ... UInt8(102):
                // lowercase letters
                return ascii - UInt8(87) as UInt8?
            default:
                return nil
            }
        }

        // MARK: Numbers

        private enum ControlCharacter {
            case operand
            case decimalPoint
            case exp
            case expOperator
        }

        private mutating func parseNumber() throws -> String {
            var pastControlChar: ControlCharacter = .operand
            var numbersSinceControlChar = 0
            var hasLeadingZero = false

            // parse first character

            guard let ascii = self.peek() else {
                preconditionFailure("Why was this function called, if there is no 0...9 or -")
            }
            switch ascii {
            case UInt8(ascii: "0"):
                numbersSinceControlChar = 1
                pastControlChar = .operand
                hasLeadingZero = true
            case UInt8(ascii: "1") ... UInt8(ascii: "9"):
                numbersSinceControlChar = 1
                pastControlChar = .operand
            case UInt8(ascii: "-"):
                numbersSinceControlChar = 0
                pastControlChar = .operand
            default:
                preconditionFailure("Why was this function called, if there is no 0...9 or -")
            }

            var numberchars = 1

            // parse everything else
            while let byte = self.peek(offset: numberchars) {
                switch byte {
                case UInt8(ascii: "0"):
                    if hasLeadingZero {
                        throw JSONError.numberWithLeadingZero(index: readerIndex + numberchars)
                    }
                    if numbersSinceControlChar == 0, pastControlChar == .operand {
                        // the number started with a minus. this is the leading zero.
                        hasLeadingZero = true
                    }
                    numberchars += 1
                    numbersSinceControlChar += 1
                case UInt8(ascii: "1") ... UInt8(ascii: "9"):
                    if hasLeadingZero {
                        throw JSONError.numberWithLeadingZero(index: readerIndex + numberchars)
                    }
                    numberchars += 1
                    numbersSinceControlChar += 1
                case UInt8(ascii: "."):
                    guard numbersSinceControlChar > 0, pastControlChar == .operand else {
                        throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: readerIndex + numberchars)
                    }
                    
                    numberchars += 1
                    hasLeadingZero = false
                    pastControlChar = .decimalPoint
                    numbersSinceControlChar = 0
                    
                case UInt8(ascii: "e"), UInt8(ascii: "E"):
                    guard numbersSinceControlChar > 0,
                          pastControlChar == .operand || pastControlChar == .decimalPoint
                    else {
                        throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: readerIndex + numberchars)
                    }
                    
                    numberchars += 1
                    hasLeadingZero = false
                    pastControlChar = .exp
                    numbersSinceControlChar = 0
                case UInt8(ascii: "+"), UInt8(ascii: "-"):
                    guard numbersSinceControlChar == 0, pastControlChar == .exp else {
                        throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: readerIndex + numberchars)
                    }
                    
                    numberchars += 1
                    pastControlChar = .expOperator
                    numbersSinceControlChar = 0
                case UInt8_space, UInt8_return, UInt8_newline, UInt8_tab, UInt8_comma, UInt8_closebracket, UInt8_closebrace:
                    guard numbersSinceControlChar > 0 else {
                        throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: readerIndex + numberchars)
                    }
                    let numberStartIndex = self.readerIndex
                    self.moveReaderIndex(forwardBy: numberchars)

                    #if !JSON_NOSKIP // Initializer 'init(decoding:as:)' requires the types 'UInt8' and 'Unicode.UTF8.CodeUnit' be equivalent
                    fatalError("TODO: String(decoding:)")
                    #else
                    return String(decoding: self[numberStartIndex ..< self.readerIndex], as: Unicode.UTF8.self)
                    #endif
                default:
                    throw JSONError.unexpectedCharacter(ascii: byte, characterIndex: readerIndex + numberchars)
                }
            }

            guard numbersSinceControlChar > 0 else {
                throw JSONError.unexpectedEndOfFile
            }

            defer { self.readerIndex = self.array.endIndex }

            fatalError("TODO: String(decoding:)")
            //return String(decoding: self.array.suffix(from: readerIndex), as: Swift.Unicode.UTF8.self)
        }
    }
}

extension UInt8 {

    internal static let _space = UInt8(ascii: " ")
    internal static let _return = UInt8(ascii: "\r")
    internal static let _newline = UInt8(ascii: "\n")
    internal static let _tab = UInt8(ascii: "\t")

    internal static let _colon = UInt8(ascii: ":")
    internal static let _comma = UInt8(ascii: ",")

    internal static let _openbrace = UInt8(ascii: "{")
    internal static let _closebrace = UInt8(ascii: "}")

    internal static let _openbracket = UInt8(ascii: "[")
    internal static let _closebracket = UInt8(ascii: "]")

    internal static let _quote = UInt8(ascii: "\"")
    internal static let _backslash = UInt8(ascii: "\\")
}

extension Array where Element == UInt8 {

    internal static let _true = [UInt8(ascii: "t"), UInt8(ascii: "r"), UInt8(ascii: "u"), UInt8(ascii: "e")]
    internal static let _false = [UInt8(ascii: "f"), UInt8(ascii: "a"), UInt8(ascii: "l"), UInt8(ascii: "s"), UInt8(ascii: "e")]
    internal static let _null = [UInt8(ascii: "n"), UInt8(ascii: "u"), UInt8(ascii: "l"), UInt8(ascii: "l")]
}

#endif // !SKIP
