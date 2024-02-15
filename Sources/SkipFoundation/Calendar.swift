// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

// Needed to expose `clone`:
// SKIP INSERT: fun java.util.Calendar.clone(): java.util.Calendar { return this.clone() as java.util.Calendar }

public struct Calendar : Hashable, Codable, CustomStringConvertible {
    internal var platformValue: java.util.Calendar

    public static var current: Calendar {
        return Calendar(platformValue: java.util.Calendar.getInstance())
    }

    @available(*, unavailable)
    public static var autoupdatingCurrent: Calendar {
        fatalError()
    }

    private static func platformValue(for identifier: Calendar.Identifier) -> java.util.Calendar {
        switch identifier {
        case .gregorian:
            return java.util.GregorianCalendar()
        case .iso8601:
            return java.util.Calendar.getInstance()
        default:
            // TODO: how to support the other calendars?
            return java.util.Calendar.getInstance()
        }
    }

    public init(_ platformValue: java.util.Calendar) {
        self.platformValue = platformValue
        self.locale = Locale.current
    }

    public init(identifier: Calendar.Identifier) {
        self.platformValue = Self.platformValue(for: identifier)
        self.locale = Locale.current
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let identifier = try container.decode(Calendar.Identifier.self)
        self.platformValue = Self.platformValue(for: identifier)
        self.locale = Locale.current
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }

    public var locale: Locale

    public var timeZone: TimeZone {
        get {
            return TimeZone(platformValue.getTimeZone())
        }
        set {
            platformValue.setTimeZone(newValue.platformValue)
        }
    }

    public var description: String {
        return platformValue.description
    }

    public var identifier: Calendar.Identifier {
        // TODO: non-gregorian calendar
        if gregorianCalendar != nil {
            return Calendar.Identifier.gregorian
        } else {
            return Calendar.Identifier.iso8601
        }
    }

    internal func toDate() -> Date {
        Date(platformValue: platformValue.getTime())
    }

    private var dateFormatSymbols: java.text.DateFormatSymbols {
        java.text.DateFormatSymbols.getInstance(locale.platformValue)
    }

    private var gregorianCalendar: java.util.GregorianCalendar? {
        return platformValue as? java.util.GregorianCalendar
    }

    @available(*, unavailable)
    public var firstWeekday: Int {
        fatalError()
    }

    @available(*, unavailable)
    public var minimumDaysInFirstWeek: Int {
        fatalError()
    }

    public var eraSymbols: [String] {
        return Array(dateFormatSymbols.getEras().toList())
    }

    @available(*, unavailable)
    public var longEraSymbols: [String] {
        fatalError()
    }

    public var monthSymbols: [String] {
        // The java.text.DateFormatSymbols.getInstance().getMonths() method in Java returns an array of 13 symbols because it includes both the 12 months of the year and an additional symbol
        // some documentation says the blank symbol is at index 0, but other tests show it at the end, so just pare it out
        return Array(dateFormatSymbols.getMonths().toList()).filter({ $0?.isEmpty == false })
    }

    public var shortMonthSymbols: [String] {
        return Array(dateFormatSymbols.getShortMonths().toList()).filter({ $0?.isEmpty == false })
    }

    @available(*, unavailable)
    public var veryShortMonthSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var standaloneMonthSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var shortStandaloneMonthSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var veryShortStandaloneMonthSymbols: [String] {
        fatalError()
    }

    public var weekdaySymbols: [String] {
        return Array(dateFormatSymbols.getWeekdays().toList()).filter({ $0?.isEmpty == false })
    }

    public var shortWeekdaySymbols: [String] {
        return Array(dateFormatSymbols.getShortWeekdays().toList()).filter({ $0?.isEmpty == false })
    }

    @available(*, unavailable)
    public var veryShortWeekdaySymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var standaloneWeekdaySymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var shortStandaloneWeekdaySymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var veryShortStandaloneWeekdaySymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var quarterSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var shortQuarterSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var standaloneQuarterSymbols: [String] {
        fatalError()
    }

    @available(*, unavailable)
    public var shortStandaloneQuarterSymbols: [String] {
        fatalError()
    }

    public var amSymbol: String {
        return dateFormatSymbols.getAmPmStrings()[0]
    }

    public var pmSymbol: String {
        return dateFormatSymbols.getAmPmStrings()[1]
    }

    @available(*, unavailable)
    public func minimumRange(of component: Calendar.Component) -> Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public func maximumRange(of component: Calendar.Component) -> Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public func range(of smaller: Calendar.Component, in larger: Calendar.Component, for date: Date) -> Range<Int>? {
        fatalError()
    }

    @available(*, unavailable)
    public func dateInterval(of component: Calendar.Component, start: inout Date, interval: inout TimeInterval, for date: Date) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func dateInterval(of component: Calendar.Component, for date: Date) -> DateInterval? {
        fatalError()
    }

    @available(*, unavailable)
    public func ordinality(of smaller: Calendar.Component, in larger: Calendar.Component, for date: Date) -> Int? {
        fatalError()
    }

    public func date(from components: DateComponents) -> Date? {
        // TODO: Need to set `this` calendar in the components.calendar
        return Date(platformValue: components.createCalendarComponents().getTime())
    }

