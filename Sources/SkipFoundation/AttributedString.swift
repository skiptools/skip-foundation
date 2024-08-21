// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
public struct AttributedString: Hashable {
    // Allow e.g. SwiftUI to access our state
    public let string: String
    public let markdownNode: MarkdownNode?

    public init() {
        string = ""
        markdownNode = nil
    }

    public init(stringLiteral: String) {
        string = stringLiteral
        markdownNode = nil
    }

    public init(markdown: String) throws {
        string = markdown
        markdownNode = MarkdownNode.from(string: markdown)
    }

    public init(localized keyAndValue: String.LocalizationValue, /* options: AttributedString.FormattingOptions = [], */ table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let key = keyAndValue.patternFormat // interpolated string: "Hello \(name)" keyed as: "Hello %@"
        let (_, locfmt, locnode) = bundle?.localizedInfo(forKey: key, value: nil, table: table) ?? Triple("", key.kotlinFormatString, MarkdownNode.from(string: key))
        // re-interpret the placeholder strings in the resulting localized string with the string interpolation's values
        self.string = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
        self.markdownNode = locnode?.format(keyAndValue.stringInterpolation.values)
    }

    public init(localized key: String, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let (locstring, _, locnode) = bundle?.localizedInfo(forKey: key, value: nil, table: table) ?? Triple(key, "", MarkdownNode.from(string: key))
        self.string = locstring
        self.markdownNode = locnode
    }

    public var description: String {
        return string
    }

    public static func ==(lhs: AttributedString, rhs: AttributedString) {
        return lhs.string == rhs.string
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }
}

#endif
