// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import Foundation
import XCTest

final class TestMarkdown: XCTestCase {
    func testNoMarkdown() {
        XCTAssertNil(MarkdownNode.from(string: ""))
        XCTAssertNil(MarkdownNode.from(string: "This is some plain text"))
        XCTAssertNil(MarkdownNode.from(string: "This is some plain text\n\n- with block\n\n-elements"))
    }

    func testInlineFormatting() {
        XCTAssertEqual(stringify(MarkdownNode.from(string: "**This is some bold text**")), "<b>This is some bold text</b>")
        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is some **bold** text")), "This is some <b>bold</b> text")
        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is some ***bold italic*** text")), "This is some <i><b>bold italic</b></i> text")
//        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is some ~~strikethrough~~ text")), "This is some <s>strikethrough</s> text")
//        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is some ~~strikethrough *italic*~~ text")), "This is some <s>strikethrough <i>italic</i></s> text")
        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is some `code` text")), "This is some <c>code</c> text")
    }

    func testLinebreaks() {
        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is **some** text\nwith line\n\nbreaks")), "This is <b>some</b> text\nwith line\n\nbreaks")
    }

    func testLink() {
        XCTAssertEqual(stringify(MarkdownNode.from(string: "This is [link 1](http://link1.com) and [*link 2*](http://link2.com)")), "This is <a href=http://link1.com>link 1</a> and <a href=http://link2.com><i>link 2</i></a>")
    }

    private func stringify(_ node: MarkdownNode?, isFirstChild: Bool = true) -> String {
        guard let node else {
            return ""
        }
        switch node.type {
        case .bold:
            return "<b>" + stringify(node.children) + "</b>"
        case .code:
            return "<c>" + (node.string ?? "") + "</c>"
        case .italic:
            return "<i>" + stringify(node.children) + "</i>"
        case .link:
            return "<a href=\(node.string)>" + stringify(node.children) + "</a>"
        case .paragraph:
            return (isFirstChild ? "" : "\n\n") + stringify(node.children)
        case .strikethrough:
            return "<s>" + stringify(node.children) + "</s>"
        case .root:
            return stringify(node.children)
        case .text:
            return node.string ?? ""
        case .unknown:
            return "<?>" + stringify(node.children) + "</?>"
        }
    }

    private func stringify(_ nodes: List<MarkdownNode>?) -> String {
        guard let nodes else {
            return ""
        }
        var string = ""
        for i in 0..<nodes.count() {
            string += stringify(nodes[i], isFirstChild: i == 0)
        }
        return string
    }
}
#endif
