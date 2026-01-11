// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

internal class JSONParser {
    var reader: org.json.JSONTokener

    init(bytes: [UInt8]) {
        self.reader = org.json.JSONTokener(String(data: Data(bytes), encoding: .utf8) ?? "")
    }

    public func parseJSONValue() throws -> JSONValue {
        try createJSONValue(from: reader.nextValue())
    }

    public func parseSwiftValue() throws -> Any {
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
            case let bol as Boolean:
                return bol == true
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

#endif
