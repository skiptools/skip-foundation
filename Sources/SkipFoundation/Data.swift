// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

internal typealias PlatformData = kotlin.ByteArray
public typealias NSData = Data

public protocol DataProtocol {
    var platformData: PlatformData { get }
}

public struct Data : DataProtocol, Hashable, CustomStringConvertible, Codable, KotlinConverting<kotlin.ByteArray>, SwiftCustomBridged {
    public var platformValue: PlatformData

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

    public init?(base64Encoded: String, options: Data.Base64DecodingOptions = []) {
        guard let data = try? java.util.Base64.getDecoder().decode(base64Encoded) else {
            return nil
        }
        self.platformValue = data
    }

    @available(*, unavailable)
    public init?(base64Encoded base64Data: Data, options: Data.Base64DecodingOptions = []) {
        self.platformValue = PlatformData(size: 0)
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

    @available(*, unavailable)
    public init(bytes: Any /* UnsafeRawPointer */, count: Int) {
        self.platformValue = PlatformData(size: 0)
    }

    @available(*, unavailable)
    public init(buffer: Any /* UnsafeBufferPointer<SourceType> UnsafeMutableBufferPointer<SourceType> */) {
        self.platformValue = PlatformData(size: 0)
    }

    @available(*, unavailable)
    public init(repeating repeatedValue: UInt8, count: Int) {
        self.platformValue = PlatformData(size: 0)
    }

    @available(*, unavailable)
    public init(bytesNoCopy bytes: Any /* UnsafeMutableRawPointer */, count: Int, deallocator: Data.Deallocator) {
        self.platformValue = PlatformData(size: 0)
    }

    @available(*, unavailable)
    public init(_ elements: any Sequence<UInt8>) {
        self.platformValue = PlatformData(size: 0)
    }

    @available(*, unavailable)
    public init(referencing reference: Data) {
        self.platformValue = PlatformData(size: 0)
    }

    public init(contentsOfFile filePath: String) throws {
        self.platformValue = java.io.File(filePath).readBytes()
    }

    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        if url.scheme == "content" {
            let uri = url.toAndroidUri()
            if let inputStream = ProcessInfo.processInfo.androidContext.getContentResolver().openInputStream(uri) {
                var buffer = ByteArray(8192)
                var output = java.io.ByteArrayOutputStream()
                var bytesRead: Int
                while true {
                    let bytesRead = inputStream.read(buffer)
                    if (bytesRead == -1) { break }
                    output.write(buffer, 0, bytesRead)
                }
                self.platformValue = output.toByteArray()
                do { inputStream.close() } catch {}
            } else {
                throw java.util.MissingResourceException(url.absoluteString, "", "")
            }
        } else {
            self.platformValue = url.absoluteURL.platformValue.toURL().readBytes()
        }
    }

