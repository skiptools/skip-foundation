// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import org.commonmark.node.Code
import org.commonmark.node.Document
import org.commonmark.node.Emphasis
import org.commonmark.node.HardLineBreak
import org.commonmark.node.Link
import org.commonmark.node.Node
import org.commonmark.node.Paragraph
import org.commonmark.node.SoftLineBreak
import org.commonmark.node.StrongEmphasis
import org.commonmark.node.Text
import org.commonmark.parser.Parser

/// A node in a markdown AST.
public final class MarkdownNode {
    static let parser: Parser = Parser.builder().enabledBlockTypes(emptySet()).build()

    public enum NodeType {
        case bold
        case code
        case italic
        case link
        case paragraph
        case root
        case strikethrough
        case text
        case unknown
    }

    /// Parse the string as markdown.
    ///
    /// - Returns: `nil` for empty or invalid string
    public static func from(string: String?) -> MarkdownNode? {
        guard string?.isEmpty == false else {
            return nil
        }
        do {
            guard let document = Self.parser.parse(string) as? Document else {
                return nil
            }
            guard let body = document.firstChild else {
                return nil
            }
            let node = MarkdownNode(document)
            guard node.hasMarkdown else {
                return nil
            }
            return node
        } catch {
            return nil
        }
    }

    public let type: NodeType
    public var string: String?
    public var children: List<MarkdownNode>?

    private init(_ node: Node) {
        if let text = node as? Text {
            self.type = NodeType.text
            self.string = text.literal
            self.children = nil
        } else if let code = node as? Code {
            self.type = NodeType.code
            self.string = code.literal
        } else if node is Emphasis {
            self.type = NodeType.italic
            self.string = nil
            self.children = Self.processChildren(node)
        } else if node is StrongEmphasis {
            self.type = NodeType.bold
            self.string = nil
            self.children = Self.processChildren(node)
            //        } else if node is Strikethrough {
            //            self.type = NodeType.strikethrough
            //            self.string = nil
            //            self.children = Self.processChildren(node)
        } else if let link = node as? Link {
            self.type = NodeType.link
            self.string = link.destination
            self.children = Self.processChildren(node)
        } else if node is Document {
            self.type = NodeType.root
            self.string = nil
            self.children = Self.processChildren(node)
        } else if node is Paragraph {
            self.type = NodeType.paragraph
            self.string = nil
            self.children = Self.processChildren(node)
        } else if node is HardLineBreak || node is SoftLineBreak {
            self.type = NodeType.text
            self.string = "\n"
            self.children = nil
        } else {
            self.type = NodeType.unknown
            self.string = nil
            self.children = Self.processChildren(node)
        }
    }

    private var hasMarkdown: Bool {
        switch type {
        case .bold, .code, .italic, .link, .strikethrough:
            return true
        default:
            return children?.any { $0.hasMarkdown } == true
        }
    }

    private static func processChildren(_ node: Node) -> List<MarkdownNode>? {
        guard var current = node.firstChild else {
            return nil
        }

        var children: MutableList<MarkdownNode> = mutableListOf()
        while current != nil {
            children.add(MarkdownNode(current))
            current = current.next
        }
        return children
    }
}

#endif
