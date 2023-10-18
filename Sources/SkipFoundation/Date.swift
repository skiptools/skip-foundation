// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.Date
@_implementationOnly import typealias Foundation.TimeInterval
@_implementationOnly import func Foundation.CFAbsoluteTimeGetCurrent
@_implementationOnly import class Foundation.NSDate
internal typealias PlatformDate = Foundation.Date
internal typealias NSDate = Foundation.NSDate
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public typealias PlatformISO8601FormatStyle = Date.ISO8601FormatStyle
#else
public typealias PlatformDate = java.util.Date
public typealias PlatformISO8601FormatStyle = Date.ISO8601FormatStyle
public typealias NSDate = Date
#endif

#if !SKIP
public typealias TimeInterval = Double
public typealias CFAbsoluteTime = Double

public func CFAbsoluteTimeGetCurrent() -> CFAbsoluteTime {
    Foundation.CFAbsoluteTimeGetCurrent()
}

#else
public typealias TimeInterval = Double
public typealias CFTimeInterval = TimeInterval

// Minic the constructor for `TimeInterval()` with an Int.
public func TimeInterval(_ seconds: Int) -> TimeInterval {
    return seconds.toDouble()
}

public typealias CFAbsoluteTime = CFTimeInterval

public func CFAbsoluteTimeGetCurrent() -> CFAbsoluteTime {
    Date.timeIntervalSinceReferenceDate
}
#endif

public struct Date : Hashable, CustomStringConvertible, Comparable, Encodable {
    internal var platformValue: PlatformDate

    public static let timeIntervalBetween1970AndReferenceDate: TimeInterval = 978307200.0

    public static var timeIntervalSinceReferenceDate: TimeInterval {
        #if !SKIP
        return PlatformDate.timeIntervalSinceReferenceDate
        #else
        (System.currentTimeMillis().toDouble() / 1000.0) - timeIntervalBetween1970AndReferenceDate
        #endif
    }

    public static let distantPast = Date(timeIntervalSince1970: -62135769600.0)
    public static let distantFuture = Date(timeIntervalSince1970: 64092211200.0)

    public init() {
        self.platformValue = PlatformDate()
    }

    internal init(platformValue: PlatformDate) {
        self.platformValue = platformValue
    }

    public init(from decoder: Decoder) throws {
        #if !SKIP
        self.platformValue = try PlatformDate(from: decoder)
        #else
        // In Kotlin, delegating calls to 'self' or 'super' constructors can not use local variables other than the parameters passed to this constructor
        //let container = try decoder.singleValueContainer()
        //let timestamp = try container.decode(Double.self)
        //self.init(timeIntervalSinceReferenceDate: timestamp)
        //self.init(timeIntervalSinceReferenceDate: try decoder.singleValueContainer().decode(Double.self))
        self.platformValue = SkipCrash("TODO: Decoder")
        #endif
    }

    public func encode(to encoder: Encoder) throws {
        #if !SKIP
        try platformValue.encode(to: encoder)
        #else
        var container = encoder.singleValueContainer()
        try container.encode(self.timeIntervalSinceReferenceDate)
        #endif
    }

    #if SKIP
    // We don't support initializing doubles from int literals in Kotlin, so add a constructor that lets people do things like `Date(timeIntervalSince1970: 1449332351)`.
    public init(timeIntervalSince1970: Int) {
        self.platformValue = PlatformDate((Double(timeIntervalSince1970) * 1000.0).toLong())
    }

    // We don't support initializing doubles from int literals in Kotlin, so add a constructor that lets people do things like `Date(timeIntervalSince1970: 1449332351)`.
    public init(timeIntervalSinceReferenceDate: Int) {
        self.platformValue = PlatformDate(((Double(timeIntervalSinceReferenceDate) + Date.timeIntervalBetween1970AndReferenceDate) * 1000.0).toLong())
    }
    #endif

    public init(timeIntervalSince1970: TimeInterval) {
        #if !SKIP
        self.platformValue = PlatformDate(timeIntervalSince1970: timeIntervalSince1970)
        #else
        self.platformValue = PlatformDate((timeIntervalSince1970 * 1000.0).toLong())
        #endif
    }

    public init(timeIntervalSinceReferenceDate: TimeInterval) {
        #if !SKIP
        self.platformValue = PlatformDate(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate)
        #else
        self.platformValue = PlatformDate(((timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate) * 1000.0).toLong())
        #endif
    }

    public init(timeInterval: TimeInterval, since: Date) {
        #if !SKIP
        self.platformValue = PlatformDate(timeInterval: timeInterval, since: since.platformValue)
        #else
        self.init(timeIntervalSince1970: timeInterval + since.timeIntervalSince1970)
        #endif
    }

