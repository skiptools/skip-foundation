// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

import net.thauvin.erik.urlencoder.UrlEncoderUtil

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
        let lastSeparatorIndex = lastIndexOf("/")
        if lastSeparatorIndex == -1 || (lastSeparatorIndex == 0 && self.length == 1) {
            return self
        }
        let newPath = substring(0, lastSeparatorIndex)
        let newLastSeparatorIndex = newPath.lastIndexOf("/")
        if newLastSeparatorIndex == -1 {
            return newPath
        } else {
            return newPath.substring(0, newLastSeparatorIndex + 1)
        }
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

public func String(contentsOf: URL) -> String {
    return contentsOf.platformValue.readText()
}

#endif
