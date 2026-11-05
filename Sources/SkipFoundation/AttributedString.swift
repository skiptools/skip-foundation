// Copyright 2023–2026 Skip
#if SKIP
/// Text with value-semantic, editable attribute runs. Indices use the same UTF-16
/// offsets as Skip's String indices; obtain them from this value's ranges.
public struct AttributedString: Hashable {
    /// A UTF-16 position in the attributed text.
    public typealias Index = Int
    private var segments: [AttributedStringSegment] = []

    /// The unformatted characters, without Markdown delimiters.
    public var string: String { segments.map { $0.text }.joined() }
    /// Compatibility with existing Markdown consumers. Edits invalidate this tree;
    /// renderers should use `runs` to read the current attributes instead.
    public private(set) var markdownNode: MarkdownNode? = nil
    /// The characters in this value, represented by Skip's String implementation.
    public var characters: String { string }
    /// The first character position.
    public var startIndex: Index { 0 }
    /// The position immediately after the last character.
    public var endIndex: Index { string.count }

    /// Create an empty value.
    public init() {}

    /// Create literal text with optional attributes applied to every character.
    public init(_ string: String, attributes: AttributeContainer = AttributeContainer()) {
        if !string.isEmpty { segments = [AttributedStringSegment(text: string, attributes: attributes)] }
    }

    /// Create literal text without Markdown parsing.
    public init(stringLiteral: String) {
        self.init(stringLiteral, attributes: AttributeContainer())
    }

    /// Copy a substring into a new value with indices starting at zero.
    public init(_ substring: AttributedSubstring) {
        self = substring.value
    }

    /// Parse editable inline Markdown. Block formatting is not supported.
    public init(markdown: String, options: MarkdownParsingOptions = MarkdownParsingOptions()) throws {
        for run in AttributedMarkdown.runs(source: markdown) {
            var attributes = AttributeContainer()
            var intent: InlinePresentationIntent = []
            if run.bold { intent.insert(.stronglyEmphasized) }
            if run.italic { intent.insert(.emphasized) }
            if run.code { intent.insert(.code) }
            if run.strikethrough { intent.insert(.strikethrough) }
            if !intent.isEmpty { attributes.inlinePresentationIntent = intent }
            if let link = run.link { attributes.link = URL(string: link) }
            segments.append(AttributedStringSegment(text: run.text, attributes: attributes))
        }
        coalesce()
        markdownNode = MarkdownNode.from(string: markdown)
    }

    /// Create editable localized text, preserving literal interpolation values.
    public init(localized keyAndValue: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let (locstring, locfmt, _) = (bundle ?? Bundle.main).localizedInfo(forKey: keyAndValue.patternFormat, value: nil, table: table, locale: locale)
        let node = MarkdownNode.fromInline(string: locstring)?.format(keyAndValue.stringInterpolation.values)
        if let node {
            appendMarkdown(node, attributes: AttributeContainer())
            coalesce()
        } else {
            let text = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
            if !text.isEmpty { segments = [AttributedStringSegment(text: text, attributes: AttributeContainer())] }
        }
        markdownNode = node
    }

    /// Create editable localized text, preserving literal interpolation values.
    public init(localized key: String, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) {
        let (locstring, _, _) = (bundle ?? Bundle.main).localizedInfo(forKey: key, value: nil, table: table, locale: locale)
        let locnode = MarkdownNode.fromInline(string: locstring)
        if let locnode {
            appendMarkdown(locnode, attributes: AttributeContainer())
            coalesce()
        } else {
            if !locstring.isEmpty { segments = [AttributedStringSegment(text: locstring, attributes: AttributeContainer())] }
        }
        markdownNode = locnode
    }

