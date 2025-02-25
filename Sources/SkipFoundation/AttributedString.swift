// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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
        let (_, locfmt, locnode) = (bundle ?? Bundle.main).localizedInfo(forKey: key, value: nil, table: table, locale: locale)
        // re-interpret the placeholder strings in the resulting localized string with the string interpolation's values
        self.string = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
        self.markdownNode = locnode?.format(keyAndValue.stringInterpolation.values)
    }

    public init(localized key: String, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let (locstring, _, locnode) = (bundle ?? Bundle.main).localizedInfo(forKey: key, value: nil, table: table, locale: locale)
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
