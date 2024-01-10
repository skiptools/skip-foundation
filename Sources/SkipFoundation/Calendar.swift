// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

// Needed to expose `clone`:
// SKIP INSERT: fun java.util.Calendar.clone(): java.util.Calendar { return this.clone() as java.util.Calendar }

public struct Calendar : Hashable, CustomStringConvertible {
    public var locale: Locale
    internal var platformValue: java.util.Calendar

    public static var current: Calendar {
        return Calendar(platformValue: java.util.Calendar.getInstance())
    }

    internal init(_ platformValue: java.util.Calendar) {
        self.platformValue = platformValue
        self.locale = Locale.current
    }

    internal init(identifier: Calendar.Identifier) {
        switch identifier {
        case .gregorian:
            self.platformValue = java.util.GregorianCalendar()
        default:
            // TODO: how to support the other calendars?
            fatalError("Skip: unsupported calendar identifier \(identifier)")
        }
        self.locale = Locale.current
    }

    internal var identifier: Calendar.Identifier {
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

    public var amSymbol: String {
        return dateFormatSymbols.getAmPmStrings()[0]
    }

    public var pmSymbol: String {
        return dateFormatSymbols.getAmPmStrings()[1]
    }

    public var eraSymbols: [String] {
        return Array(dateFormatSymbols.getEras().toList())
    }

    public var monthSymbols: [String] {
        // The java.text.DateFormatSymbols.getInstance().getMonths() method in Java returns an array of 13 symbols because it includes both the 12 months of the year and an additional symbol
        // some documentation says the blank symbol is at index 0, but other tests show it at the end, so just pare it out
        return Array(dateFormatSymbols.getMonths().toList()).filter({ $0?.isEmpty == false })
    }

    public var shortMonthSymbols: [String] {
        return Array(dateFormatSymbols.getShortMonths().toList()).filter({ $0?.isEmpty == false })
    }

    public var weekdaySymbols: [String] {
        return Array(dateFormatSymbols.getWeekdays().toList()).filter({ $0?.isEmpty == false })
    }

    public var shortWeekdaySymbols: [String] {
        return Array(dateFormatSymbols.getShortWeekdays().toList()).filter({ $0?.isEmpty == false })
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

    public func isDateInWeekend(_ date: Date) -> Bool {
        let components = dateComponents(from: date)
        return components.weekday == java.util.Calendar.SATURDAY || components.weekday == java.util.Calendar.SUNDAY
    }

    @available(*, unavailable)
    public func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        fatalError("TODO: Skip Calendar.isDate(:inSameDayAs:)")
    }

    public func isDateInToday(_ date: Date) -> Bool {
        // return isDate(date, inSameDayAs: Date())
        fatalError("TODO: Skip Calendar.isDate(:inSameDayAs:)")
    }

    public func isDateInTomorrow(_ date: Date) -> Bool {
        if let tomorrow = date(byAdding: DateComponents(day: -1), to: Date()) {
            // return isDate(date, inSameDayAs: tomorrow)
            fatalError("TODO: Skip Calendar.isDate(:inSameDayAs:)")
        } else {
            return false
        }
    }

    public func isDateInYesterday(_ date: Date) -> Bool {
        if let yesterday = date(byAdding: DateComponents(day: -1), to: Date()) {
            // return isDate(date, inSameDayAs: yesterday)
            fatalError("TODO: Skip Calendar.isDate(:inSameDayAs:)")
        } else {
            return false
        }
    }

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
    public enum Identifier : Sendable {
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