    /// Useful for converting to Java's `long` time representation
    public var currentTimeMillis: Int64 {
        #if !SKIP
        return Int64(platformValue.timeIntervalSince1970 * 1000.0)
        #else
        return platformValue.getTime()
        #endif
    }

    public var description: String {
        #if !SKIP
        return platformValue.description
        #else
        return description(with: nil)
        #endif
    }

    func description(with locale: Locale?) -> String {
        #if !SKIP
        return platformValue.description(with: locale?.platformValue)
        #else
        let fmt = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z", (locale ?? Locale.current).platformValue)
        fmt.setTimeZone(TimeZone.gmt.platformValue)
        return fmt.format(platformValue)
        #endif
    }

    public var timeIntervalSince1970: TimeInterval {
        #if !SKIP
        return platformValue.timeIntervalSince1970
        #else
        return currentTimeMillis.toDouble() / 1000.0
        #endif
    }

    public var timeIntervalSinceReferenceDate: TimeInterval {
        #if !SKIP
        return platformValue.timeIntervalSinceReferenceDate
        #else
        return timeIntervalSince1970 - Date.timeIntervalBetween1970AndReferenceDate
        #endif
    }

    public static func < (lhs: Date, rhs: Date) -> Bool {
        #if !SKIP
        lhs.platformValue.timeIntervalSince1970 < rhs.platformValue.timeIntervalSince1970
        #else
        lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
        #endif
    }

    public func timeIntervalSince(_ date: Date) -> TimeInterval {
        #if !SKIP
        return platformValue.timeIntervalSince(date.platformValue)
        #else
        return self.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
        #endif
    }

    public func addingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        #if !SKIP
        return Date(platformValue: platformValue.addingTimeInterval(timeInterval))
        #else
        return Date(timeInterval: timeInterval, since: self)
        #endif
    }

    public mutating func addTimeInterval(_ timeInterval: TimeInterval) {
        #if !SKIP
        platformValue.addTimeInterval(timeInterval)
        #else
        self = addingTimeInterval(timeInterval)
        #endif
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func ISO8601Format(_ style: PlatformISO8601FormatStyle = .iso8601) -> String {
        #if !SKIP
        return platformValue.ISO8601Format(style.platformValue)
        #else
        // TODO: use the style parameters
        // local time zone specific
        // return java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", java.util.Locale.getDefault()).format(platformValue)
        var dateFormat = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.getDefault())
        dateFormat.timeZone = java.util.TimeZone.getTimeZone("GMT")
        return dateFormat.format(platformValue)
        #endif

    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public struct ISO8601FormatStyle : Sendable {
        public static let iso8601 = ISO8601FormatStyle()

        public enum TimeZoneSeparator : String, Sendable {
            case colon
            case omitted
        }

        public enum DateSeparator : String, Sendable {
            case dash
            case omitted
        }

        public enum TimeSeparator : String, Sendable {
            case colon
            case omitted
        }

        public enum DateTimeSeparator : String, Sendable {
            case space
            case standard
        }

        public var timeSeparator: TimeSeparator
        public var includingFractionalSeconds: Bool
        public var timeZoneSeparator: TimeZoneSeparator
        public var dateSeparator: DateSeparator
        public var dateTimeSeparator: DateTimeSeparator
        public var timeZone: TimeZone

        public init(dateSeparator: DateSeparator = .dash, dateTimeSeparator: DateTimeSeparator = .standard, timeSeparator: TimeSeparator = .colon, timeZoneSeparator: TimeZoneSeparator = .omitted, includingFractionalSeconds: Bool = false, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
            self.dateSeparator = dateSeparator
            self.dateTimeSeparator = dateTimeSeparator
            self.timeSeparator = timeSeparator
            self.timeZoneSeparator = timeZoneSeparator
            self.includingFractionalSeconds = includingFractionalSeconds
            self.timeZone = timeZone
        }

        #if !SKIP
        var platformValue: Foundation.Date.ISO8601FormatStyle {
            fatalError("TODO: platformValue: Foundation.Date.ISO8601FormatStyle")
        }
        #endif
    }
}

#if SKIP
extension Date {
    public func kotlin(nocopy: Bool = false) -> java.util.Date {
        return nocopy ? platformValue : platformValue.clone() as java.util.Date
    }
}

extension java.util.Date {
    public func swift(nocopy: Bool = false) -> Date {
        let platformValue = nocopy ? self : clone() as java.util.Date
        return Date(platformValue: platformValue)
    }
}
#endif
