// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSTimeZone = TimeZone

public struct TimeZone : Hashable, Codable, CustomStringConvertible, Sendable, KotlinConverting<java.util.TimeZone> {
    internal var platformValue: java.util.TimeZone

    public static var current: TimeZone {
        return TimeZone(platformValue: java.util.TimeZone.getDefault())
    }

    public static var `default`: TimeZone {
        get {
            return TimeZone(platformValue: java.util.TimeZone.getDefault())
        }

        set {
            java.util.TimeZone.setDefault(newValue.platformValue)
        }
    }

    public static var system: TimeZone {
        return TimeZone(platformValue: java.util.TimeZone.getDefault())
    }
    
    public static var local: TimeZone {
        return TimeZone(platformValue: java.util.TimeZone.getDefault())
    }

    public static var autoupdatingCurrent: TimeZone {
        return TimeZone(platformValue: java.util.TimeZone.getDefault())
    }

    public static var gmt: TimeZone {
        return TimeZone(platformValue: java.util.TimeZone.getTimeZone("GMT"))
    }

    public init(platformValue: java.util.TimeZone) {
        self.platformValue = platformValue
    }

    public init?(identifier: String) {
        guard let tz = java.util.TimeZone.getTimeZone(identifier) else {
            return nil
        }
        self.platformValue = tz
    }

    public init?(abbreviation: String) {
        guard let identifier = Self.abbreviationDictionary[abbreviation] else {
        }
        guard let tz = java.util.TimeZone.getTimeZone(identifier) else {
            return nil
        }
        self.platformValue = tz
    }

    public init?(secondsFromGMT seconds: Int) {
        // java.time.ZoneId is more modern, but doesn't seem to be able to vend a java.util.TimeZone
        // guard let tz = PlatformTimeZone.getTimeZone(java.time.ZoneId.ofOffset(seconds))

        //let timeZoneId = seconds >= 0
        //    ? String.format("GMT+%02d:%02d", seconds / 3600, (seconds % 3600) / 60)
        //    : String.format("GMT-%02d:%02d", -seconds / 3600, (-seconds % 3600) / 60)
        //guard let tz = PlatformTimeZone.getTimeZone(timeZoneId) else {
        //    return nil
        //}

        self.platformValue = java.util.SimpleTimeZone(seconds, "GMT")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(String.self)
        self.platformValue = java.util.TimeZone.getTimeZone(identifier)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }

    public var identifier: String {
        return platformValue.getID()
    }

    public func abbreviation(for date: Date = Date()) -> String? {
        return platformValue.getDisplayName(true, java.util.TimeZone.SHORT)
    }

    public func secondsFromGMT(for date: Date = Date()) -> Int {
        return platformValue.getOffset(date.currentTimeMillis) / 1000 // offset is in milliseconds
    }

    public var description: String {
        return platformValue.description
    }

    public func isDaylightSavingTime(for date: Date = Date()) -> Bool {
        return platformValue.toZoneId().rules.isDaylightSavings(java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId()).toInstant())
    }

    public func daylightSavingTimeOffset(for date: Date = Date()) -> TimeInterval {
        return isDaylightSavingTime(for: date) ? java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId()).offset.getTotalSeconds().toDouble() : 0.0
    }

    public var nextDaylightSavingTimeTransition: Date? {
        return nextDaylightSavingTimeTransition(after: Date())
    }

    public func nextDaylightSavingTimeTransition(after date: Date) -> Date? {
        // testSkipModule(): java.lang.NullPointerException: Cannot invoke "java.time.zone.ZoneOffsetTransition.getInstant()" because the return value of "java.time.zone.ZoneRules.nextTransition(java.time.Instant)" is null
        let zonedDateTime = java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId())
        guard let transition = platformValue.toZoneId().rules.nextTransition(zonedDateTime.toInstant()) else {
            return nil
        }
        return Date(platformValue: java.util.Date.from(transition.getInstant()))
    }

    public static var knownTimeZoneIdentifiers: [String] {
        return Array(java.time.ZoneId.getAvailableZoneIds())
    }

    public static var knownTimeZoneNames: [String] {
        return Array(java.time.ZoneId.getAvailableZoneIds())
    }

    public static var abbreviationDictionary: [String : String] = [:]

    @available(*, unavailable)
    public static var timeZoneDataVersion: String {
        fatalError("TODO: TimeZone")
    }

    public func localizedName(for style: NameStyle, locale: Locale?) -> String? {
        switch style {
        case .generic:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.FULL, locale?.platformValue)
        case .standard:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.FULL_STANDALONE, locale?.platformValue)
        case .shortStandard:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.SHORT_STANDALONE, locale?.platformValue)
        case .daylightSaving:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.FULL, locale?.platformValue)
        case .shortDaylightSaving:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.SHORT, locale?.platformValue)
        case .shortGeneric:
            return platformValue.toZoneId().getDisplayName(java.time.format.TextStyle.SHORT, locale?.platformValue)
        }
    }

    public enum NameStyle : Int {
        case standard = 0
        case shortStandard = 1
        case daylightSaving = 2
        case shortDaylightSaving = 3
        case generic = 4
        case shortGeneric = 5
    }

    public override func kotlin(nocopy: Bool = false) -> java.util.TimeZone {
        return nocopy ? platformValue : platformValue.clone() as java.util.TimeZone
    }
}

#endif
