// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.DateInterval
internal typealias PlatformDateInterval = Foundation.DateInterval
#else
public typealias PlatformDateInterval = java.time.Duration
#endif

public struct DateInterval : Hashable, Comparable, CustomStringConvertible {
    internal var platformValue: PlatformDateInterval

    internal init(platformValue: PlatformDateInterval) {
        self.platformValue = platformValue
    }

    public var description: String {
        return platformValue.description
    }

    @available(*, unavailable)
    public var start: Date {
        #if !SKIP
        return Date(platformValue: platformValue.start)
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public var end: Date {
        #if !SKIP
        return Date(platformValue: platformValue.end)
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public var duration: TimeInterval {
        #if !SKIP
        return platformValue.duration
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public init() {
        #if !SKIP
        self.platformValue = PlatformDateInterval()
        #else
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
        #endif
    }

    @available(*, unavailable)
    public init(start: Date, end: Date) {
        #if !SKIP
        self.platformValue = PlatformDateInterval(start: start.platformValue, end: end.platformValue)
        #else
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
        #endif
    }

    @available(*, unavailable)
    public init(start: Date, duration: TimeInterval) {
        #if !SKIP
        self.platformValue = PlatformDateInterval(start: start.platformValue, duration: duration)
        #else
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
        #endif
    }

    @available(*, unavailable)
    public func compare(_ dateInterval: DateInterval) -> ComparisonResult {
        #if !SKIP
        return platformValue.compare(dateInterval.platformValue).rekey()!
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public func intersects(_ dateInterval: DateInterval) -> Bool {
        #if !SKIP
        return platformValue.intersects(dateInterval.platformValue)
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public func intersection(with dateInterval: DateInterval) -> DateInterval? {
        #if !SKIP
        return (platformValue.intersection(with: dateInterval.platformValue)).flatMap(DateInterval.init(platformValue:))
        #else
        fatalError("SKIP TODO")
        #endif
    }

    @available(*, unavailable)
    public func contains(_ date: Date) -> Bool {
        #if !SKIP
        return platformValue.contains(date.platformValue)
        #else
        fatalError("SKIP TODO")
        #endif
    }

    public static func == (lhs: DateInterval, rhs: DateInterval) -> Bool {
        #if !SKIP
        return lhs.platformValue == rhs.platformValue
        #else
        fatalError("SKIP TODO")
        #endif
    }

    public static func < (lhs: DateInterval, rhs: DateInterval) -> Bool {
        #if !SKIP
        return lhs.platformValue < rhs.platformValue
        #else
        fatalError("SKIP TODO")
        #endif
    }
}
