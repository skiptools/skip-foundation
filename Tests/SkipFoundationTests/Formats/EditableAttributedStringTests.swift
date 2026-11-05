// Copyright 2026 Skip
import Foundation
import XCTest

/// The same calls execute against Apple Foundation and the transpiled implementation.
final class EditableAttributedStringTests: XCTestCase {
    func testCaseInsensitiveSearchFindsFirstMatchAndPreservesText() {
        var text = AttributedString("Search highlighting in Skip and SKIP")
        XCTAssertNil(text.range(of: "skip"))
        let range = text.range(of: "skip", options: .caseInsensitive)!
        XCTAssertEqual(String(text[range].characters), "Skip")
        text[range].inlinePresentationIntent = .stronglyEmphasized
        XCTAssertEqual(text.runs.count, 3)
        XCTAssertEqual(String(text.characters), "Search highlighting in Skip and SKIP")
        XCTAssertNil(text[text.range(of: "SKIP")!].inlinePresentationIntent)
        XCTAssertNil(text.range(of: "missing", options: .caseInsensitive))
        XCTAssertNil(text.range(of: "", options: .caseInsensitive))
        XCTAssertNil(AttributedString().range(of: "skip", options: .caseInsensitive))
    }

    func testCaseInsensitiveSearchUsesOriginalUnicodeMatchLength() {
        let composed = AttributedString("👩🏽‍💻 CAFÉ!")
        let first = composed.range(of: "cafe\u{0301}", options: .caseInsensitive)!
        XCTAssertEqual(String(composed[first].characters), "CAFÉ")
        let decomposed = AttributedString("👩🏽‍💻 CAFE\u{0301}!")
        let second = decomposed.range(of: "café", options: .caseInsensitive)!
        XCTAssertEqual(String(decomposed[second].characters), "CAFE\u{0301}")
        XCTAssertNil(composed.range(of: "cafe", options: .caseInsensitive))
    }

    func testCaseInsensitiveSubstringSearchRetainsSourceCoordinates() {
        var text = AttributedString("Skip outside | 👩🏽‍💻 Skip inside | Skip outside")
        let middle = text[text.range(of: "👩🏽‍💻 Skip inside")!]
        let range = middle.range(of: "SKIP", options: .caseInsensitive)!
        text[range].inlinePresentationIntent = .stronglyEmphasized
        XCTAssertEqual(String(text[range].characters), "Skip")
        XCTAssertNil(text[text.range(of: "Skip outside")!].inlinePresentationIntent)
        XCTAssertNil(middle.range(of: "outside", options: .caseInsensitive))
        XCTAssertEqual(String(text.characters), "Skip outside | 👩🏽‍💻 Skip inside | Skip outside")
    }

    func testCaseInsensitiveSearchUsesExplicitLocale() {
        let text = AttributedString("I")
        XCTAssertNil(text.range(of: "ı", options: .caseInsensitive))
        let range = text.range(of: "ı", options: .caseInsensitive, locale: Locale(identifier: "tr_TR"))!
        XCTAssertEqual(String(text[range].characters), "I")
    }

    func testOverlappingEditsPreserveOtherAttributes() {
        var text = AttributedString("one two three")
        let link = URL(string: "https://example.com")!
        text.link = link
        let range = text.range(of: "two")!
        text[range].inlinePresentationIntent = .stronglyEmphasized
        XCTAssertEqual(text.link, link)
        XCTAssertNil(text.inlinePresentationIntent)
        XCTAssertEqual(text[range].link, link)
        XCTAssertEqual(text[range].inlinePresentationIntent, .stronglyEmphasized)
        XCTAssertEqual(text.runs.count, 3)
        text[range].inlinePresentationIntent = nil
        XCTAssertEqual(text.runs.count, 1)
        XCTAssertEqual(text.link, link)
    }

    func testRemovingAnAttributePreservesOverlappingStyles() {
        var text = AttributedString("abcde")
        text[text.range(of: "abcd")!].link = URL(string: "https://example.com")
        text[text.range(of: "cde")!].inlinePresentationIntent = .emphasized
        text[text.range(of: "bcd")!].link = nil
        XCTAssertNotNil(text[text.range(of: "a")!].link)
        XCTAssertNil(text[text.range(of: "bcd")!].link)
        XCTAssertEqual(text[text.range(of: "cde")!].inlinePresentationIntent, .emphasized)
        XCTAssertEqual(String(text.characters), "abcde")
    }

    func testCopyAndDetachedSubstringAreIndependent() {
        let original = AttributedString("hello world")
        var copy = original
        let range = copy.range(of: "world")!
        var substring = copy[range]
        substring.link = URL(string: "https://example.com")
        XCTAssertNil(copy[range].link)
        copy[range] = substring
        XCTAssertNotNil(copy[range].link)
        XCTAssertNil(original[range].link)
        substring.link = nil
        XCTAssertNotNil(copy[range].link)
    }

    func testSubstringIndicesRemainInSourceCoordinates() {
        var text = AttributedString("prefix hello world suffix")
        let middle = text.range(of: "hello world")!
        let substring = text[middle]
        let world = substring.range(of: "world")!
        text[world].link = URL(string: "https://example.com")
        XCTAssertEqual(String(text[world].characters), "world")
        XCTAssertNotNil(text[world].link)
        for run in substring.runs {
            XCTAssertFalse(String(text[run.range].characters).isEmpty)
        }
    }

    func testUnicodeRangesRoundTrip() {
        var text = AttributedString("before 👩🏽‍💻 cafe\u{0301} after")
        let range = text.range(of: "👩🏽‍💻 cafe\u{0301}")!
        text[range].link = URL(string: "https://example.com")
        XCTAssertEqual(String(text[range].characters), "👩🏽‍💻 cafe\u{0301}")
        XCTAssertEqual(text.runs.map { String(text[$0.range].characters) }.joined(), "before 👩🏽‍💻 cafe\u{0301} after")
        XCTAssertEqual(text.runs.count, 3)
    }

