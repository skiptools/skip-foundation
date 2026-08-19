// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP
public struct AttributedString: Hashable {
    /// An index into an attributed string, measured in UTF-16 code units.
    public struct Index : Hashable, Comparable {
        internal let utf16Offset: Int

        internal init(utf16Offset: Int) {
            self.utf16Offset = utf16Offset
        }

        public static func < (lhs: Index, rhs: Index) -> Bool {
            return lhs.utf16Offset < rhs.utf16Offset
        }
    }

    /// A run of characters sharing the same attributes.
    public struct Run : Hashable {
        public let utf16Range: Range<Int>
        public let attributes: AttributeContainer

        internal init(utf16Range: Range<Int>, attributes: AttributeContainer) {
            self.utf16Range = utf16Range
            self.attributes = attributes
        }
    }

    /// The plain text content.
    public var characters: String

    internal var _runs: [Run]

    /// Plain text for display and compatibility.
    public var string: String {
        return characters
    }

    internal init(characters: String, runs: [Run]) {
        self.characters = characters
        self._runs = runs
    }

    public init() {
        characters = ""
        _runs = []
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(markdown: String) throws {
        if let node = MarkdownNode.from(string: markdown) {
            let built = Self.from(markdown: node)
            characters = built.characters
            _runs = built._runs
        } else {
            characters = markdown
            _runs = Self.singleRun(length: markdown.count, attributes: AttributeContainer())
        }
    }

    public init(localized keyAndValue: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let key = keyAndValue.patternFormat
        let (_, locfmt, locnode) = (bundle ?? Bundle.main).localizedInfo(forKey: key, value: nil, table: table, locale: locale)
        let characters = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
        if let locnode {
            let built = Self.from(markdown: locnode.format(keyAndValue.stringInterpolation.values), interpolations: keyAndValue.stringInterpolation.values)
            self.characters = characters
            _runs = built._runs
        } else {
            self.characters = characters
            _runs = Self.singleRun(length: characters.count, attributes: AttributeContainer())
        }
    }

    public init(localized key: String, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let (locstring, _, locnode) = (bundle ?? Bundle.main).localizedInfo(forKey: key, value: nil, table: table, locale: locale)
        if let locnode {
            let built = Self.from(markdown: locnode)
            characters = locstring
            _runs = built._runs
        } else {
            characters = locstring
            _runs = Self.singleRun(length: locstring.count, attributes: AttributeContainer())
        }
    }

    public var description: String {
        return characters
    }

    public static func ==(lhs: AttributedString, rhs: AttributedString) -> Bool {
        return lhs.characters == rhs.characters && lhs._runs == rhs._runs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(characters)
        hasher.combine(_runs)
    }
}

#endif