    public init(_ checksum: Digest) {
        self.init(checksum.bytes)
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

    public var platformData: PlatformData {
        return platformValue
    }

    public var description: String {
        return platformValue.description
    }

    public var count: Int {
        return platformValue.size
    }

    public var isEmpty: Bool {
        return count == 0
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

    public var utf8String: String? {
        String(data: self, encoding: String.Encoding.utf8)
    }

    public func base64EncodedString() -> String {
        return java.util.Base64.getEncoder().encodeToString(platformValue)
    }

    @available(*, unavailable)
    public func base64EncodedData(options: Data.Base64EncodingOptions = []) -> Data {
        fatalError()
    }

    public func sha256() -> Data {
        return Data(SHA256.hash(data: self).bytes)
    }

    public func hex() -> String {
        return platformValue.hex()
    }

    public mutating func reserveCapacity(_ minimumCapacity: Int) {
    }

    @available(*, unavailable)
    public var regions: Collection<Data> {
        fatalError()
    }

    @available(*, deprecated, message: "withUnsafeBytes requires import SkipFFI")
    internal func withUnsafeBytes(_ body: (Any /*UnsafeRawBufferPointer */) throws -> Any /* ResultType */) rethrows -> Any /*ResultType */ {
        fatalError()
    }

    @available(*, deprecated, message: "withUnsafeMutableBytes requires import SkipFFI")
    internal mutating func withUnsafeMutableBytes(_ body: (Any /* UnsafeMutableRawBufferPointer */) throws -> Any /* ResultType */) rethrows -> Any /* ResultType */ {
        fatalError()
    }

    @available(*, unavailable)
    public func copyBytes(to pointer: Any /* UnsafeMutablePointer<UInt8> */, count: Int) {
    }

    @available(*, unavailable)
    public func copyBytes(to pointer: Any /* UnsafeMutablePointer<UInt8> */, from range: Range<Int>) {
    }

    // public func copyBytes<DestinationType>(to buffer: UnsafeMutableBufferPointer<DestinationType>, from range: Range<Data.Index>? = nil) -> Int

    @available(*, unavailable)
    public mutating func append(_ bytes: Any /* UnsafePointer<UInt8> */, count: Int) {
    }

    public mutating func append(_ other: Data) {
        append(contentsOf: other)
    }

    public mutating func append(contentsOf bytes: [UInt8]) {
        self.platformValue += Data(bytes).platformValue
    }

    // This should be append(contentsOf: any Sequence<UInt8>), but Data does not yet conform to Sequence
    public mutating func append(contentsOf data: Data) {
        self.platformValue += data.platformValue
    }

    // public mutating func append<SourceType>(_ buffer: UnsafeBufferPointer<SourceType>)

    public func contains(_ other: Data) -> Bool {
        if (other.isEmpty) {
            return true
        }

        let limit = self.count - other.count
        if limit < 0 {
            return false
        }

        for i in 0...limit {
            if (platformValue.sliceArray(i..<(i + other.count)).contentEquals(other.platformValue)) {
                return true
            }
        }
        return false

    }

    @available(*, unavailable)
    public mutating func resetBytes(in range: Range<Int>) {
    }

    @available(*, unavailable)
    public mutating func replaceSubrange(_ subrange: Range<Int>, with data: Data) {
    }

    // public mutating func replaceSubrange<SourceType>(_ subrange: Range<Data.Index>, with buffer: UnsafeBufferPointer<SourceType>)

    // public mutating func replaceSubrange<ByteCollection>(_ subrange: Range<Data.Index>, with newElements: ByteCollection) where ByteCollection : Collection, ByteCollection.Element == UInt8

    @available(*, unavailable)
    public mutating func replaceSubrange(_ subrange: Range<Int>, with bytes: Any /* UnsafeRawPointer */, count: Int) {
    }

    @available(*, unavailable)
    public func subdata(in range: Range<Int>) -> Data {
        fatalError()
    }

    @available(*, unavailable)
    public func range(of dataToFind: Data, options: Data.SearchOptions = [], in range: Range<Int>? = nil) -> Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public func advanced(by amount: Int) -> Data {
        fatalError()
    }

    public subscript(index: Int) -> UInt8 {
        return UInt8(platformValue.get(index))
    }

    @available(*, unavailable)
    public subscript(bounds: Range<Int>) -> Data {
        fatalError()
    }

    public func write(to url: URL, options: Data.WritingOptions = []) throws {
        try writePlatformData(platformValue, to: url.toPath(), atomically: options.contains(Data.WritingOptions.atomic))
    }

    public static func ==(lhs: Data, rhs: Data) -> Bool {
        return lhs.platformValue.contentEquals(rhs.platformValue)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(platformValue.hashCode())
    }

    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias Element = UInt8

    public enum Deallocator {
        case virtualMemory
        case unmap
        case free
        case none
        case custom((Any /*UnsafeMutableRawPointer*/, Int) -> Void)
    }

    public struct ReadingOptions : OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        @available(*, unavailable)
        public static let mappedIfSafe = ReadingOptions(rawValue: 1)

        @available(*, unavailable)
        public static let uncached = ReadingOptions(rawValue: 2)

        @available(*, unavailable)
        public static let alwaysMapped = ReadingOptions(rawValue: 4)
    }

    public struct WritingOptions : OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let atomic = WritingOptions(rawValue: 1)

        @available(*, unavailable)
        public static let withoutOverwriting = WritingOptions(rawValue: 2)

        @available(*, unavailable)
        public static let noFileProtection = WritingOptions(rawValue: 4)

        @available(*, unavailable)
        public static let completeFileProtection = WritingOptions(rawValue: 8)

        @available(*, unavailable)
        public static let completeFileProtectionUnlessOpen = WritingOptions(rawValue: 16)

        @available(*, unavailable)
        public static let completeFileProtectionUntilFirstUserAuthentication = WritingOptions(rawValue: 32)
    }

    public struct SearchOptions : OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        @available(*, unavailable)
        public static let backwards = SearchOptions(rawValue: 1)

        @available(*, unavailable)
        public static let anchored = SearchOptions(rawValue: 2)
    }

    public struct Base64EncodingOptions : OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        @available(*, unavailable)
        public static let lineLength64Characters = Base64EncodingOptions(rawValue: 1)

        @available(*, unavailable)
        public static let lineLength76Characters = Base64EncodingOptions(rawValue: 2)

        @available(*, unavailable)
        public static let endLineWithCarriageReturn = Base64EncodingOptions(rawValue: 4)

        @available(*, unavailable)
        public static let endLineWithLineFeed = Base64EncodingOptions(rawValue: 8)
    }

    public struct Base64DecodingOptions : OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        @available(*, unavailable)
        public static let ignoreUnknownCharacters = Base64DecodingOptions(rawValue: 1)
    }

    public override func kotlin(nocopy: Bool = false) -> PlatformData {
        return nocopy ? platformValue : platformValue.copyOf()
    }
}

/// Mimic an `Array<UInt8>` constructor that accepts a `Data` as an array of bytes.
// SKIP INSERT: fun <T> Array(data: Data): Array<T> = data.bytes as Array<T>
// SKIP INSERT: fun Array.Companion.init(data: Data) = data.bytes

#endif
