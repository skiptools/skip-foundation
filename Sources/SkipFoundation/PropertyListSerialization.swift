// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP
import android.util.Xml
import org.xmlpull.v1.XmlPullParser
import java.io.ByteArrayInputStream

public class PropertyListSerialization {
    
    @available(*, unavailable)
    public static func propertyList(_ propertyList: Any, isValidFor: PropertyListSerialization.PropertyListFormat) -> Bool {
        fatalError()
    }

    public static func propertyList(from data: Data, options: PropertyListSerialization.ReadOptions = [], format: Any?) throws -> [String: String]? {
        let text = data.utf8String
        guard let text = text else {
            // should this throw an error?
            return nil
        }

        switch format {
        case PropertyListFormat.xml:
            return try convertStringsDictToICUDict(from: data)
        default:
            // TODO: auto-detect format from data content if the format argument is unset
            return try openStepPropertyList(from: data, options: options)
        }
    }

    private static func convertStringsDictToICUDict(from data: Data) throws -> [String: String]? {
        let parser = Xml.newPullParser()
        parser.setInput(ByteArrayInputStream(data.platformValue), "UTF-8")

        var result: [String: String] = [:]
        var dictStack: [[String: Any]] = []
        var keyStack: [String] = []
        var textAccumulator = ""

        var eventType = parser.getEventType()
        while eventType != XmlPullParser.END_DOCUMENT {

            let tagName = parser.getName()
            switch eventType {
            case XmlPullParser.START_TAG:
                textAccumulator = ""
                if tagName == "dict" {
                    dictStack.append([:])
                }

            case XmlPullParser.TEXT:
                textAccumulator += parser.getText() ?? ""

            case XmlPullParser.END_TAG:
                let content = textAccumulator.trimmingCharacters(in: .whitespacesAndNewlines)
                switch tagName {
                case "key":
                    keyStack.append(content)
                case "string":
                    if let key = keyStack.popLast(), !dictStack.isEmpty {
                        dictStack[dictStack.count - 1][key] = content
                    }
                case "dict":
                    if let finishedDict = dictStack.popLast() {
                        if let parentKey = keyStack.popLast(), !dictStack.isEmpty {
                            dictStack[dictStack.count - 1][parentKey] = finishedDict
                        } else {
                            for (key, value) in finishedDict {
                                /* SKIP NOWARN */
                                if let stringsDict = value as? [String: Any],
                                   let icuString = convertStringsDictToICUString(stringsDict) {
                                    result[key] = icuString
                                }
                            }
                        }
                    }
                default:
                    break
                }

                textAccumulator = ""
            default:
                break
            }

            eventType = parser.next()
        }

        return result
    }

    private static func convertStringsDictToICUString(_ stringsDict: [String: Any]) -> String? {
        guard let formatKey = stringsDict["NSStringLocalizedFormatKey"] as? String else {
            return nil
        }

        var result: String = formatKey

        /* SKIP NOWARN */
        for (key, varDict) in stringsDict.compactMapValues({ $0 as? [String: Any] }) {
            guard let specType = varDict["NSStringFormatSpecTypeKey"] as? String, specType == "NSStringPluralRuleType"
            else {
                continue
            }

            let categories = ["zero", "one", "two", "few", "many", "other"]
            let rules = categories.compactMap { (category: String) -> String? in
                guard let pluralString = varDict[category] as? String else { return nil }
                var cleaned = pluralString
                    .replacingOccurrences(of: "%d", with: "#")
                    .replacingOccurrences(of: "%f", with: "#")
                    .replacingOccurrences(of: "%@", with: "{0}")
                for index in 1...10 {
                    cleaned = cleaned
                        .replacingOccurrences(of: "%\(index)$@", with: "{\(index-1)}")
                        .replacingOccurrences(of: "%\(index)$d", with: "{\(index-1)}")
                }
                return "\(category){\(cleaned)}"
            }.joined(separator: " ")

            if !rules.isEmpty {
                let pattern = "%#@\(key)@"
                let replacement = "{0, plural, \(rules)}"

                if result.contains(pattern) {
                    result = result.replacingOccurrences(of: pattern, with: replacement)
                } else if result.contains("%#@") {
                    let parts = result.components(separatedBy: "%#@")
                    if parts.count > 1 {
                        let prefix = parts[0]
                        let remaining = parts[1]
                        let subParts = remaining.components(separatedBy: "@")
                        if subParts.count > 1 {
                            let suffix = subParts[1...].joined(separator: "@")
                            result = prefix + replacement + suffix
                        }
                    }
                }
            }
        }

        return result
    }

    private static func openStepPropertyList(from data: Data, options: PropertyListSerialization.ReadOptions = []) throws -> [String: String]? {
        var dict: Dictionary<String, String> = [:]

        let text = data.utf8String
        guard let text = text else {
            // should this throw an error?
            return nil
        }

        let lines = text.components(separatedBy: "\n")

        for line in lines {
            if !line.hasPrefix("\"") {
                continue // maybe a comment? (note: we do no support multi-line /* */ comments
            }
            var key: String?
            var value: String?
            var isParsingKey = true
            var currentToken = ""
            var isEscaped = false
            var isInsideString = false

            for char in line {
                if isEscaped {
                    if char == "n" {
                        currentToken += "\n"
                    } else if char == "r" {
                        currentToken += "\r"
                    } else if char == "t" {
                        currentToken += "\t"
                    //} else if char == "u" { // TODO: handle unicode escapes like \uXXXX
                    } else {
                        // otherwise, just add the literal characters (like " or \)
                        currentToken += char
                    }
                    isEscaped = false
                    continue
                }

                switch char {
                case "\\":
                    isEscaped = true
                case "\"":
                    isInsideString = !isInsideString
                    if !isInsideString {
                        if isParsingKey {
                            key = currentToken
                            isParsingKey = false
                        } else {
                            value = currentToken
                        }
                        currentToken = ""
                    }
                case "=":
                    if isInsideString {
                        currentToken += char
                    } else {
                        isParsingKey = false
                    }

                case ";":
                    if isInsideString {
                        currentToken += char
                    } else {
                        if let k = key, let v = value {
                            dict[k] = v
                        }
                    }

                default:
                    if isInsideString {
                        currentToken += char
                    }
                }
            }
        }

        return dict
    }

    @available(*, unavailable)
    public static func data(fromPropertyList: Any, format: PropertyListSerialization.PropertyListFormat, options: PropertyListSerialization.WriteOptions) -> Data {
        fatalError()
    }

    @available(*, unavailable)
    public static func writePropertyList(_ propertyList: Any, to: Any, format: PropertyListSerialization.PropertyListFormat, options: PropertyListSerialization.WriteOptions, error: Any) -> Int {
        fatalError()
    }

    @available(*, unavailable)
    public static func propertyList(with: Any, options: PropertyListSerialization.ReadOptions = [], format: Any?) -> Any {
        fatalError()
    }

    public enum PropertyListFormat: UInt {
        case openStep = 1
        case xml = 100
        case binary = 200
    }

    public struct ReadOptions: RawRepresentable, OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let mutableContainers = ReadOptions(rawValue: UInt(1))
        public static let mutableContainersAndLeaves = ReadOptions(rawValue: UInt(2))
    }

    public typealias WriteOptions = Int
}

#endif
