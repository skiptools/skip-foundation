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

/// An object that converts between a property list and one of several serialized representations.
public class PropertyListSerialization {
    public enum PropertyListFormat {
        case openStep
        case xml
        case binary
    }

    /// Creates and returns a property list from the specified data.
    ///
    /// NOTE: this currenly only supports the strings format ("key" = "value"). XML and binary plists are TODO.
    @available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
    public static func propertyList(from: Data, format: PropertyListFormat? = nil) throws -> Dictionary<String, String>? {
        var dict: Dictionary<String, String> = [:]
        let re = "\"(.*)\"[ ]*=[ ]*\"(.*)\";"
        //let re = #"(?<!\\)"(.*?)(?<!\\)"\s*=\s*"(.*?)(?<!\\)";"# // Swift Regex error: "lookbehind is not currently supported"

        let text = from.utf8String

        guard let text = text else {
            // TODO: should this throw an error?
            return nil
        }

        #if SKIP
        let exp: kotlin.text.Regex = re.toRegex()
        let matches = exp.findAll(text)
        for match in matches {
            if match.groupValues.size == 3,
               let key = match.groupValues[1],
               let value = match.groupValues[2] {
                dict[key.replacingOccurrences(of: "\\\\\\\"", with: "\"")] = value.replacingOccurrences(of: "\\\\\\\"", with: "\"")
            }
        }
        #else
        let exp = try Regex(re)

        for line in text.components(separatedBy: "\n") {
            let matches = line.matches(of: exp)
            for match in matches {
                if match.count == 3,
                   let key = match[1].substring,
                   let value = match[2].substring {
                    dict[key.replacingOccurrences(of: "\\\"", with: "\"")] = value.replacingOccurrences(of: "\\\"", with: "\"")
                }
            }
        }
        #endif
        return dict
    }
}
