// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
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
        let tz = java.util.TimeZone.getTimeZone(identifier)
        // Java's getTimeZone() returns a timezone with ID "GMT" for unknown identifiers;
        // if the result is GMT but the requested identifier wasn't "GMT", it means the
        // identifier was not recognized.
        if tz.getID() == "GMT" && identifier != "GMT" {
            return nil
        }
        self.platformValue = tz
    }

    public init?(abbreviation: String) {
        guard let identifier = Self.abbreviationDictionary[abbreviation], let timeZone = TimeZone(identifier: identifier) else {
            return nil
        }
        self.platformValue = timeZone.platformValue
    }

    public init?(secondsFromGMT seconds: Int) {
        // Foundation accepts offsets within 18 hours of GMT, including partial minutes.
        guard seconds >= -18 * 3600 && seconds <= 18 * 3600 else {
            return nil
        }
        // Round only the identifier to the nearest minute, preserving the exact offset.
        let totalMinutes = (abs(seconds) + 30) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let sign = seconds >= 0 ? "+" : "-"
        let identifier = totalMinutes == 0 ? "GMT" : String(format: "GMT%@%02d:%02d", sign, hours, minutes)
        self.platformValue = java.util.SimpleTimeZone(seconds * 1000, identifier)
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
        return platformValue.getDisplayName(isDaylightSavingTime(for: date), java.util.TimeZone.SHORT)
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
        // Match the provider used by init(identifier:). On Android, java.time also
        // advertises legacy aliases that java.util.TimeZone does not recognize.
        return Array(java.util.TimeZone.getAvailableIDs().toList())
    }

    public static var knownTimeZoneNames: [String] {
        return knownTimeZoneIdentifiers
    }

    public static var abbreviationDictionary: [String : String] = {
        var abbreviations: [String : String] = [:]
        // Abbreviations are ambiguous. Keep the first identifier in sorted order so
        // the mapping is stable, and use English names regardless of the device locale.
        for identifier in knownTimeZoneIdentifiers.sorted() {
            let timeZone = java.util.TimeZone.getTimeZone(identifier)
            let standard = timeZone.getDisplayName(false, java.util.TimeZone.SHORT, java.util.Locale.US)
            if abbreviations[standard] == nil {
                abbreviations[standard] = identifier
            }
            if timeZone.useDaylightTime() {
                let daylight = timeZone.getDisplayName(true, java.util.TimeZone.SHORT, java.util.Locale.US)
                if abbreviations[daylight] == nil {
                    abbreviations[daylight] = identifier
                }
            }
        }
        return abbreviations
    }()

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
