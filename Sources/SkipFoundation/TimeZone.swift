// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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
        guard let identifier = Self.abbreviationDictionary[abbreviation] else {
            return nil
        }
        let tz = java.util.TimeZone.getTimeZone(identifier)
        if tz.getID() == "GMT" && identifier != "GMT" {
            return nil
        }
        self.platformValue = tz
    }

    public init?(secondsFromGMT seconds: Int) {
        // Seconds must be within ±18 hours (same constraint as Swift Foundation)
        guard seconds >= -18 * 3600 && seconds <= 18 * 3600 else {
            return nil
        }
        let absSeconds = abs(seconds)
        let hours = absSeconds / 3600
        let minutes = (absSeconds % 3600) / 60
        let sign = seconds >= 0 ? "+" : "-"
        let identifier = String(format: "GMT%@%02d:%02d", sign, hours, minutes)
        self.platformValue = java.util.TimeZone.getTimeZone(identifier)
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
        return Array(java.time.ZoneId.getAvailableZoneIds())
    }

    public static var knownTimeZoneNames: [String] {
        return Array(java.time.ZoneId.getAvailableZoneIds())
    }

    public static var abbreviationDictionary: [String : String] = [
        "ADT": "America/Halifax",
        "AKDT": "America/Juneau",
        "AKST": "America/Juneau",
        "ART": "America/Argentina/Buenos_Aires",
        "AST": "America/Halifax",
        "BDT": "Asia/Dhaka",
        "BRST": "America/Sao_Paulo",
        "BRT": "America/Sao_Paulo",
        "BST": "Europe/London",
        "CAT": "Africa/Harare",
        "CDT": "America/Chicago",
        "CEST": "Europe/Paris",
        "CET": "Europe/Paris",
        "COT": "America/Bogota",
        "CST": "America/Chicago",
        "EAT": "Africa/Addis_Ababa",
        "EDT": "America/New_York",
        "EEST": "Europe/Athens",
        "EET": "Europe/Athens",
        "EST": "America/New_York",
        "GMT": "GMT",
        "GST": "Asia/Dubai",
        "HKT": "Asia/Hong_Kong",
        "HST": "Pacific/Honolulu",
        "ICT": "Asia/Bangkok",
        "IRST": "Asia/Tehran",
        "IST": "Asia/Calcutta",
        "JST": "Asia/Tokyo",
        "KST": "Asia/Seoul",
        "MDT": "America/Denver",
        "MEST": "Europe/Paris",
        "MET": "Europe/Paris",
        "MSK": "Europe/Moscow",
        "MST": "America/Denver",
        "MYT": "Asia/Kuala_Lumpur",
        "NDT": "America/St_Johns",
        "NST": "America/St_Johns",
        "NZDT": "Pacific/Auckland",
        "NZST": "Pacific/Auckland",
        "PDT": "America/Los_Angeles",
        "PET": "America/Lima",
        "PHT": "Asia/Manila",
        "PKT": "Asia/Karachi",
        "PST": "America/Los_Angeles",
        "SGT": "Asia/Singapore",
        "SST": "Pacific/Pago_Pago",
        "UTC": "UTC",
        "WAT": "Africa/Lagos",
        "WEST": "Europe/Lisbon",
        "WET": "Europe/Lisbon",
    ]

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