    func testEqualityAndHashingIncludeAttributesButNotEditHistory() {
        var first = AttributedString("abcd")
        var second = first
        let url = URL(string: "https://example.com")!
        first.link = url
        XCTAssertNotEqual(first, second)
        second[second.range(of: "ab")!].link = url
        second[second.range(of: "cd")!].link = url
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.hashValue, second.hashValue)
        XCTAssertEqual(Set([first, second]).count, 1)
    }

    func testMarkdownCanBeEditedWithoutLosingInlineStyles() throws {
        var text = try AttributedString(markdown: "  **bold** *italic* [link](https://example.com)  \n\nend", options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        XCTAssertEqual(String(text.characters), "  bold italic link  \n\nend")
        let range = text.range(of: "link")!
        XCTAssertEqual(text[text.range(of: "italic")!].inlinePresentationIntent, .emphasized)
        text[range].link = URL(string: "https://swift.org")
        XCTAssertEqual(text[range].link, URL(string: "https://swift.org"))
        XCTAssertEqual(text[text.range(of: "italic")!].inlinePresentationIntent, .emphasized)
        XCTAssertEqual(text[text.range(of: "bold")!].inlinePresentationIntent, .stronglyEmphasized)
    }

    func testAppendMergesMatchingRunsAndRetainsStyles() {
        var text = AttributedString("one")
        text.link = URL(string: "https://example.com")
        var suffix = AttributedString(" two")
        suffix.link = text.link
        text.append(suffix)
        XCTAssertEqual(text.runs.count, 1)
        text.append(AttributedString(" three"))
        XCTAssertEqual(text.runs.count, 2)
        XCTAssertNil(text.link)
        XCTAssertEqual(String(text.characters), "one two three")
    }

    func testEmptyTextAndMissingRange() {
        var text = AttributedString()
        text.link = URL(string: "https://example.com")
        XCTAssertEqual(text.runs.count, 0)
        XCTAssertNil(text.link)
        XCTAssertNil(text.range(of: "missing"))
        XCTAssertEqual(text.startIndex, text.endIndex)
    }

    func testWritesThroughAnArrayElementPreserveValueSemantics() {
        let original = AttributedString("hello")
        var values = [original]
        let range = values[0].range(of: "hello")!
        values[0][range].link = URL(string: "https://example.com")
        XCTAssertNotNil(values[0].link)
        XCTAssertNil(original.link)
        let detached = values[0]
        values[0][range].link = nil
        XCTAssertNotNil(detached.link)
    }

    func testLocalizedInterpolationIsEditable() {
        let name = "world"
        var text = AttributedString(localized: "**Hello \(name)**")
        XCTAssertEqual(String(text.characters), "Hello world")
        let range = text.range(of: name)!
        XCTAssertEqual(text[range].inlinePresentationIntent, .stronglyEmphasized)
        text[range].link = URL(string: "https://example.com")
        XCTAssertEqual(text[range].inlinePresentationIntent, .stronglyEmphasized)
        XCTAssertNotNil(text[range].link)
    }

    func testLocalizedMarkdownPreservesLiteralPercents() {
        let amount = 50
        let text = AttributedString(localized: "**Save \(amount)%** [100%](https://example.com/a%20b)")
        XCTAssertEqual(String(text.characters), "Save 50% 100%")
        XCTAssertEqual(text[text.range(of: "100%")!].link?.absoluteString, "https://example.com/a%20b")
    }

    func testLocalizedMarkdownPreservesWhitespaceAndHTML() {
        let name = "world"
        let text = AttributedString(localized: "  **Hello \(name)**\n\n  <b>next</b>  ")
        XCTAssertEqual(String(text.characters), "  Hello world\n\n  <b>next</b>  ")
        XCTAssertEqual(text[text.range(of: "Hello world")!].inlinePresentationIntent, .stronglyEmphasized)
    }

    func testLocalizedMarkdownWithoutSubstitutionsPreservesPercents() {
        let text = AttributedString(localized: "**100%** [link](https://example.com/a%20b)")
        XCTAssertEqual(String(text.characters), "100% link")
        XCTAssertEqual(text[text.range(of: "link")!].link?.absoluteString, "https://example.com/a%20b")
        XCTAssertEqual(text[text.range(of: "100%")!].inlinePresentationIntent, .stronglyEmphasized)
    }

    func testMarkdownPreservesWhitespaceFollowingEntities() throws {
        let sources = ["&#9;\t", "a &#32; ", "&#32;  ", "a &#32; \nb", "a\t \nb", "a &#32; **b**"]
        let expected = ["\t\t", "a   ", "   ", "a   \nb", "a\t \nb", "a   b"]
        for index in sources.indices {
            let text = try AttributedString(markdown: sources[index], options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            XCTAssertEqual(String(text.characters), expected[index])
        }
    }

    #if SKIP
    func testLocalizedStringKeyPreservesWhitespaceAndHTML() {
        let key: String = "  **Hello**\n\n  <b>next</b>  "
        let text = AttributedString(localized: key)
        XCTAssertEqual(String(text.characters), "  Hello\n\n  <b>next</b>  ")
    }

    // Preserve Lite's existing behavior: substitutions do not introduce Markdown.
    func testLocalizedSubstitutionDoesNotIntroduceMarkup() {
        let name = "*literal*"
        let text = AttributedString(localized: "**Hello \(name)**")
        XCTAssertEqual(String(text.characters), "Hello *literal*")
        XCTAssertEqual(text.inlinePresentationIntent, .stronglyEmphasized)
    }
    #endif
}
