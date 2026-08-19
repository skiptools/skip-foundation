// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

extension AttributedString {
    /// Builds an attributed string from a markdown AST node.
    internal static func from(markdown: MarkdownNode, interpolations: kotlin.collections.List<AnyHashable>? = nil) -> AttributedString {
        var builder = MarkdownRunBuilder()
        appendMarkdown(markdown, to: &builder, interpolations: interpolations, isFirstChild: true)
        return AttributedString(characters: builder.text, runs: builder.runs())
    }

    private static func appendMarkdown(_ markdown: MarkdownNode, to builder: inout MarkdownRunBuilder, interpolations: kotlin.collections.List<AnyHashable>?, isFirstChild: Bool) {
        func appendChildren() {
            markdown.children?.forEachIndexed { appendMarkdown($1, to: &builder, interpolations: interpolations, isFirstChild: $0 == 0) }
        }

        switch markdown.type {
        case MarkdownNode.NodeType.bold:
            builder.pushBold()
            appendChildren()
            builder.pop()
        case MarkdownNode.NodeType.code:
            builder.pushCode()
            if let text = markdown.formattedString(interpolations) {
                builder.append(text)
            }
            builder.pop()
        case MarkdownNode.NodeType.italic:
            builder.pushItalic()
            appendChildren()
            builder.pop()
        case MarkdownNode.NodeType.link:
            if let urlString = markdown.formattedString(interpolations), let url = URL(string: urlString) {
                builder.pushLink(url)
            }
            appendChildren()
            builder.pop()
        case MarkdownNode.NodeType.paragraph:
            if !isFirstChild {
                builder.append("\n\n")
            }
            appendChildren()
        case MarkdownNode.NodeType.root:
            appendChildren()
        case MarkdownNode.NodeType.strikethrough:
            builder.pushStrikethrough()
            appendChildren()
            builder.pop()
        case MarkdownNode.NodeType.text:
            if let text = markdown.formattedString(interpolations) {
                builder.append(text)
            }
        case MarkdownNode.NodeType.unknown:
            appendChildren()
        }
    }
}

/// Walks markdown and produces runs with varying attributes per text segment.
struct MarkdownRunBuilder {
    private var attributeStack: [AttributeContainer] = [AttributeContainer()]
    private var segments: [(String, AttributeContainer)] = []

    mutating func pushBold() {
        push { $0.markdownBold = true }
    }

    mutating func pushItalic() {
        push { $0.markdownItalic = true }
    }

    mutating func pushStrikethrough() {
        push { $0.markdownStrikethrough = true }
    }

    mutating func pushCode() {
        push { $0.markdownCode = true }
    }

    mutating func pushLink(_ url: URL) {
        push { $0.link = url }
    }

    private mutating func push(_ update: (inout AttributeContainer) -> Void) {
        var container = attributeStack.last ?? AttributeContainer()
        update(&container)
        attributeStack.append(container)
    }

    mutating func pop() {
        if attributeStack.count > 1 {
            attributeStack.removeLast()
        }
    }

    mutating func append(_ string: String) {
        guard !string.isEmpty else { return }
        segments.append((string, attributeStack.last ?? AttributeContainer()))
    }

    var text: String {
        return segments.map { $0.0 }.joined()
    }

    func runs() -> [AttributedString.Run] {
        var result: [AttributedString.Run] = []
        var offset = 0
        for (segment, attributes) in segments {
            let length = segment.count
            if length > 0 {
                result.append(AttributedString.Run(
                    utf16Range: offset..<(offset + length),
                    attributes: attributes
                ))
                offset += length
            }
        }
        return AttributedString.coalesce(result)
    }
}

#endif
