// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSDate = Date
public typealias TimeInterval = Double
public typealias CFTimeInterval = TimeInterval

// Mimic the constructor for `TimeInterval()` with an Int.
public func TimeInterval(_ seconds: Int) -> TimeInterval {
    return seconds.toDouble()
}

public typealias CFAbsoluteTime = CFTimeInterval

public func CFAbsoluteTimeGetCurrent() -> CFAbsoluteTime {
    Date.timeIntervalSinceReferenceDate
}

public struct Date : Hashable, CustomStringConvertible, Comparable, Codable {
    internal var platformValue: java.util.Date

    public static let timeIntervalBetween1970AndReferenceDate: TimeInterval = 978307200.0

    public static var timeIntervalSinceReferenceDate: TimeInterval {
        (System.currentTimeMillis().toDouble() / 1000.0) - timeIntervalBetween1970AndReferenceDate
    }

    public static let distantPast = Date(timeIntervalSince1970: -62135769600.0)
    public static let distantFuture = Date(timeIntervalSince1970: 64092211200.0)

    public static var now: Date { Date() }
    
    public init() {
        self.platformValue = java.util.Date()
    }

    public init(platformValue: java.util.Date) {
        self.platformValue = platformValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timeIntervalSinceReferenceDate = try container.decode(Double.self)
        self.platformValue = java.util.Date(((timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate) * 1000.0).toLong())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.timeIntervalSinceReferenceDate)
    }

    // We don't support initializing doubles from int literals in Kotlin, so add a constructor that lets people do things like `Date(timeIntervalSince1970: 1449332351)`.
    public init(timeIntervalSince1970: Int) {
        self.platformValue = java.util.Date((Double(timeIntervalSince1970) * 1000.0).toLong())
    }

    // We don't support initializing doubles from int literals in Kotlin, so add a constructor that lets people do things like `Date(timeIntervalSince1970: 1449332351)`.
    public init(timeIntervalSinceReferenceDate: Int) {
        self.platformValue = java.util.Date(((Double(timeIntervalSinceReferenceDate) + Date.timeIntervalBetween1970AndReferenceDate) * 1000.0).toLong())
    }

    public init(timeIntervalSince1970: TimeInterval) {
        self.platformValue = java.util.Date((timeIntervalSince1970 * 1000.0).toLong())
    }

    public init(timeIntervalSinceReferenceDate: TimeInterval) {
        self.platformValue = java.util.Date(((timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate) * 1000.0).toLong())
    }

    public init(timeInterval: TimeInterval, since: Date) {
        self.init(timeIntervalSince1970: timeInterval + since.timeIntervalSince1970)
    }

    /// Useful for converting to Java's `long` time representation
    public var currentTimeMillis: Int64 {
        return platformValue.getTime()
    }

    public var description: String {
        return description(with: nil)
    }

    func description(with locale: Locale?) -> String {
        let fmt = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z", (locale ?? Locale.current).platformValue)
        fmt.setTimeZone(TimeZone.gmt.platformValue)
        return fmt.format(platformValue)
    }

    public var timeIntervalSince1970: TimeInterval {
        return currentTimeMillis.toDouble() / 1000.0
    }

    public var timeIntervalSinceReferenceDate: TimeInterval {
        return timeIntervalSince1970 - Date.timeIntervalBetween1970AndReferenceDate
    }

    public static func < (lhs: Date, rhs: Date) -> Bool {
        lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
    }

    public func timeIntervalSince(_ date: Date) -> TimeInterval {
        return self.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
    }

    public func addingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        return Date(timeInterval: timeInterval, since: self)
    }

    public mutating func addTimeInterval(_ timeInterval: TimeInterval) {
        self = addingTimeInterval(timeInterval)
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func ISO8601Format(_ style: Date.ISO8601FormatStyle = .iso8601) -> String {

        // TODO: use the style parameters
        // local time zone specific
        // return java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", java.util.Locale.getDefault()).format(platformValue)
        var dateFormat = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", java.util.Locale.getDefault())
        dateFormat.timeZone = java.util.TimeZone.getTimeZone("GMT")
        return dateFormat.format(platformValue)
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
    }
}

extension Date: KotlinConverting<java.util.Date> {
    public override func kotlin(nocopy: Bool = false) -> java.util.Date {
        return nocopy ? platformValue : platformValue.clone() as java.util.Date
    }
}

#endif
