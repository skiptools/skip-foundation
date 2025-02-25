// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public typealias NSUUID = UUID

public struct UUID : Hashable, Comparable, CustomStringConvertible, Codable, KotlinConverting<java.util.UUID>, SwiftCustomBridged {
    internal var platformValue: java.util.UUID

    public init?(uuidString: String) {
        // Java throws an exception for bad UUID, but Foundation expects it to return nil
        guard let uuid = try? java.util.UUID.fromString(uuidString) else {
            return nil
        }
        self.platformValue = uuid
    }

    public init(platformValue: java.util.UUID) {
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

    @available(*, unavailable)
    public var uuid: Any {
        fatalError()
    }

    public var uuidString: String {
        // java.util.UUID is lowercase, Foundation.UUID is uppercase
        return platformValue.toString().uppercase()
    }

    public var description: String {
        return uuidString
    }

    public static func <(lhs: UUID, rhs: UUID) -> Bool {
        return lhs.platformValue < rhs.platformValue
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.UUID {
        return platformValue
    }
}

// SKIP INSERT: public fun UUID(mostSigBits: Long, leastSigBits: Long): UUID { return UUID(java.util.UUID(mostSigBits, leastSigBits)) }

#endif

