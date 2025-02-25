// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public class PropertyListSerialization {
    public static func propertyList(from: Data, options: PropertyListSerialization.ReadOptions = [], format: Any?) throws -> [String: String]? {
        var dict: Dictionary<String, String> = [:]
        //let re = #"(?<!\\)"(.*?)(?<!\\)"\s*=\s*"(.*?)(?<!\\)";"# // Swift Regex error: "lookbehind is not currently supported"
        //let re = "^\"(.*)\"[ ]*=[ ]*\"(.*)\";\\s*$"
        let re = "^\"(.*)\"[ ]*=[ ]*\"(.*)\";$" // needs https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.text/-regex-option/-m-u-l-t-i-l-i-n-e.html

        let text = from.utf8String

        guard let text = text else {
            // should this throw an error?
            return nil
        }

        func unescape(_ string: String) -> String {
            string
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\n", with: "\n")
        }

        for line in text.components(separatedBy: "\n") {
            let exp = try kotlin.text.Regex(re, RegexOption.MULTILINE) // https://www.baeldung.com/regular-expressions-java#Pattern
            for match in exp.findAll(text).map(\.groupValues) {
                if match.size == 3,
                   let key = match[1],
                   let value = match[2] {
                    dict[unescape(key)] = unescape(value)
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

    @available(*, unavailable)
    public static func propertyList(_ propertyList: Any, isValidFor: PropertyListSerialization.PropertyListFormat) -> Bool {
        fatalError()
    }

    public enum PropertyListFormat {
        case openStep
        case xml
        case binary
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
