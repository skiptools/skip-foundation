// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
import protocol Swift.RandomNumberGenerator
import struct Swift.SystemRandomNumberGenerator

public typealias RandomNumberGenerator = Swift.RandomNumberGenerator
public typealias SystemRandomNumberGenerator = Swift.SystemRandomNumberGenerator

/// A seeded random number generator that is not cryptographically secure.
///
/// The implementation follows the Java `java.util.Random` seeded random:
/// it uses a 48-bit seed, which is modified using a linear congruential formula. (See Donald Knuth, The Art of Computer Programming, Volume 2, Section 3.2.1.)
public struct PseudoRandomNumberGenerator : RandomNumberGenerator {
    private let multiplier: Int64 = 0x5DEECE66D
    private let addend: Int64 = 0xB
    private let mask: Int64 = (1 << 48) - 1
    public var seed: Int64
    public let algorithm: Algorithm

    public enum Algorithm {
        case linearCongruential
        //case mersenneTwister
        //case xorShift
    }

    public init(algorithm: Algorithm = .linearCongruential, seed: Int64) {
        self.algorithm = algorithm
        self.seed = (seed ^ multiplier) & mask
    }

    @usableFromInline mutating func next(_ bits: Int32) -> Int64 {
        seed = (seed &* multiplier + addend) & mask
        return seed >> (48 - bits)
    }

    @inlinable public mutating func nextBoolean() -> Bool {
        return next(1) != 0
    }

    @inlinable public mutating func nextInt() -> Int32 {
        Int32(truncatingIfNeeded: next(32))
    }

    @inlinable public mutating func nextLong() -> Int64 {
        (Int64(nextInt()) << 32) + Int64(nextInt())
    }

    @inlinable public mutating func next() -> UInt64 {
        return UInt64(bitPattern: nextLong())
    }

    public static func seeded(seed: Int64) -> PseudoRandomNumberGenerator {
        PseudoRandomNumberGenerator(seed: seed)
    }
}

extension RandomNumberGenerator {
    /// Returns a new UUID with the most and least signficiant bits being the next two ints
    @inlinable public mutating func nextUUID() -> UUID {
        return UUID(mostSigBits: Int64(bitPattern: next()), leastSigBits: Int64(bitPattern: next()))
    }

}

#else

public typealias PlatformPseudoRandomNumberGenerator = java.util.Random
public typealias PlatformSystemRandomNumberGenerator = java.security.SecureRandom

public protocol RandomNumberGenerator {
    mutating func next() -> UInt64
}

public struct SystemRandomNumberGenerator : RawRepresentable, RandomNumberGenerator {
    public var rawValue: PlatformSystemRandomNumberGenerator

    public init(rawValue: PlatformSystemRandomNumberGenerator) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: PlatformSystemRandomNumberGenerator = PlatformSystemRandomNumberGenerator()) {
        self.rawValue = rawValue
    }

    public func nextLong() -> Long {
        return rawValue.nextLong()
    }

    public func nextInt() -> Int32 {
        return rawValue.nextInt()
    }

    public func next() -> UInt64 {
        return rawValue.nextLong().toULong()
    }

    public func nextBoolean() -> Bool {
        return rawValue.nextBoolean()
    }

    public func nextUUID() -> UUID {
        return UUID(mostSigBits: rawValue.nextLong(), leastSigBits: rawValue.nextLong())
    }
}


public struct PseudoRandomNumberGenerator : RawRepresentable {
    public var rawValue: PlatformPseudoRandomNumberGenerator

    public init(rawValue: PlatformPseudoRandomNumberGenerator) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: PlatformPseudoRandomNumberGenerator = PlatformPseudoRandomNumberGenerator()) {
        self.rawValue = rawValue
    }

    public static func seeded(seed: Int64) -> PseudoRandomNumberGenerator {
        return PseudoRandomNumberGenerator(rawValue: PlatformPseudoRandomNumberGenerator(seed))
    }

    public func nextLong() -> Long {
        return rawValue.nextLong()
    }

    public func nextInt() -> Int32 {
        return rawValue.nextInt()
    }

    public func next() -> UInt64 {
        return rawValue.nextLong().toULong()
    }

    public func nextBoolean() -> Bool {
        return rawValue.nextBoolean()
    }

    public func nextUUID() -> UUID {
        return UUID(mostSigBits: rawValue.nextLong(), leastSigBits: rawValue.nextLong())
    }
}

#endif
