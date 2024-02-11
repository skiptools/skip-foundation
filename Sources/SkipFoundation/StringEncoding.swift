// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct StringEncoding : RawRepresentable, Hashable {
    public static let utf8 = StringEncoding(rawValue: Charsets.UTF_8)
    public static let utf16 = StringEncoding(rawValue: Charsets.UTF_16)
    public static let utf16LittleEndian = StringEncoding(rawValue: Charsets.UTF_16LE)
    public static let utf16BigEndian = StringEncoding(rawValue: Charsets.UTF_16BE)
    public static let utf32 = StringEncoding(rawValue: Charsets.UTF_32)
    public static let utf32LittleEndian = StringEncoding(rawValue: Charsets.UTF_32LE)
    public static let utf32BigEndian = StringEncoding(rawValue: Charsets.UTF_32BE)

    public let rawValue: java.nio.charset.Charset

    public init(rawValue: java.nio.charset.Charset) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: java.nio.charset.Charset) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue.description
    }
}

#endif
