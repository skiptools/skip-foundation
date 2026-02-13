// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
// This code is adapted from https://github.com/swiftlang/swift-corelibs-foundation/blob/main/Sources/Foundation/URL.swift which has the following license:

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#if SKIP

public typealias NSString = kotlin.String
public func NSString(string: String) -> NSString { string }

public func strlen(_ string: String) -> Int {
    return string.count
}

public func strncmp(_ str1: String, _ str2: String) -> Int {
    return str1.lowercase() == str2.lowercase() ? 0 : 1
}

extension String {
    public func appending(_ other: String) -> String {
        self + other
    }

    public var capitalized: String {
        return split(separator: " ", omittingEmptySubsequences: false)
            .joinToString(separator: " ") {
                $0.replaceFirstChar { $0.titlecase() }
            }
    }

    public var deletingLastPathComponent: String {
        guard let lastSlash = lastIndex(of: "/") else {
            // No slash, entire string is deleted
            return ""
        }

        // Skip past consecutive slashes, if any (e.g. find "y" in "/my//path" or "h" in "/path//")
        guard let lastNonSlash = String(self[..<lastSlash]).lastIndex(where: { $0 != "/" }) else {
            // String consists entirely of slashes, return a single slash
            return "/"
        }

        let hasTrailingSlash = (lastSlash == index(before: endIndex))
        guard hasTrailingSlash else {
            // No trailing slash, return up to (including) the last non-slash character
            return String(self[...lastNonSlash])
        }

        // We have a trailing slash, find the slash before the last component
        guard let previousSlash = String(self[..<lastNonSlash]).lastIndex(of: "/") else {
            // No prior slash, deleting the last component removes the entire string (e.g. "path/")
            return ""
        }

        // Again, skip past consecutive slashes, if any (e.g. find "y" in "/my//path/")
        guard let previousNonSlash = String(self[..<previousSlash]).lastIndex(where: { $0 != "/" }) else {
            // String is an absolute path with a single component (e.g. "/path/" or "//path/")
            return "/"
        }

        return String(self[...previousNonSlash])
    }

    public func replacingOccurrences(of search: String, with replacement: String) -> String {
        return replace(search, replacement)
    }

    public func components(separatedBy separator: String) -> [String] {
        return Array(split(separator, ignoreCase: false))
    }

