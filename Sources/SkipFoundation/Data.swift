// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.Data
@_implementationOnly import protocol Foundation.DataProtocol
internal typealias PlatformData = Foundation.Data
internal typealias PlatformDataProtocol = Foundation.DataProtocol
public typealias StringProtocol = Swift.StringProtocol
#else
public typealias PlatformData = kotlin.ByteArray
public typealias StringProtocol = kotlin.CharSequence
internal typealias PlatformDataProtocol = kotlin.ByteArray
#endif

public protocol DataProtocol {
    #if SKIP
    var platformData: any PlatformDataProtocol { get }
    #endif
}

/// A byte buffer in memory.
public struct Data : DataProtocol, Hashable, CustomStringConvertible, Encodable {
    internal var platformValue: PlatformData

    internal var platformData: any PlatformDataProtocol {
        return platformValue
    }

    #if !SKIP
    internal init(platformValue: PlatformData) {
        self.platformValue = platformValue
    }
    #else
    public init(platformValue: PlatformData) {
        self.platformValue = platformValue
    }
    #endif

    public init(_ data: Data) {
        self.platformValue = data.platformValue
    }

    public init(_ bytes: [UInt8]) {
        #if !SKIP
        self.platformValue = PlatformData(bytes)
        #else
        self.platformValue = PlatformData(size: bytes.count, init: {
            bytes[$0].toByte()
        })
        #endif
    }

    #if !SKIP
    public init(_ bytes: Array<UInt8>.SubSequence) {
        self.platformValue = PlatformData(bytes)
    }
    #endif

    public init?(base64Encoded: String) {
        #if !SKIP
        guard let data = PlatformData(base64Encoded: base64Encoded) else {
            return nil
        }
        self.init(platformValue: data)
        #else
        guard let data = try? java.util.Base64.getDecoder().decode(base64Encoded) else {
            return nil
        }
        self.platformValue = data
        #endif
    }

    public init(from decoder: Decoder) throws {
        #if !SKIP
        self.platformValue = try PlatformData(from: decoder)
        #else
        self.platformValue = SkipCrash("TODO: Decoder")
        #endif
    }

    public func encode(to encoder: Encoder) throws {
        #if !SKIP
        try platformValue.encode(to: encoder)
        #else
        var container = encoder.unkeyedContainer()
        for b in self.bytes {
            try container.encode(b)
        }
        #endif
    }

    public var count: Int {
        #if !SKIP
        return platformValue.count
        #else
        return platformValue.size
        #endif
    }

    public var bytes: [UInt8] {
        #if !SKIP
        return Array(platformValue)
        #else
        return Array(platformValue.map { $0.toUByte() })
        #endif
    }

    // Platform declaration clash: The following declarations have the same JVM signature (<init>(Lskip/lib/Array;)V):
    //public init(_ bytes: [Int]) {
    //    self.platformValue = PlatformData(size: bytes.count, init: {
    //        bytes[$0].toByte()
    //    })
    //}

    public var description: String {
        return platformValue.description
    }

    /// A UTF8-encoded `String` created from this `Data`
    public var utf8String: String? {
        #if !SKIP
        String(data: platformValue, encoding: String.Encoding.utf8)
        #else
        String(data: self, encoding: String.Encoding.utf8)
        #endif
    }

    public init() {
        #if !SKIP
        self.platformValue = PlatformData(count: 0)
        #else
        self.platformValue = PlatformData(size: 0)
        #endif
    }

    public init(count: Int) {
        #if !SKIP
        self.platformValue = PlatformData(count: count)
        #else
        self.platformValue = PlatformData(size: count)
        #endif
    }

    public init(capacity: Int) {
        #if !SKIP
        self.platformValue = PlatformData(capacity: capacity)
        #else
        // No equivalent kotlin.ByteArray(capacity:), so allocate with zero
        self.platformValue = PlatformData(size: 0)
        #endif
    }

    public mutating func append(contentsOf bytes: [UInt8]) {
        #if !SKIP
        self.platformValue.append(contentsOf: bytes)
        #else
        self.platformValue += Data(bytes).platformValue
        #endif
    }

    public mutating func append(contentsOf data: Data) {
        #if !SKIP
        self.platformValue.append(contentsOf: data.platformValue)
        #else
        self.platformValue += data.platformValue
        #endif
    }

    public static func ==(lhs: Data, rhs: Data) -> Bool {
        #if !SKIP
        return lhs.platformValue == rhs.platformValue
        #else
        return lhs.platformValue.contentEquals(rhs.platformValue)
        #endif
    }

    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        #if !SKIP
        try platformValue.write(to: url.platformValue, options: .init(rawValue: options.rawValue))
        #else
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if options.contains(Data.WritingOptions.atomic) {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
        }

        java.nio.file.Files.write(url.toPath(), platformValue, *(opts.toList().toTypedArray()))
        #endif
    }

    public struct WritingOptions : OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let atomic = WritingOptions(rawValue: UInt(1 << 0))
    }
}

#if SKIP
extension Data {
    public func kotlin(nocopy: Bool = false) -> kotlin.ByteArray {
        return nocopy ? platformValue : platformValue.copyOf()
    }
}

extension kotlin.ByteArray {
    public func swift(nocopy: Bool = false) -> Data {
        let platformValue = nocopy ? self : copyOf()
        return Data(platformValue: platformValue)
    }
}
#endif

#if SKIP
// Mimic a String constructor.
public func String(data: Data, encoding: PlatformStringEncoding) -> String? {
    #if !SKIP
    return String.init(data: data.platformValue, encoding: encoding)
    #else
    return java.lang.String(data.platformValue, encoding.rawValue) as kotlin.String?
    #endif
}
#endif

extension String {
    /// The UTF8-encoded data for this string
    public var utf8Data: Data {
        #if !SKIP
        Data(platformValue: data(using: String.Encoding.utf8) ?? PlatformData())
        #else
        data(using: String.Encoding.utf8) ?? Data()
        #endif
    }
}

#if SKIP

// SKIP INSERT: public operator fun String.Companion.invoke(contentsOf: URL): String { return contentsOf.platformValue.readText() }

// SKIP INSERT: public operator fun Data.Companion.invoke(contentsOf: URL): Data { return Data.contentsOfURL(url = contentsOf) }

extension Data {
    /// Static init until constructor overload works.
    public static func contentsOfFile(filePath: String) throws -> Data {
        return Data(platformValue: java.io.File(filePath).readBytes())
    }

    /// Static init until constructor overload works.
    public static func contentsOfURL(url: URL) throws -> Data {
        //if url.isFileURL {
        //    return Data(java.io.File(url.path).readBytes())
        //} else {
        //    return Data(url.platformValue.openConnection().getInputStream().readBytes())
        //}

        // this seems to work for both file URLs and network URLs
        return Data(platformValue: url.platformValue.readBytes())
    }
}

public extension StringProtocol {
    public func lowercased() -> String { description.lowercased() }
    public func uppercased() -> String { description.uppercased() }

    public func hasPrefix(_ string: String) -> Bool { description.hasPrefix(string) }
    public func hasSuffix(_ string: String) -> Bool { description.hasSuffix(string) }
}

#endif
