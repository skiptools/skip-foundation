// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public struct DateInterval : Hashable, Comparable, Codable {
    public let start: Date

    public var end: Date {
        return start.addingTimeInterval(duration)
    }

    public let duration: TimeInterval

    public init() {
        self.init(start: Date(), duration: 0.0)
    }

    public init(start: Date, end: Date) {
        self.init(start: start, duration: end.timeIntervalSince1970 - start.timeIntervalSince1970)
    }

    public init(start: Date, duration: TimeInterval) {
        self.start = start
        self.duration = duration
    }

    public func intersects(_ dateInterval: DateInterval) -> Bool {
        return intersection(with: dateInterval) != nil
    }

    public func intersection(with dateInterval: DateInterval) -> DateInterval? {
        let start = max(self.start, dateInterval.start)
        let end = min(self.end, dateInterval.end)
        guard start <= end else {
            return nil
        }
        return DateInterval(start: start, end: end)
    }

    public func contains(_ date: Date) -> Bool {
        return start <= date && end >= date
    }

    public static func == (lhs: DateInterval, rhs: DateInterval) -> Bool {
        return lhs.start == rhs.start && lhs.duration == rhs.duration
    }

    public static func <(lhs: DateInterval, rhs: DateInterval) -> Bool {
        return lhs.start < rhs.start || (lhs.start == rhs.start && lhs.duration < rhs.duration)
    }
}

#endif
