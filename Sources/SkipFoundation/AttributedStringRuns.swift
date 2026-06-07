// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

extension AttributedString {
    public var entireUTF16Range: Range<Int> {
        return 0..<_utf16Length
    }

    /// Attribute runs in the attributed string.
    public var runs: [Run] {
        return _runs
    }

    public var startIndex: Index {
        return Index(utf16Offset: 0)
    }

    public var endIndex: Index {
        return Index(utf16Offset: _utf16Length)
    }

    internal var _utf16Length: Int {
        return characters.count
    }

    public func substring(in range: Range<Int>) -> String {
        return String(characters[range.lowerBound..<range.upperBound])
    }

    internal func index(at utf16Offset: Int) -> Index {
        return Index(utf16Offset: utf16Offset)
    }

    internal static func coalesce(_ runs: [Run]) -> [Run] {
        guard !runs.isEmpty else { return [] }
        var result: [Run] = []
        for run in runs {
            if let last = result.last, last.attributes == run.attributes, last.utf16Range.upperBound == run.utf16Range.lowerBound {
                result[result.count - 1] = Run(utf16Range: last.utf16Range.lowerBound..<run.utf16Range.upperBound, attributes: last.attributes)
            } else {
                result.append(run)
            }
        }
        return result
    }

    internal static func singleRun(length: Int, attributes: AttributeContainer) -> [Run] {
        guard length > 0 else { return [] }
        return [Run(utf16Range: 0..<length, attributes: attributes)]
    }
}

#endif
