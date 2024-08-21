// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import org.commonmark.ext.gfm.strikethrough.Strikethrough
import org.commonmark.ext.gfm.strikethrough.StrikethroughExtension
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
    static let parser: Parser = Parser.builder()
        .enabledBlockTypes(emptySet())
        .extensions(listOf(StrikethroughExtension.create()))
        .build()

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

        static let markdownCharacters: Set<Character> = ["*", "_", "`", "[", "~"]

        static func hasMarkdown(_ node: Node?) -> Bool {
            guard let node else {
                return false
            }
            if node is StrongEmphasis || node is Code || node is Emphasis || node is Link || node is Strikethrough {
                return true
            }
            var child = node.firstChild
            while child != nil {
                if hasMarkdown(child) {
                    return true
                }
                child = child?.next
            }
            return false
        }
    }

    /// Parse the string as markdown.
    ///
    /// - Returns: `nil` for empty or invalid string
    public static func from(string: String?) -> MarkdownNode? {
        guard let string, !string.isEmpty() else {
            return nil
        }
        // Don't spend time parsing and gathering string interpolation info if definitely not markdown
        guard string.contains(where: { NodeType.markdownCharacters.contains($0) }) else {
            return nil
        }
        do {
            guard let document = Self.parser.parse(string) as? Document, NodeType.hasMarkdown(document) else {
                return nil
            }
            return MarkdownNode(document)
        } catch {
            return nil
        }
    }

    public let type: NodeType
    /// The string is converted to use Kotlin/Java-style format specifiers.
    public let string: String?
    public let interpolationIndexes: List<Int>?
    public let children: List<MarkdownNode>?

    public func format(_ interpolations: List<AnyHashable>?) -> MarkdownNode {
        guard let interpolations, !interpolations.isEmpty() else {
            return self
        }
        let string = formattedString(interpolations)
        return MarkdownNode(type: type, string: string, interpolationIndexes: nil, children: children?.map { $0.format(interpolations) })
    }

    public func formattedString(_ interpolations: List<AnyHashable>?) -> String? {
        guard let string, let interpolationIndexes, let interpolations else {
            return self.string
        }
        let stringInterpolations = mutableListOf<AnyHashable>()
        for index in interpolationIndexes {
            if interpolations.count() >= index {
                stringInterpolations.add(interpolations[index - 1])
            }
        }
        return string.format(*stringInterpolations.toTypedArray())
    }

    private init(type: NodeType, string: String?, interpolationIndexes: List<Int>?, children: List<MarkdownNode>?) {
        self.type = type
        self.string = string
        self.interpolationIndexes = interpolationIndexes
        self.children = children
    }

    private init(_ node: Node, interpolationInfo: InterpolationInfo = InterpolationInfo()) {
        if let text = node as? Text {
            self.type = NodeType.text
            let (string, indexes) = text.literal.kotlinFormatInfo(interpolationIndex: interpolationInfo.index, removePositions: true)
            interpolationInfo.update(for: indexes)
            self.string = string
            self.interpolationIndexes = indexes
            self.children = nil
        } else if let code = node as? Code {
            self.type = NodeType.code
            let (string, indexes) = code.literal.kotlinFormatInfo(interpolationIndex: interpolationInfo.index, removePositions: true)
            interpolationInfo.update(for: indexes)
            self.string = string
            self.interpolationIndexes = indexes
            self.children = nil
        } else if node is Emphasis {
            self.type = NodeType.italic
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        } else if node is StrongEmphasis {
            self.type = NodeType.bold
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        } else if node is Strikethrough {
            self.type = NodeType.strikethrough
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        } else if let link = node as? Link {
            self.type = NodeType.link
            // Process children before destination because they appear first in the link markdown
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
            let (string, indexes) = link.destination.kotlinFormatInfo(interpolationIndex: interpolationInfo.index, removePositions: true)
            interpolationInfo.update(for: indexes)
            self.string = string
            self.interpolationIndexes = indexes
        } else if node is Document {
            self.type = NodeType.root
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        } else if node is Paragraph {
            self.type = NodeType.paragraph
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        } else if node is HardLineBreak || node is SoftLineBreak {
            self.type = NodeType.text
            self.string = "\n"
            self.interpolationIndexes = nil
            self.children = nil
        } else {
            self.type = NodeType.unknown
            self.string = nil
            self.interpolationIndexes = nil
            self.children = Self.processChildren(node, interpolationInfo: interpolationInfo)
        }
    }

    private static func processChildren(_ node: Node, interpolationInfo: InterpolationInfo) -> List<MarkdownNode>? {
        guard var current = node.firstChild else {
            return nil
        }

        var children: MutableList<MarkdownNode> = mutableListOf()
        while current != nil {
            children.add(MarkdownNode(current, interpolationInfo: interpolationInfo))
            current = current.next
        }
        return children
    }

    private final class InterpolationInfo {
        var index = 0

        func update(for indexes: List<Int>?) {
            if let indexes {
                index = max(index, indexes.maxOrNull() ?? 0)
            }
        }
    }
}

#endif
