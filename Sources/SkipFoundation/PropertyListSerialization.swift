// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import class Foundation.PropertyListSerialization
internal typealias PlatformPropertyListSerialization = Foundation.PropertyListSerialization
#endif

public class PropertyListSerialization {
    public enum PropertyListFormat {
        case openStep
        case xml
        case binary
    }

    public static func propertyList(from: Data, format: PropertyListFormat? = nil) throws -> Dictionary<String, String>? {
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
            #if SKIP
            let exp = try kotlin.text.Regex(re, RegexOption.MULTILINE) // https://www.baeldung.com/regular-expressions-java#Pattern
            for match in exp.findAll(text).map(\.groupValues) {
                if match.size == 3,
                   let key = match[1],
                   let value = match[2] {
                    dict[unescape(key)] = unescape(value)
                }
            }
            #else
            let exp = try Regex(re) // Swift.Regex
            for match in line.matches(of: exp) {
                if match.count == 3,
                   let key = match[1].substring,
                   let value = match[2].substring {
                    dict[unescape(key.description)] = unescape(value.description)
                }
            }
            #endif
        }
        return dict
    }
}
