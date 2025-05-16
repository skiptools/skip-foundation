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
    return str1.toLowerCase() == str2.toLowerCase() ? 0 : 1
}

extension String {
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
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if useAuxiliaryFile {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
            opts.append(java.nio.file.StandardOpenOption.SYNC)
        }
        java.nio.file.Files.write(platformFilePath(for: url), self.data(using: enc)?.platformValue, *(opts.toList().toTypedArray()))
    }

    public func write(toFile path: String, atomically useAuxiliaryFile: Bool, encoding enc: StringEncoding) throws {
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if useAuxiliaryFile {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
            opts.append(java.nio.file.StandardOpenOption.SYNC)
        }
        java.nio.file.Files.write(platformFilePath(for: path), self.data(using: enc)?.platformValue, *(opts.toList().toTypedArray()))
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
