// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct DateInterval : Hashable, Comparable, CustomStringConvertible {
    internal var platformValue: java.time.Duration

    internal init(platformValue: java.time.Duration) {
        self.platformValue = platformValue
    }

    public var description: String {
        return platformValue.description
    }

    @available(*, unavailable)
    public var start: Date {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public var end: Date {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public var duration: TimeInterval {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public init() {
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
    }

    @available(*, unavailable)
    public init(start: Date, end: Date) {
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
    }

    @available(*, unavailable)
    public init(start: Date, duration: TimeInterval) {
        self.platformValue = SkipCrash("TODO: PlatformDateInterval")
    }

    @available(*, unavailable)
    public func compare(_ dateInterval: DateInterval) -> ComparisonResult {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public func intersects(_ dateInterval: DateInterval) -> Bool {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public func intersection(with dateInterval: DateInterval) -> DateInterval? {
        fatalError("SKIP TODO")
    }

    @available(*, unavailable)
    public func contains(_ date: Date) -> Bool {
        fatalError("SKIP TODO")
    }

    public static func == (lhs: DateInterval, rhs: DateInterval) -> Bool {
        return lhs.platformValue == rhs.platformValue
    }

    public static func < (lhs: DateInterval, rhs: DateInterval) -> Bool {
        fatalError("SKIP TODO")
    }
}

#endif