    /// Find the first occurrence using Skip String's UTF-16 index convention.
    /// Case-insensitive searches use Android ICU, preserving accents and original
    /// match lengths. A nil locale uses ICU's root locale. Other options are unsupported.
    public func range(of text: String, options: String.CompareOptions = [], locale: Locale? = nil) -> AttributedStringRange? {
        precondition(options.rawValue & ~String.CompareOptions.caseInsensitive.rawValue == UInt(0), "Unsupported attributed-string search options")
        let source = string
        guard !text.isEmpty && !source.isEmpty else { return nil }
        if options.isEmpty && locale == nil {
            let offset = source.indexOf(text)
            return offset < 0 ? nil : AttributedStringRange(lowerBound: offset, upperBound: offset + text.count)
        }
        let collator = android.icu.text.Collator.getInstance(locale?.platformValue ?? java.util.Locale.ROOT) as! android.icu.text.RuleBasedCollator
        collator.setStrength(options.contains(.caseInsensitive) ? android.icu.text.Collator.SECONDARY : android.icu.text.Collator.TERTIARY)
        collator.setDecomposition(android.icu.text.Collator.CANONICAL_DECOMPOSITION)
        let search = android.icu.text.StringSearch(text, java.text.StringCharacterIterator(source), collator)
        let offset = search.first()
        guard offset != android.icu.text.SearchIterator.DONE else { return nil }
        // ICU reports the length in the original text, which may differ from the query.
        return AttributedStringRange(lowerBound: offset, upperBound: offset + search.getMatchLength())
    }

    /// Read or replace an attributed range. Mutating an attribute on the returned
    /// substring writes that change back through this setter.
    public subscript(_ bounds: AttributedStringRange) -> AttributedSubstring {
        get {
            let substring = AttributedSubstring(value: slice(bounds.lowerBound..<bounds.upperBound), startIndex: bounds.lowerBound)
            // Match SkipLib's mutable collection elements: direct mutation writes
            // back, while storing the result separately detaches it via sref().
            // SKIP REPLACE: return substring.sref({ this[bounds] = it })
            return substring
        }
        set {
            let prefix = slice(startIndex..<bounds.lowerBound)
            let suffix = slice(bounds.upperBound..<endIndex)
            segments = prefix.segments + newValue.value.segments + suffix.segments
            markdownNode = nil
            coalesce()
        }
    }

    /// Enumerate maximal ranges with identical attributes.
    public var runs: [Run] {
        var offset = 0
        return segments.map { segment in
            let start = offset
            offset += segment.text.count
            return Run(range: AttributedStringRange(lowerBound: start, upperBound: offset), attributes: segment.attributes)
        }
    }

    /// Append text while preserving each segment's attributes.
    public mutating func append(_ other: AttributedString) {
        segments += other.segments
        markdownNode = nil
        coalesce()
    }

    /// Return an attribute only when its value agrees across the entire text.
    /// This named access lets UI libraries provide typed properties without a
    /// dependency from Foundation to those libraries.
    public func attribute(named name: String) -> AnyHashable? {
        guard let first = segments.first else { return nil }
        let value = first.attributes.attribute(named: name)
        return segments.allSatisfy { $0.attributes.attribute(named: name) == value } ? value : nil
    }

    /// Set or remove one attribute, preserving every other attribute.
    public mutating func setAttribute(named name: String, value: AnyHashable?) {
        segments = segments.map { segment in
            var attributes = segment.attributes
            attributes.setAttribute(named: name, value: value)
            return AttributedStringSegment(text: segment.text, attributes: attributes)
        }
        markdownNode = nil
        coalesce()
    }

    /// The link destination, or nil when absent or different across the text.
    public var link: URL? {
        get { attribute(named: "NSLink") as? URL }
        set { setAttribute(named: "NSLink", value: newValue) }
    }

    /// The inline styles, or nil when absent or different across the text.
    public var inlinePresentationIntent: InlinePresentationIntent? {
        get { attribute(named: "NSInlinePresentationIntent") as? InlinePresentationIntent }
        set { setAttribute(named: "NSInlinePresentationIntent", value: newValue) }
    }

    /// The plain text without attribute information.
    public var description: String { string }

    /// Compare text and attributes independently of their storage or source indices.
    public static func ==(lhs: AttributedString, rhs: AttributedString) -> Bool {
        lhs.segments == rhs.segments
    }

