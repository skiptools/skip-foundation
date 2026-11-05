// Copyright 2026 Skip
package skip.foundation

import org.commonmark.ext.gfm.strikethrough.Strikethrough
import org.commonmark.ext.gfm.strikethrough.StrikethroughExtension
import org.commonmark.node.*
import org.commonmark.node.Text as MarkdownText
import org.commonmark.node.Link as MarkdownLink
import org.commonmark.parser.*
import org.commonmark.parser.block.*

/**
 * Uses the same CommonMark engine and strikethrough extension as SkipFoundation.
 * An inline-only input must bypass paragraph splitting and whitespace trimming.
 * The public block extension supplies normalized input to CommonMark's inline
 * parser as one source line, including its embedded newlines and source positions.
 */
internal object AttributedMarkdown {
    fun runs(source: String): skip.lib.Array<AttributedMarkdownRun> {
        val result = mutableListOf<AttributedMarkdownRun>()
        append(parse(source), result)
        return skip.lib.Array(result)
    }

    /** Parse inline Markdown, retaining whitespace and literal HTML for both callers. */
    fun parse(source: String): Node {
        // Direct inline parsing bypasses CommonMark's input normalization. Keep
        // parsing and source-span lookups on the same normalized string.
        val normalizedSource = source.replace('\u0000', '\uFFFD')
            .replace("\r\n", "\n")
            .replace('\r', '\n')
        val parser = Parser.builder()
            .enabledBlockTypes(emptySet())
            .extensions(listOf(StrikethroughExtension.create()))
            .customBlockParserFactory { _, _ ->
                BlockStart.of(InputBlock(normalizedSource)).atIndex(0)
            }
            .build()
        // A punctuation character invokes the custom block factory. The block's
        // parseInlines method replaces this trigger with the actual source.
        val document = parser.parse("#")
        preserveText(document, normalizedSource)
        return document
    }

    private class InputBlock(private val source: String) : AbstractBlockParser() {
        private val paragraph = Paragraph()
        override fun getBlock(): Block = paragraph
        override fun tryContinue(state: ParserState): BlockContinue = BlockContinue.none()
        override fun parseInlines(parser: InlineParser) {
            parser.parse(SourceLines.of(SourceLine.of(source, SourceSpan.of(0, 0, 0, source.length))), paragraph)
        }
    }

    // Restore only whitespace that CommonMark trims at a line/input boundary.
    // Decoded entities may also end in whitespace, so literal suffix lengths
    // cannot tell us how much source whitespace was retained.
    private fun preserveText(node: Node, source: String) {
        if (node is MarkdownText) {
            val span = node.sourceSpans.lastOrNull()
            if (span != null) {
                val end = span.inputIndex + span.length
                val raw = source.substring(span.inputIndex, end)
                val trimmed = when {
                    end == source.length -> raw.takeLastWhile { it == ' ' || it == '\t' }
                    source[end] == '\n' -> raw.takeLastWhile { it == ' ' }
                    else -> ""
                }
                node.literal += trimmed
            }
        } else if (node is HtmlInline) {
            // MarkdownNode consumes Text nodes; inline HTML remains literal text.
            node.insertBefore(MarkdownText(node.literal))
            node.unlink()
        }
        var child = node.firstChild
        while (child != null) {
            val next = child.next
            preserveText(child, source)
            child = next
        }
    }

    private fun append(
        node: Node, result: MutableList<AttributedMarkdownRun>,
        bold: Boolean = false, italic: Boolean = false, code: Boolean = false,
        strike: Boolean = false, link: String? = null
    ) {
        val nextBold = bold || node is StrongEmphasis
        val nextItalic = italic || node is Emphasis
        val nextCode = code || node is Code
        val nextStrike = strike || node is Strikethrough
        val nextLink = (node as? MarkdownLink)?.destination ?: link
        val text = when (node) {
            is MarkdownText -> node.literal
            is Code -> node.literal
            is HtmlInline -> node.literal
            is SoftLineBreak, is HardLineBreak -> "\n"
            else -> null
        }
        if (text != null) {
            if (text.isNotEmpty()) {
                result.add(AttributedMarkdownRun(text, nextBold, nextItalic, nextCode, nextStrike, nextLink))
            }
        } else {
            var child = node.firstChild
            while (child != null) {
                append(child, result, nextBold, nextItalic, nextCode, nextStrike, nextLink)
                child = child.next
            }
        }
    }
}
