// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

internal typealias PlatformData = kotlin.ByteArray
public typealias NSData = Data

public protocol DataProtocol {
    var platformData: PlatformData { get }
}

public struct Data : DataProtocol, Hashable, CustomStringConvertible, Codable {
    internal var platformValue: PlatformData

    public var platformData: PlatformData {
        return platformValue
    }

    public init(platformValue: PlatformData) {
        self.platformValue = platformValue
    }

    public init(_ data: Data) {
        self.platformValue = data.platformValue
    }

    public init(_ bytes: [UInt8], length: Int? = nil) {
        self.platformValue = PlatformData(size: length ?? bytes.count, init: {
            bytes[$0].toByte()
        })
    }

    public init?(base64Encoded: String) {
        guard let data = try? java.util.Base64.getDecoder().decode(base64Encoded) else {
            return nil
        }
        self.platformValue = data
    }

    public init(from decoder: Decoder) throws {
        var container = decoder.unkeyedContainer()
        var bytes: [UInt8] = []
        while !container.isAtEnd {
            bytes.append(container.decode(UInt8.self))
        }
        self.platformValue = PlatformData(size: bytes.count, init: {
            bytes[$0].toByte()
        })
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for b in self.bytes {
            try container.encode(b)
        }
    }

    public var count: Int {
        return platformValue.size
    }

    public var bytes: [UInt8] {
        return Array(platformValue.map { $0.toUByte() })
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

    public var utf8String: String? {
        String(data: self, encoding: String.Encoding.utf8)
    }

    public init() {
        self.platformValue = PlatformData(size: 0)
    }

    public init(count: Int) {
        self.platformValue = PlatformData(size: count)
    }

    public init(capacity: Int) {
        // No equivalent kotlin.ByteArray(capacity:), so allocate with zero
        self.platformValue = PlatformData(size: 0)
    }

    public mutating func append(contentsOf bytes: [UInt8]) {
        self.platformValue += Data(bytes).platformValue
    }

    public mutating func append(contentsOf data: Data) {
        self.platformValue += data.platformValue
    }

    public static func ==(lhs: Data, rhs: Data) -> Bool {
        return lhs.platformValue.contentEquals(rhs.platformValue)
    }

    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        var opts: [java.nio.file.StandardOpenOption] = []
        opts.append(java.nio.file.StandardOpenOption.CREATE)
        opts.append(java.nio.file.StandardOpenOption.WRITE)
        if options.contains(Data.WritingOptions.atomic) {
            opts.append(java.nio.file.StandardOpenOption.DSYNC)
        }

        java.nio.file.Files.write(url.toPath(), platformValue, *(opts.toList().toTypedArray()))
    }

    public struct WritingOptions : OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let atomic = WritingOptions(rawValue: UInt(1 << 0))
    }
}

extension Data: KotlinConverting<PlatformData> {
    public override func kotlin(nocopy: Bool = false) -> PlatformData {
        return nocopy ? platformValue : platformValue.copyOf()
    }
}

// Mimic a String constructor.
public func String(data: Data, encoding: StringEncoding) -> String? {
    return java.lang.String(data.platformValue, encoding.rawValue) as kotlin.String?
}

extension String {
    /// The UTF8-encoded data for this string
    public var utf8Data: Data {
        data(using: String.Encoding.utf8) ?? Data()
    }
}

// SKIP INSERT: public operator fun String.Companion.invoke(contentsOf: URL): String { return contentsOf.platformValue.readText() }

// SKIP INSERT: public operator fun Data.Companion.invoke(contentsOf: URL): Data { return Data.contentsOfURL(url = contentsOf) }

extension Data {
    // Static init until constructor overload works.
    public static func contentsOfFile(filePath: String) throws -> Data {
        return Data(platformValue: java.io.File(filePath).readBytes())
    }

    // Static init until constructor overload works.
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

#endif