    /// Hash the values used for equality.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(segments)
    }

    /// Produce a detached, zero-based slice. Range writes use it to retain the
    /// unaffected prefix and suffix, including their existing attributes.
    private func slice(_ bounds: Range<Int>) -> AttributedString {
        precondition(bounds.lowerBound >= startIndex && bounds.upperBound <= endIndex)
        var result = AttributedString()
        var offset = 0
        for segment in segments {
            let end = offset + segment.text.count
            let lower = max(bounds.lowerBound, offset)
            let upper = min(bounds.upperBound, end)
            if lower < upper {
                result.segments.append(AttributedStringSegment(text: segment.text.substring(lower - offset, upper - offset), attributes: segment.attributes))
            }
            offset = end
        }
        return result
    }

    /// Keep segmentation independent of the sequence of edits, so equality and
    /// hashing compare content rather than edit history.
    private mutating func coalesce() {
        var result: [AttributedStringSegment] = []
        for segment in segments {
            if segment.text.isEmpty { continue }
            if let last = result.last, last.attributes == segment.attributes {
                result[result.count - 1] = AttributedStringSegment(text: last.text + segment.text, attributes: last.attributes)
            } else {
                result.append(segment)
            }
        }
        segments = result
    }

    /// Flatten a localized Markdown tree after interpolation. Substituted text is
    /// already literal and must not be parsed a second time as Markdown.
    private mutating func appendMarkdown(_ node: MarkdownNode, attributes: AttributeContainer) {
        var attributes = attributes
        var intent: InlinePresentationIntent = attributes.inlinePresentationIntent ?? []
        switch node.type {
        case .bold: intent.insert(.stronglyEmphasized)
        case .italic: intent.insert(.emphasized)
        case .code: intent.insert(.code)
        case .strikethrough: intent.insert(.strikethrough)
        case .link: attributes.link = node.string.flatMap { URL(string: $0) }
        default: break
        }
        if !intent.isEmpty { attributes.inlinePresentationIntent = intent }
        if node.type == .text || node.type == .code, let text = node.string {
            segments.append(AttributedStringSegment(text: text, attributes: attributes))
        }
        if let children = node.children {
            for child in children { appendMarkdown(child, attributes: attributes) }
        }
    }

    /// A maximal range of characters sharing the same attributes.
    public struct Run {
        /// The range of this run in its containing text.
        public let range: AttributedStringRange
        /// The attributes shared by every character in the run.
        public let attributes: AttributeContainer
        /// The link destination shared by this run, or nil when absent.
        public var link: URL? { attributes.link }
        /// The inline styles shared by this run, or nil when absent.
        public var inlinePresentationIntent: InlinePresentationIntent? { attributes.inlinePresentationIntent }
    }

    /// Inline-only Markdown options supported by Skip Lite.
    public struct MarkdownParsingOptions {
        /// Markdown interpretation modes supported by Lite.
        public enum InterpretedSyntax {
            /// Parse inline formatting and preserve whitespace and line breaks.
            case inlineOnlyPreservingWhitespace
        }
        /// The selected interpretation mode.
        public var interpretedSyntax: InterpretedSyntax
        /// Select the supported inline Markdown syntax.
        public init(interpretedSyntax: InterpretedSyntax = .inlineOnlyPreservingWhitespace) {
            self.interpretedSyntax = interpretedSyntax
        }
    }
}

/// A detached value whose indices retain their positions in the source string.
/// Assignment through `text[range]` writes attribute edits back to the source.
public struct AttributedSubstring: Hashable {
    fileprivate var value: AttributedString
    /// The substring start, in the source string's coordinates.
    public let startIndex: AttributedString.Index
    /// The position after the last character, in the source string's coordinates.
    public var endIndex: AttributedString.Index { startIndex + value.endIndex }
    /// A read-only view of the substring's characters.
    public var characters: String { value.characters }
    /// Attribute runs whose ranges retain their source coordinates.
    public var runs: [AttributedString.Run] {
        value.runs.map { AttributedString.Run(range: AttributedStringRange(lowerBound: $0.range.lowerBound + startIndex, upperBound: $0.range.upperBound + startIndex), attributes: $0.attributes) }
    }

    /// Search within this substring and return a range in the source coordinates.
    /// Supports the same options and locale as `AttributedString.range(of:options:locale:)`.
    public func range(of text: String, options: String.CompareOptions = [], locale: Locale? = nil) -> AttributedStringRange? {
        guard let range = value.range(of: text, options: options, locale: locale) else { return nil }
        return AttributedStringRange(lowerBound: range.lowerBound + startIndex, upperBound: range.upperBound + startIndex)
    }

    /// Read a nested substring using source coordinates.
    public subscript(_ bounds: AttributedStringRange) -> AttributedSubstring {
        get {
            let result = value[AttributedStringRange(lowerBound: bounds.lowerBound - startIndex, upperBound: bounds.upperBound - startIndex)]
            return AttributedSubstring(value: result.value, startIndex: bounds.lowerBound)
        }
    }

