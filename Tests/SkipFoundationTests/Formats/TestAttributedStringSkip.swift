// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
import Foundation
import XCTest

#if SKIP

final class TestAttributedStringSkip: XCTestCase {
    func testEmpty() {
        let str = AttributedString()
        XCTAssertEqual(str.characters, "")
        XCTAssertEqual(str.runs.first, nil)
    }

    func testInitWithAttributes() {
        var container = AttributeContainer()
        container.link = URL(string: "https://example.com")
        let str = AttributedString("Hello", attributes: container)
        XCTAssertEqual(str.characters, "Hello")
        XCTAssertEqual(str.link, URL(string: "https://example.com"))
    }

    func testAppendAndPlus() {
        var a = AttributedString("Hello")
        a.append(AttributedString(" World"))
        XCTAssertEqual(a.characters, "Hello World")
        let b = AttributedString("!") + a
        XCTAssertEqual(b.characters, "!Hello World")
    }

    func testWholeStringLinkOnMarkdown() throws {
        var str = try AttributedString(markdown: "**Bold** and plain")
        str.link = URL(string: "https://example.com")
        for run in str.runs {
            XCTAssertEqual(run.attributes.link, URL(string: "https://example.com"))
        }
    }

    func testMarkdownInit() throws {
        let str = try AttributedString(markdown: "**Bold** and *italic*")
        XCTAssertEqual(str.characters, "Bold and italic")
        var hasBold = false
        for run in str.runs {
            if run.attributes.markdownBold {
                hasBold = true
            }
        }
        XCTAssertTrue(hasBold)
    }
}

#endif
