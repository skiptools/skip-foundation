// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if SKIP

extension AttributedString {
    public init(_ string: String) {
        self.init(characters: string, runs: Self.singleRun(length: string.count, attributes: AttributeContainer()))
    }

    public init(_ string: String, attributes: AttributeContainer) {
        self.init(characters: string, runs: Self.singleRun(length: string.count, attributes: attributes))
    }

    public func attributeValue(key: String) -> Any? {
        guard _runs.count == 1 else {
            return attributes(in: entireUTF16Range).value(key: key)
        }
        return _runs[0].attributes.value(key: key)
    }

    public mutating func setAttributeValue(_ value: Any?, key: String) {
        if _runs.isEmpty && !characters.isEmpty {
            _runs = Self.singleRun(length: characters.count, attributes: AttributeContainer())
        }
        _runs = _runs.map { run in
            var attrs = run.attributes
            attrs.setValue(value, key: key)
            return Run(utf16Range: run.utf16Range, attributes: attrs)
        }
    }

    // SKIP DECLARE: operator fun plus(other: AttributedString): AttributedString
    public func plus(other: AttributedString) -> AttributedString {
        var result = self
        result.append(other)
        return result
    }

    // SKIP DECLARE: operator fun plusAssign(other: AttributedString)
    public mutating func plusAssign(other: AttributedString) {
        append(other)
    }

    public mutating func append(_ other: AttributedString) {
        let offset = _utf16Length
        characters += other.characters
        for run in other._runs {
            let runUTF16 = run.utf16Range
            let shifted = Run(
                utf16Range: (runUTF16.lowerBound + offset)..<(runUTF16.upperBound + offset),
                attributes: run.attributes
            )
            _runs.append(shifted)
        }
        _runs = Self.coalesce(_runs)
    }

    internal func attributes(in utf16Range: Range<Int>) -> AttributeContainer {
        var merged = AttributeContainer()
        for run in _runs {
            let runUTF16 = run.utf16Range
            if runUTF16.lowerBound < utf16Range.upperBound && runUTF16.upperBound > utf16Range.lowerBound {
                merged.storage = merged.storage.merging(run.attributes.storage)
            }
        }
        return merged
    }
}

#endif
