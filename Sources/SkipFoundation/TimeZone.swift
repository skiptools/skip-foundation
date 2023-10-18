// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.TimeZone
@_implementationOnly import class Foundation.NSTimeZone
internal typealias PlatformTimeZone = Foundation.TimeZone
#else
public typealias NSTimeZone = TimeZone
public typealias PlatformTimeZone = java.util.TimeZone
#endif

public struct TimeZone : Hashable, CustomStringConvertible, Sendable {
    internal var platformValue: PlatformTimeZone

    public static var current: TimeZone {
        #if !SKIP
        return TimeZone(platformValue: PlatformTimeZone.current)
        #else
        return TimeZone(platformValue: PlatformTimeZone.getDefault())
        #endif
    }

    public static var `default`: TimeZone {
        get {
            #if !SKIP
            return TimeZone(platformValue: NSTimeZone.default)
            #else
            return TimeZone(platformValue: PlatformTimeZone.getDefault())
            #endif
        }

        set {
            #if !SKIP
            NSTimeZone.default = newValue.platformValue
            #else
            PlatformTimeZone.setDefault(newValue.platformValue)
            #endif
        }
    }

    public static var system: TimeZone {
        #if !SKIP
        return TimeZone(platformValue: PlatformTimeZone.current)
        #else
        return TimeZone(platformValue: PlatformTimeZone.getDefault())
        #endif
    }
    
    public static var local: TimeZone {
        #if !SKIP
        return TimeZone(platformValue: PlatformTimeZone.current)
        #else
        return TimeZone(platformValue: PlatformTimeZone.getDefault())
        #endif
    }

    public static var autoupdatingCurrent: TimeZone {
        #if !SKIP
        return TimeZone(platformValue: .autoupdatingCurrent)
        #else
        return TimeZone(platformValue: PlatformTimeZone.getDefault())
        #endif
    }

    public static var gmt: TimeZone {
        #if !SKIP
        return TimeZone(platformValue: PlatformTimeZone.gmt)
        #else
        return TimeZone(platformValue: PlatformTimeZone.getTimeZone("GMT"))
        #endif
    }

    internal init(platformValue: PlatformTimeZone) {
        self.platformValue = platformValue
    }

    public init?(identifier: String) {
        #if !SKIP
        guard let tz = PlatformTimeZone(identifier: identifier) else {
            return nil
        }
        self.platformValue = tz
        #else
        guard let tz = PlatformTimeZone.getTimeZone(identifier) else {
            return nil
        }
        self.platformValue = tz
        #endif
    }

    public init?(abbreviation: String) {
        #if !SKIP
        guard let tz = PlatformTimeZone(abbreviation: abbreviation) else {
            return nil
        }
        self.platformValue = tz
        #else
        guard let identifier = Self.abbreviationDictionary[abbreviation] else {
        }
        guard let tz = PlatformTimeZone.getTimeZone(identifier) else {
            return nil
        }
        self.platformValue = tz
        #endif
    }

    public init?(secondsFromGMT seconds: Int) {
        #if !SKIP
        guard let tz = PlatformTimeZone(secondsFromGMT: seconds) else {
            return nil
        }
        self.platformValue = tz
        #else
        // java.time.ZoneId is more modern, but doesn't seem to be able to vend a java.util.TimeZone
        // guard let tz = PlatformTimeZone.getTimeZone(java.time.ZoneId.ofOffset(seconds))

        //let timeZoneId = seconds >= 0
        //    ? String.format("GMT+%02d:%02d", seconds / 3600, (seconds % 3600) / 60)
        //    : String.format("GMT-%02d:%02d", -seconds / 3600, (-seconds % 3600) / 60)
        //guard let tz = PlatformTimeZone.getTimeZone(timeZoneId) else {
        //    return nil
        //}

        self.platformValue = java.util.SimpleTimeZone(seconds, "GMT")
        #endif
    }

    public var identifier: String {
        #if !SKIP
        return platformValue.identifier
        #else
        return platformValue.getID()
        #endif
    }