    /// Read a named attribute; text returns nil when its runs disagree.
    public func attribute(named name: String) -> AnyHashable? { value.attribute(named: name) }
    /// Set or remove one named attribute, preserving all other attributes.
    public mutating func setAttribute(named name: String, value: AnyHashable?) { self.value.setAttribute(named: name, value: value) }
    /// The link destination, or nil when absent or different across the text.
    public var link: URL? {
        get { value.link }
        set { value.link = newValue }
    }
    /// The inline styles, or nil when absent or different across the text.
    public var inlinePresentationIntent: InlinePresentationIntent? {
        get { value.inlinePresentationIntent }
        set { value.inlinePresentationIntent = newValue }
    }
    /// Compare text and attributes independently of their storage or source indices.
    public static func ==(lhs: AttributedSubstring, rhs: AttributedSubstring) -> Bool { lhs.value == rhs.value }
    /// Hash the values used for equality.
    public func hash(into hasher: inout Hasher) { hasher.combine(value) }
}

/// Attribute values shared by text and UI libraries. Typed properties are supplied
/// by the library that owns the attribute; arbitrary dynamic attribute scopes are
/// not currently supported in transpiled code.
public struct AttributeContainer: Hashable {
    private var values: [String: AnyHashable] = [:]
    /// Create an empty value.
    public init() {}
    /// Read a named attribute, or nil when it is absent.
    public func attribute(named name: String) -> AnyHashable? { values[name] }
    /// Set or remove one named attribute, preserving all other attributes.
    public mutating func setAttribute(named name: String, value: AnyHashable?) { values[name] = value }
    /// The stored link destination, or nil when absent.
    public var link: URL? {
        get { attribute(named: "NSLink") as? URL }
        set { setAttribute(named: "NSLink", value: newValue) }
    }
    /// The stored inline styles, or nil when absent.
    public var inlinePresentationIntent: InlinePresentationIntent? {
        get { attribute(named: "NSInlinePresentationIntent") as? InlinePresentationIntent }
        set { setAttribute(named: "NSInlinePresentationIntent", value: newValue) }
    }
    /// Compare attribute names and values independently of insertion order.
    public static func ==(lhs: AttributeContainer, rhs: AttributeContainer) -> Bool { lhs.values == rhs.values }
    /// Hash the values used for equality.
    public func hash(into hasher: inout Hasher) {
        for key in values.keys.sorted() {
            hasher.combine(key)
            hasher.combine(values[key])
        }
    }
}

/// Inline styles carried by Markdown and editable attributed text.
public struct InlinePresentationIntent: OptionSet, Hashable {
    /// The bitmask of inline styles.
    public let rawValue: UInt
    /// Create a set of inline presentation intents from its bitmask.
    public init(rawValue: UInt) { self.rawValue = rawValue }
    /// Italic emphasis.
    public static let emphasized = Self(rawValue: UInt(1) << 0)
    /// Strong emphasis, normally rendered in bold.
    public static let stronglyEmphasized = Self(rawValue: UInt(1) << 1)
    /// Inline monospaced code.
    public static let code = Self(rawValue: UInt(1) << 2)
    /// Strikethrough text.
    public static let strikethrough = Self(rawValue: UInt(1) << 5)
}

/// An attributed range returned by `range(of:)` or run enumeration. It is a
/// concrete type in Lite because generic collection slices are not writable in
/// the transpiler. Keep ranges inferred to share call sites with Foundation.
public struct AttributedStringRange: Hashable {
    /// The inclusive start in UTF-16 code units.
    public let lowerBound: Int
    /// The exclusive end in UTF-16 code units.
    public let upperBound: Int
}

/// Internal storage uses text segments so edits cannot mix source offsets with
/// offsets in the rendered text after Markdown delimiters have been removed.
private struct AttributedStringSegment: Hashable {
    let text: String
    let attributes: AttributeContainer
}

/// The CommonMark parser's output before attribute values are assembled.
internal struct AttributedMarkdownRun {
    let text: String
    let bold: Bool
    let italic: Bool
    let code: Bool
    let strikethrough: Bool
    let link: String?
}
#endif
