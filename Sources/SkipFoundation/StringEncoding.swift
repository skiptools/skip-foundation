// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
extension String {
    public func data(using: StringEncoding, allowLossyConversion: Bool = true) -> Data? {
        return try? Data(platformValue: toByteArray(using.rawValue))
    }

    public var utf8: [UInt8] {
        // TODO: there should be a faster way to convert a string to a UInt8 array
        return Array(toByteArray(StringEncoding.utf8.rawValue).map { it.toUByte() })
    }

    public var utf16: [UInt8] {
        return Array(toByteArray(StringEncoding.utf16.rawValue).map { it.toUByte() })
    }

    public var unicodeScalars: [UInt8] {
        return Array(toByteArray(StringEncoding.utf8.rawValue).map { it.toUByte() })
    }
}

#endif

public struct StringEncoding : RawRepresentable, Hashable {
    #if SKIP
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
    #else
    public static let ascii = StringEncoding(rawValue: String.Encoding.ascii.rawValue)
    public static let nextstep = StringEncoding(rawValue: String.Encoding.nextstep.rawValue)
    public static let japaneseEUC = StringEncoding(rawValue: String.Encoding.japaneseEUC.rawValue)
    public static let utf8 = StringEncoding(rawValue: String.Encoding.utf8.rawValue)
    public static let isoLatin1 = StringEncoding(rawValue: String.Encoding.isoLatin1.rawValue)
    public static let symbol = StringEncoding(rawValue: String.Encoding.symbol.rawValue)
    public static let nonLossyASCII = StringEncoding(rawValue: String.Encoding.nonLossyASCII.rawValue)
    public static let shiftJIS = StringEncoding(rawValue: String.Encoding.shiftJIS.rawValue)
    public static let isoLatin2 = StringEncoding(rawValue: String.Encoding.isoLatin2.rawValue)
    public static let unicode = StringEncoding(rawValue: String.Encoding.unicode.rawValue)
    public static let windowsCP1251 = StringEncoding(rawValue: String.Encoding.windowsCP1251.rawValue)
    public static let windowsCP1252 = StringEncoding(rawValue: String.Encoding.windowsCP1252.rawValue)
    public static let windowsCP1253 = StringEncoding(rawValue: String.Encoding.windowsCP1253.rawValue)
    public static let windowsCP1254 = StringEncoding(rawValue: String.Encoding.windowsCP1254.rawValue)
    public static let windowsCP1250 = StringEncoding(rawValue: String.Encoding.windowsCP1250.rawValue)
    public static let iso2022JP = StringEncoding(rawValue: String.Encoding.iso2022JP.rawValue)
    public static let macOSRoman = StringEncoding(rawValue: String.Encoding.macOSRoman.rawValue)
    public static let utf16 = StringEncoding(rawValue: String.Encoding.utf16.rawValue)
    public static let utf16BigEndian = StringEncoding(rawValue: String.Encoding.utf16BigEndian.rawValue)
    public static let utf16LittleEndian = StringEncoding(rawValue: String.Encoding.utf16LittleEndian.rawValue)
    public static let utf32 = StringEncoding(rawValue: String.Encoding.utf32.rawValue)
    public static let utf32BigEndian = StringEncoding(rawValue: String.Encoding.utf32BigEndian.rawValue)
    public static let utf32LittleEndian = StringEncoding(rawValue: String.Encoding.utf32LittleEndian.rawValue)

    public typealias RawValue = UInt
    public let rawValue: RawValue

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    internal var platformValue: Swift.String.Encoding {
        Swift.String.Encoding(rawValue: rawValue)
    }
    #endif
}