    private func compare(_ aString: String, strength: Int, locale: Locale = Locale.current) -> ComparisonResult {
        let collator = java.text.Collator.getInstance(locale.platformValue)
        collator.setStrength(strength)
        let result = collator.compare(self, aString)
        if result < 0 {
            return .orderedAscending
        } else if result > 0 {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }

    public func localizedCompare(_ string: String) -> ComparisonResult {
        // only SECONDARY and above differences are considered significant during comparison. The assignment of strengths to language features is locale dependant. A common example is for different accented forms of the same base letter ("a" vs "ä") to be considered a SECONDARY difference.
        compare(string, strength: java.text.Collator.SECONDARY)
    }

    public func localizedCaseInsensitiveCompare(_ string: String) -> ComparisonResult {
        // only TERTIARY and above differences are considered significant during comparison. The assignment of strengths to language features is locale dependant. A common example is for case differences ("a" vs "A") to be considered a TERTIARY difference.
        compare(string, strength: java.text.Collator.TERTIARY)
    }

    @available(*, unavailable)
    public func localizedStandardCompare(_ string: String) -> ComparisonResult {
        fatalError("unsupported")
    }

    public func trimmingCharacters(in set: CharacterSet) -> String {
        return trim { set.platformValue.contains(UInt32($0.code)) }
    }

    public func addingPercentEncoding(withAllowedCharacters allowedCharacters: CharacterSet) -> String? {
        return UrlEncoderUtil.encode(self, allowedCharacters.platformValue, spaceToPlus: true)
    }

    public var removingPercentEncoding: String? {
        return UrlEncoderUtil.decode(self, plusToSpace: true)
    }

    public func range(of searchString: String) -> Range<String.Index>? {
        let startIndex = indexOf(searchString)
        return startIndex != -1 ? startIndex..<(startIndex + searchString.count) : nil
    }

    public typealias Encoding = StringEncoding

    public var utf8Data: Data {
        data(using: String.Encoding.utf8) ?? Data()
    }

    public func data(using: StringEncoding, allowLossyConversion: Bool = true) -> Data? {
        if using == StringEncoding.utf16 {
            return Data(self.utf16) // Darwin is little-endian while Java is big-endian
        } else if using == StringEncoding.utf32 {
            return Data(self.utf32) // Darwin is little-endian while Java is big-endian
        } else {
            let bytes = toByteArray(using.rawValue)
            return Data(platformValue: bytes)
        }
    }

    public var utf8: [UInt8] {
        // TODO: there should be a faster way to convert a string to a UInt8 array
        return Array(toByteArray(StringEncoding.utf8.rawValue).toUByteArray())
    }

    public var utf16: [UInt8] {
        // Darwin is little-endian while Java is big-endian
        // encoding difference with UTF16: https://github.com/google/j2objc/issues/403
        // so we manually use utf16LittleEndian (no BOM) then add back in the byte-order mark (the first two bytes)
        return [UInt8(0xFF), UInt8(0xFE)] + Array(toByteArray(StringEncoding.utf16LittleEndian.rawValue).toUByteArray())
    }

    public var utf32: [UInt8] {
        // manually use utf32LittleEndian (no BOM) then add back in the byte-order mark (the first two bytes)
        return [UInt8(0xFF), UInt8(0xFE), UInt8(0x00), UInt8(0x00)] + Array(toByteArray(StringEncoding.utf32LittleEndian.rawValue).toUByteArray())
    }

    public var unicodeScalars: [UInt8] {
        return Array(toByteArray(StringEncoding.utf8.rawValue).toUByteArray())
    }

    public func write(to url: URL, atomically useAuxiliaryFile: Bool, encoding enc: StringEncoding) throws {
        guard let bytes = self.data(using: enc)?.platformValue else { return }
        try writePlatformData(bytes, to: platformFilePath(for: url), atomically: useAuxiliaryFile)
    }

    public func write(toFile path: String, atomically useAuxiliaryFile: Bool, encoding enc: StringEncoding) throws {
        guard let bytes = self.data(using: enc)?.platformValue else { return }
        try writePlatformData(bytes, to: platformFilePath(for: path), atomically: useAuxiliaryFile)
    }
}

public func String(data: Data, encoding: StringEncoding) -> String? {
    return java.lang.String(data.platformValue, encoding.rawValue) as kotlin.String?
}

public func String(bytes: [UInt8], encoding: StringEncoding) -> String? {
    let byteArray = ByteArray(size: bytes.count) {
         return bytes[$0].toByte()
     }
     return byteArray.toString(encoding.rawValue)
}

public func String(contentsOf: URL) throws -> String {
    return contentsOf.absoluteURL.platformValue.toURL().readText()
}

public func String(contentsOf: URL, encoding: StringEncoding) throws -> String {
    return java.lang.String(Data(contentsOf: contentsOf).platformValue, encoding.rawValue) as kotlin.String
}

private func localizationValue(keyAndValue: String.LocalizationValue, bundle: Bundle, defaultValue: String?, tableName: String?, locale: Locale?) -> String {
    let key = keyAndValue.patternFormat // interpolated string: "Hello \(name)" keyed as: "Hello %@"
    let (_, locfmt, _) = bundle.localizedInfo(forKey: key, value: defaultValue, table: tableName, locale: locale)
    // re-interpret the placeholder strings in the resulting localized string with the string interpolation's values
    let replaced = locfmt.format(*keyAndValue.stringInterpolation.values.toTypedArray())
    return replaced
}

public func String(localized resource: LocalizedStringResource) -> String {
    localizationValue(keyAndValue: resource.keyAndValue, bundle: resource.bundle?.bundle ?? Bundle.main, defaultValue: resource.defaultValue?.patternFormat.kotlinFormatString, tableName: resource.table, locale: resource.locale)
}

/// e.g.: `String(localized: "Done", table: nil, bundle: Bundle.module, locale: Locale(identifier: "en"), comment: nil)`
public func String(localized keyAndValue: String.LocalizationValue, table: String? = nil, bundle: Bundle? = nil, locale: Locale = Locale.current, comment: String? = nil) -> String {
    localizationValue(keyAndValue: keyAndValue, bundle: bundle ?? Bundle.main, defaultValue: nil, tableName: table, locale: locale)
}

public func String(localized key: String, defaultValue: String? = nil, table: String? = nil, bundle: Bundle? = nil, locale: Locale? = nil, comment: String? = nil) -> String {
    return (bundle ?? Bundle.main).localizedString(forKey: key, value: defaultValue, table: table, locale: locale) ?? defaultValue ?? key
}

#endif
