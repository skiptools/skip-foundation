// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class PropertyListSerialization {
    @available(*, unavailable)
    public static func propertyList(_ propertyList: Any, isValidFor: PropertyListSerialization.PropertyListFormat) -> Bool {
        fatalError()
    }


    public static func propertyList(from: Data, options: PropertyListSerialization.ReadOptions = [], format: Any?) throws -> [String: String]? {
        // TODO: auto-detect format from data content if the format argument is unset
        return try openStepPropertyList(from: from, options: options)
    }

    static func openStepPropertyList(from: Data, options: PropertyListSerialization.ReadOptions = []) throws -> [String: String]? {
        var dict: Dictionary<String, String> = [:]

        let text = from.utf8String

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