    public func dateComponents(in zone: TimeZone? = nil, from date: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: zone ?? self.timeZone, from: date)
    }

    public func dateComponents(_ components: Set<Calendar.Component>, from start: Date, to end: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: nil, from: start, to: end)
    }

    public func dateComponents(_ components: Set<Calendar.Component>, from date: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: nil, from: date, with: components)
    }

    public func date(byAdding components: DateComponents, to date: Date, wrappingComponents: Bool = false) -> Date? {
        var comps = DateComponents(fromCalendar: self, in: self.timeZone, from: date)
        comps.add(components)
        return date(from: comps)
    }

    public func date(byAdding component: Calendar.Component, value: Int, to date: Date, wrappingComponents: Bool = false) -> Date? {
        var comps = DateComponents(fromCalendar: self, in: self.timeZone, from: date)
        comps.addValue(value, for: component)
        return date(from: comps)
    }

    @available(*, unavailable)
    public func component(_ component: Calendar.Component, from date: Date) -> Int {
        fatalError()
    }

    @available(*, unavailable)
    public func startOfDay(for date: Date) -> Date {
        fatalError()
    }

    @available(*, unavailable)
    public func compare(_ date1: Date, to date2: Date, toGranularity component: Calendar.Component) -> ComparisonResult {
        fatalError()
    }

    @available(*, unavailable)
    public func isDate(_ date1: Date, equalTo date2: Date, toGranularity component: Calendar.Component) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func isDateInToday(_ date: Date) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func isDateInYesterday(_ date: Date) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func isDateInTomorrow(_ date: Date) -> Bool {
        fatalError()
    }

    public func isDateInWeekend(_ date: Date) -> Bool {
        let components = dateComponents(from: date)
        return components.weekday == java.util.Calendar.SATURDAY || components.weekday == java.util.Calendar.SUNDAY
    }

    @available(*, unavailable)
    public func dateIntervalOfWeekend(containing date: Date, start: inout Date, interval: inout TimeInterval) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func dateIntervalOfWeekend(containing date: Date) -> DateInterval? {
        fatalError()
    }

    @available(*, unavailable)
    public func nextWeekend(startingAfter date: Date, start: inout Date, interval: inout TimeInterval, direction: Calendar.SearchDirection = .forward) -> Bool {
        fatalError()
    }

    @available(*, unavailable)
    public func nextWeekend(startingAfter date: Date, direction: Calendar.SearchDirection = .forward) -> DateInterval? {
        fatalError()
    }

    @available(*, unavailable)
    public func enumerateDates(startingAfter start: Date, matching components: DateComponents, matchingPolicy: Calendar.MatchingPolicy, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward, using block: (_ result: Date?, _ exactMatch: Bool, _ stop: inout Bool) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    public func nextDate(after date: Date, matching components: DateComponents, matchingPolicy: Calendar.MatchingPolicy, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward) -> Date? {
        fatalError()
    }

    @available(*, unavailable)
    public func date(bySetting component: Calendar.Component, value: Int, of date: Date) -> Date? {
        fatalError()
    }

    @available(*, unavailable)
    public func date(bySettingHour hour: Int, minute: Int, second: Int, of date: Date, matchingPolicy: Calendar.MatchingPolicy = .nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward) -> Date? {
        fatalError()
    }

    @available(*, unavailable)
    public func date(_ date: Date, matchesComponents components: DateComponents) -> Bool {
        fatalError()
    }

    public enum Component: Sendable {
        case era
        case year
        case month
        case day
        case hour
        case minute
        case second
        case weekday
        case weekdayOrdinal
        case quarter
        case weekOfMonth
        case weekOfYear
        case yearForWeekOfYear
        case nanosecond
        case calendar
        case timeZone
    }

    /// Calendar supports many different kinds of calendars. Each is identified by an identifier here.
    public enum Identifier : Int, Codable, Sendable {
        /// The common calendar in Europe, the Western Hemisphere, and elsewhere.
        case gregorian
        case buddhist
        case chinese
        case coptic
        case ethiopicAmeteMihret
        case ethiopicAmeteAlem
        case hebrew
        case iso8601
        case indian
        case islamic
        case islamicCivil
        case japanese
        case persian
        case republicOfChina
        case islamicTabular
        case islamicUmmAlQura
    }

    public enum SearchDirection : Sendable {
        case forward
        case backward
    }

    public enum RepeatedTimePolicy : Sendable {
        case first
        case last
    }

    public enum MatchingPolicy : Sendable {
        case nextTime
        case nextTimePreservingSmallerComponents
        case previousTimePreservingSmallerComponents
        case strict
    }
}

extension Calendar: KotlinConverting<java.util.Calendar> {
    public override func kotlin(nocopy: Bool = false) -> java.util.Calendar {
        return nocopy ? platformValue : platformValue.clone() as java.util.Calendar
    }
}

// Shims for testing
internal class NSCalendar : NSObject {
    struct Options {
    }

    enum Unit {
        case era
        case year
        case month
        case day
        case hour
        case minute
        case second
        case weekday
        case weekdayOrdinal
        case quarter
        case weekOfMonth
        case weekOfYear
        case yearForWeekOfYear
        case nanosecond
        case calendar
        case timeZone
    }

    enum Identifier {
        case gregorian
        case buddhist
        case chinese
        case coptic
        case ethiopicAmeteMihret
        case ethiopicAmeteAlem
        case hebrew
        case ISO8601
        case indian
        case islamic
        case islamicCivil
        case japanese
        case persian
        case republicOfChina
        case islamicTabular
        case islamicUmmAlQura
    }
}

#endif
