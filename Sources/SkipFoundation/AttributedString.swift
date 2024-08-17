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
        markdownNode = MarkdownNode(markdown)
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
