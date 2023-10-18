// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.UUID
internal typealias PlatformUUID = Foundation.UUID
internal typealias NSUUID = Foundation.UUID
#else
public typealias PlatformUUID = java.util.UUID
public typealias NSUUID = UUID
#endif

public struct UUID : Hashable, CustomStringConvertible, Encodable {
    internal var platformValue: PlatformUUID

    public init?(uuidString: String) {
        #if !SKIP
        guard let platformValue = PlatformUUID(uuidString: uuidString) else {
            return nil
        }
        self.platformValue = platformValue
        #else
        // Java throws an exception for bad UUID, but Foundation expects it to return nil
        guard let uuid = try? java.util.UUID.fromString(uuidString) else {
            return nil
        }
        self.platformValue = uuid
        #endif
    }

    internal init(_ platformValue: PlatformUUID) {
        self.platformValue = platformValue
    }

    #if !SKIP
    internal init(platformValue: PlatformUUID) {
        self.platformValue = platformValue
    }
    #endif

    #if SKIP
    public init() {
        self.platformValue = java.util.UUID.randomUUID()
    }
    #endif

    public init(from decoder: Decoder) throws {
        #if !SKIP
        self.platformValue = try PlatformUUID(from: decoder)
        #else
        self.platformValue = SkipCrash("TODO: Decoder")
        #endif
    }

    public func encode(to encoder: Encoder) throws {
        #if !SKIP
        try platformValue.encode(to: encoder)
        #else
        var container = encoder.singleValueContainer()
        try container.encode(self.uuidString)
        #endif
    }

    #if SKIP
    public static func fromString(uuidString: String) -> UUID? {
        // Java throws an exception for bad UUID, but Foundation expects it to return nil
        // return try? UUID(platformValue: PlatformUUID.fromString(uuidString)) // mistranspiles to: (PlatformUUID.companionObjectInstance as java.util.UUID.Companion).fromString(uuidString))
        return try? UUID(platformValue: java.util.UUID.fromString(uuidString))
    }
    #endif

    public var uuidString: String {
        #if SKIP
        // java.util.UUID is lowercase, Foundation.UUID is uppercase
        return platformValue.toString().uppercase()
        #else
        return platformValue.uuidString
        #endif
    }

    public var description: String {
        return uuidString
    }
}

#if !SKIP

extension UUID {
    public init(mostSigBits: Int64, leastSigBits: Int64) {
        var mostSigBits = mostSigBits
        var leastSigBits = leastSigBits
        self.platformValue = withUnsafeBytes(of: &mostSigBits) { a in
            withUnsafeBytes(of: &leastSigBits) { b in
                PlatformUUID(uuid: (a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0], b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0]))
            }
        }
    }
}

#else

// SKIP INSERT: public fun UUID(mostSigBits: Long, leastSigBits: Long): UUID { return UUID(java.util.UUID(mostSigBits, leastSigBits)) }

//extension UUID {
//    public init(mostSigBits: Int64, leastSigBits: Int64) {
//        UUID(mostSigBits, leastSigBits)
//    }
//
//    public var uuidString: String {
//        // java.util.UUID is lowercase, Foundation.UUID is uppercase
//        return platformValue.toString().uppercase()
//    }
//
//    public var description: String {
//        return uuidString
//    }
//}

#endif

#if SKIP
extension UUID {
    public func kotlin(nocopy: Bool = false) -> java.util.UUID {
        return platformValue
    }
}

extension java.util.UUID {
    public func swift(nocopy: Bool = false) -> UUID {
        return UUID(platformValue: self)
    }
}
#endif