    public func abbreviation(for date: Date = Date()) -> String? {
        #if !SKIP
        return platformValue.abbreviation(for: date.platformValue)
        #else
        return platformValue.getDisplayName(true, PlatformTimeZone.SHORT)
        #endif
    }

    public func secondsFromGMT(for date: Date = Date()) -> Int {
        #if !SKIP
        return platformValue.secondsFromGMT(for: date.platformValue)
        #else
        return platformValue.getOffset(date.currentTimeMillis) / 1000 // offset is in milliseconds
        #endif
    }

    public var description: String {
        return platformValue.description
    }

    public func isDaylightSavingTime(for date: Date = Date()) -> Bool {
        #if !SKIP
        return platformValue.isDaylightSavingTime(for: date.platformValue)
        #else
        return platformValue.toZoneId().rules.isDaylightSavings(java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId()).toInstant())
        #endif
    }

    public func daylightSavingTimeOffset(for date: Date = Date()) -> TimeInterval {
        #if !SKIP
        return platformValue.daylightSavingTimeOffset(for: date.platformValue)
        #else
        return isDaylightSavingTime(for: date) ? java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId()).offset.getTotalSeconds().toDouble() : 0.0
        #endif
    }

    public var nextDaylightSavingTimeTransition: Date? {
        #if !SKIP
        return platformValue.nextDaylightSavingTimeTransition.flatMap(Date.init(platformValue:))
        #else
        return nextDaylightSavingTimeTransition(after: Date())
        #endif
    }

    public func nextDaylightSavingTimeTransition(after date: Date) -> Date? {
        #if !SKIP
        return platformValue.nextDaylightSavingTimeTransition(after: date.platformValue).flatMap(Date.init(platformValue:))
        #else
        // testSkipModule(): java.lang.NullPointerException: Cannot invoke "java.time.zone.ZoneOffsetTransition.getInstant()" because the return value of "java.time.zone.ZoneRules.nextTransition(java.time.Instant)" is null
        let zonedDateTime = java.time.ZonedDateTime.ofInstant(date.platformValue.toInstant(), platformValue.toZoneId())
        guard let transition = platformValue.toZoneId().rules.nextTransition(zonedDateTime.toInstant()) else {
            return nil
        }
        return Date(platformValue: java.util.Date.from(transition.getInstant()))
        #endif
    }

    public static var knownTimeZoneIdentifiers: [String] {
        #if !SKIP
        return PlatformTimeZone.knownTimeZoneIdentifiers
        #else
        return Array(java.time.ZoneId.getAvailableZoneIds())
        #endif
    }

    public static var knownTimeZoneNames: [String] {
        #if !SKIP
        return NSTimeZone.knownTimeZoneNames
        #else
        return Array(java.time.ZoneId.getAvailableZoneIds())
        #endif
    }

    #if !SKIP
    public static var abbreviationDictionary: [String : String] {
        get {
            return PlatformTimeZone.abbreviationDictionary
        }

        set {
            return PlatformTimeZone.abbreviationDictionary = newValue
        }
    }
    #else
    public static var abbreviationDictionary: [String : String] = [:]
    #endif

    public static var timeZoneDataVersion: String {
        #if !SKIP
        return PlatformTimeZone.timeZoneDataVersion
        #else
        fatalError("TODO: TimeZone")
        #endif
    }

    public func localizedName(for style: NameStyle, locale: Locale?) -> String? {
        #if !SKIP
        return platformValue.localizedName(for: .init(rawValue: style.rawValue)!, locale: locale?.platformValue)
        #else
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
        #endif
    }

    public enum NameStyle : Int {
        case standard = 0
        case shortStandard = 1
        case daylightSaving = 2
        case shortDaylightSaving = 3
        case generic = 4
        case shortGeneric = 5
    }
}

#if SKIP
extension TimeZone {
    public func kotlin(nocopy: Bool = false) -> java.util.TimeZone {
        return nocopy ? platformValue : platformValue.clone() as java.util.TimeZone
    }
}

extension java.util.TimeZone {
    public func swift(nocopy: Bool = false) -> TimeZone {
        let platformValue = nocopy ? self : clone() as java.util.TimeZone
        return TimeZone(platformValue: platformValue)
    }
}
#endif
