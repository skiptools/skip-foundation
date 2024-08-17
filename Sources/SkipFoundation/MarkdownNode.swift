// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import org.commonmark.node.Node
import org.commonmark.parser.Parser

/// A node in a markdown AST.
public class MarkdownNode {
    static let parser = Parser.builder().build()

    /// Parse the string as markdown.
    ///
    /// - Returns: `nil` for empty or invalid string
    public static func from(string: String?) -> MarkdownNode? {
        guard string?.isEmpty == false else {
            return nil
        }
        do {
            let cnode = Self.parser.parse(string)

        } catch {
            return nil
        }
    }

    public enum Type {
        case root
    }

    public let type: Type
    public var string: String?
    public var children: [MarkdownNode]?

    private init(type: Type, string: String? = nil, children: [MarkdownNode]? = nil) {
        self.type = type
        self.string = string
        self.children = children
    }
}

#endif
