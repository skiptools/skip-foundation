// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSUUID = UUID

public struct UUID : Hashable, CustomStringConvertible, Codable {
    internal var platformValue: java.util.UUID

    public init?(uuidString: String) {
        // Java throws an exception for bad UUID, but Foundation expects it to return nil
        guard let uuid = try? java.util.UUID.fromString(uuidString) else {
            return nil
        }
        self.platformValue = uuid
    }

    internal init(_ platformValue: java.util.UUID) {
        self.platformValue = platformValue
    }

    public init() {
        self.platformValue = java.util.UUID.randomUUID()
    }

    public init(from decoder: Decoder) throws {
        var container = decoder.singleValueContainer()
        self.platformValue = java.util.UUID.fromString(container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.uuidString)
    }

    public static func fromString(uuidString: String) -> UUID? {
        // Java throws an exception for bad UUID, but Foundation expects it to return nil
        // return try? UUID(platformValue: PlatformUUID.fromString(uuidString)) // mistranspiles to: (PlatformUUID.companionObjectInstance as java.util.UUID.Companion).fromString(uuidString))
        return try? UUID(platformValue: java.util.UUID.fromString(uuidString))
    }

    public var uuidString: String {
        // java.util.UUID is lowercase, Foundation.UUID is uppercase
        return platformValue.toString().uppercase()
    }

    public var description: String {
        return uuidString
    }
}

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

