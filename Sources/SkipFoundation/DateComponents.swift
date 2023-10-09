// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Note: !SKIP code paths used to validate implementation only.
// Not used in applications. See contribution guide for details.
#if !SKIP
@_implementationOnly import struct Foundation.DateComponents
internal typealias PlatformDateComponents = Foundation.DateComponents
#else
public typealias NSDateComponents = DateComponents
#endif

/// A date or time specified in terms of units (such as year, month, day, hour, and minute) to be evaluated in a calendar system and time zone.
public struct DateComponents : Hashable, CustomStringConvertible {
    #if !SKIP
    internal var components: PlatformDateComponents

    internal var platformValue: PlatformDateComponents {
        components
    }

    public var calendar: Calendar? {
        get { components.calendar.flatMap(Calendar.init(platformValue:)) }
        set { components.calendar = newValue?.platformValue }
    }
    public var timeZone: TimeZone? {
        get { components.timeZone.flatMap(TimeZone.init(platformValue:)) }
        set { components.timeZone = newValue?.platformValue }
    }
    public var era: Int? {
        get { components.era }
        set { components.era = newValue }
    }
    public var year: Int? {
        get { components.year }
        set { components.year = newValue }
    }
    public var month: Int? {
        get { components.month }
        set { components.month = newValue }
    }
    public var day: Int? {
        get { components.day }
        set { components.day = newValue }
    }
    public var hour: Int? {
        get { components.hour }
        set { components.hour = newValue }
    }
    public var minute: Int? {
        get { components.minute }
        set { components.minute = newValue }
    }
    public var second: Int? {
        get { components.second }
        set { components.second = newValue }
    }
    public var nanosecond: Int? {
        get { components.nanosecond }
        set { components.nanosecond = newValue }
    }
    public var weekday: Int? {
        get { components.weekday }
        set { components.weekday = newValue }
    }
    public var weekdayOrdinal: Int? {
        get { components.weekdayOrdinal }
        set { components.weekdayOrdinal = newValue }
    }
    public var quarter: Int? {
        get { components.quarter }
        set { components.quarter = newValue }
    }
    public var weekOfMonth: Int? {
        get { components.weekOfMonth }
        set { components.weekOfMonth = newValue }
    }
    public var weekOfYear: Int? {
        get { components.weekOfYear }
        set { components.weekOfYear = newValue }
    }
    public var yearForWeekOfYear: Int? {
        get { components.yearForWeekOfYear }
        set { components.yearForWeekOfYear = newValue }
    }

    internal init(components: PlatformDateComponents) {
        self.components = components
    }
    #else

    // There is no direct analogue to DateComponents in Java (other then java.util.Calendar), so we store the individual properties here

    public var calendar: Calendar? = nil
    public var timeZone: TimeZone? = nil
    public var era: Int? = nil
    public var year: Int? = nil
    public var month: Int? = nil
    public var day: Int? = nil
    public var hour: Int? = nil
    public var minute: Int? = nil
    public var second: Int? = nil
    public var nanosecond: Int? = nil
    public var weekday: Int? = nil
    public var weekdayOrdinal: Int? = nil
    public var quarter: Int? = nil
    public var weekOfMonth: Int? = nil
    public var weekOfYear: Int? = nil
    public var yearForWeekOfYear: Int? = nil
    #endif

    public init(calendar: Calendar? = nil, timeZone: TimeZone? = nil, era: Int? = nil, year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil, weekday: Int? = nil, weekdayOrdinal: Int? = nil, quarter: Int? = nil, weekOfMonth: Int? = nil, weekOfYear: Int? = nil, yearForWeekOfYear: Int? = nil) {
        #if !SKIP
        self.components = PlatformDateComponents(calendar: calendar?.platformValue, timeZone: timeZone?.platformValue, era: era, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: weekday, weekdayOrdinal: weekdayOrdinal, quarter: quarter, weekOfMonth: weekOfMonth, weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear)
        #else
        self.calendar = calendar
        self.timeZone = timeZone
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
        self.nanosecond = nanosecond
        self.weekday = weekday
        self.weekdayOrdinal = weekdayOrdinal
        self.quarter = quarter
        self.weekOfMonth = weekOfMonth
        self.weekOfYear = weekOfYear
        self.yearForWeekOfYear = yearForWeekOfYear
        #endif
    }

    #if SKIP
    internal init(fromCalendar calendar: Calendar, in zone: TimeZone? = nil, from date: Date? = nil, to endDate: Date? = nil, with components: Set<PlatformCalendarComponent>? = nil) {
        let platformCal = calendar.platformValue.clone() as PlatformCalendar

        if let date = date {
            platformCal.time = date.platformValue
        }

        if let zone = zone {
            platformCal.timeZone = zone.platformValue
        }

        if components?.contains(.era) != false {
            if let endDate = endDate {
                // TODO: if components.contains(.year) { dc.year = Int(ucal_getFieldDifference(ucalendar, goal, UCAL_YEAR, &status)) }
                fatalError("TODO: Skip DateComponents field differences")
            } else {
                self.era = platformCal.get(PlatformCalendar.ERA)
            }
        }
        if components?.contains(.year) != false {
            self.year = platformCal.get(PlatformCalendar.YEAR)
        }
        if components?.contains(.month) != false {
            self.month = platformCal.get(PlatformCalendar.MONTH) + 1
        }
        if components?.contains(.day) != false {
            self.day = platformCal.get(PlatformCalendar.DATE) // i.e., DAY_OF_MONTH
        }
        if components?.contains(.hour) != false {
            self.hour = platformCal.get(PlatformCalendar.HOUR_OF_DAY)
        }
        if components?.contains(.minute) != false {
            self.minute = platformCal.get(PlatformCalendar.MINUTE)
        }
        if components?.contains(.second) != false {
            self.second = platformCal.get(PlatformCalendar.SECOND)
        }
        if components?.contains(.weekday) != false {
            self.weekday = platformCal.get(PlatformCalendar.DAY_OF_WEEK)
        }
        if components?.contains(.weekOfMonth) != false {
            self.weekOfMonth = platformCal.get(PlatformCalendar.WEEK_OF_MONTH)
        }
        if components?.contains(.weekOfYear) != false {
            self.weekOfYear = platformCal.get(PlatformCalendar.WEEK_OF_YEAR)
        }

        // unsupported fields in java.util.Calendar:
        //self.nanosecond = platformCal.get(PlatformCalendar.NANOSECOND)
        //self.weekdayOrdinal = platformCal.get(PlatformCalendar.WEEKDAYORDINAL)
        //self.quarter = platformCal.get(PlatformCalendar.QUARTER)
        //self.yearForWeekOfYear = platformCal.get(PlatformCalendar.YEARFORWEEKOFYEAR)
    }

    /// Builds a java.util.Calendar from the fields.
    internal func createCalendarComponents() -> PlatformCalendar {
        let c: PlatformCalendar = (self.calendar?.platformValue ?? PlatformCalendar.getInstance())
        let cal: PlatformCalendar = (c as java.util.Calendar).clone() as PlatformCalendar

        cal.setTimeInMillis(0) // clear the time and set the fields afresh

        if let timeZone = self.timeZone {
            cal.setTimeZone(timeZone.platformValue)
        } else {
            cal.setTimeZone(TimeZone.current.platformValue)
        }

        if let era = self.era {
            cal.set(PlatformCalendar.ERA, era)
        }
        if let year = self.year {
            cal.set(PlatformCalendar.YEAR, year)
        }
        if let month = self.month {
            // Foundation starts at 1, but Java: “Field number for get and set indicating the month. This is a calendar-specific value. The first month of the year in the Gregorian and Julian calendars is JANUARY which is 0; the last depends on the number of months in a year.”
            cal.set(PlatformCalendar.MONTH, month - 1)
        }
        if let day = self.day {
            cal.set(PlatformCalendar.DATE, day) // i.e., DAY_OF_MONTH
        }
        if let hour = self.hour {
            cal.set(PlatformCalendar.HOUR_OF_DAY, hour)
        }
        if let minute = self.minute {
            cal.set(PlatformCalendar.MINUTE, minute)
        }
        if let second = self.second {
            cal.set(PlatformCalendar.SECOND, second)
        }
        if let nanosecond = self.nanosecond {
            //cal.set(PlatformCalendar.NANOSECOND, nanosecond)
            fatalError("Skip Date Components.nanosecond unsupported in Skip")
        }
        if let weekday = self.weekday {
            cal.set(PlatformCalendar.DAY_OF_WEEK, weekday)
        }
        if let weekdayOrdinal = self.weekdayOrdinal {
            //cal.set(PlatformCalendar.WEEKDAYORDINAL, weekdayOrdinal)
            fatalError("Skip Date Components.weekdayOrdinal unsupported in Skip")
        }
        if let quarter = self.quarter {
            //cal.set(PlatformCalendar.QUARTER, quarter)
            fatalError("Skip Date Components.quarter unsupported in Skip")
        }
        if let weekOfMonth = self.weekOfMonth {
            cal.set(PlatformCalendar.WEEK_OF_MONTH, weekOfMonth)
        }
        if let weekOfYear = self.weekOfYear {
            cal.set(PlatformCalendar.WEEK_OF_YEAR, weekOfYear)
        }
        if let yearForWeekOfYear = self.yearForWeekOfYear {
            //cal.set(PlatformCalendar.YEARFORWEEKOFYEAR, yearForWeekOfYear)
            fatalError("Skip Date Components.yearForWeekOfYear unsupported in Skip")
        }

        return cal
    }
    #endif


    /// Set the value of one of the properties, using an enumeration value instead of a property name.
    ///
    /// The calendar and timeZone and isLeapMonth properties cannot be set by this method.
    public mutating func setValue(_ value: Int?, for component: Calendar.Component) {
        switch component {
        case .era: self.era = value
        case .year: self.year = value
        case .month: self.month = value
        case .day: self.day = value
        case .hour: self.hour = value
        case .minute: self.minute = value
        case .second: self.second = value
        case .weekday: self.weekday = value
        case .weekdayOrdinal: self.weekdayOrdinal = value
        case .quarter: self.quarter = value
        case .weekOfMonth: self.weekOfMonth = value
        case .weekOfYear: self.weekOfYear = value
        case .yearForWeekOfYear: self.yearForWeekOfYear = value
        case .nanosecond: self.nanosecond = value
        case .calendar, .timeZone: // , .isLeapMonth:
            // Do nothing
            break
        }
    }

    /// Adds one set of components to this date.
    public mutating func add(components: DateComponents) {
        #if !SKIP
        fatalError("Skip DateComponents: add not implemented for Swift")
        #else
        let cal = createCalendarComponents()

        if let value = components.era {
            cal.roll(PlatformCalendar.ERA, value)
        }
        if let value = components.year {
            cal.roll(PlatformCalendar.YEAR, value)
        }
        if let value = components.quarter {
            //cal.roll(PlatformCalendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        }
        if let value = components.month {
            cal.roll(PlatformCalendar.MONTH, value)
        }
        if let value = components.weekday {
            cal.roll(PlatformCalendar.DAY_OF_WEEK, value)
        }
        if let value = components.weekdayOrdinal {
            //cal.roll(PlatformCalendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        }
        if let value = components.weekOfMonth {
            cal.roll(PlatformCalendar.WEEK_OF_MONTH, value)
        }
        if let value = components.weekOfYear {
            cal.roll(PlatformCalendar.WEEK_OF_YEAR, value)
        }
        if let value = components.yearForWeekOfYear {
            //cal.roll(PlatformCalendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        }
        if let value = components.day {
            cal.roll(PlatformCalendar.DATE, value) // i.e., DAY_OF_MONTH
        }
        if let value = components.hour {
            cal.roll(PlatformCalendar.HOUR_OF_DAY, value)
        }
        if let value = components.minute {
            cal.roll(PlatformCalendar.MINUTE, value)
        }
        if let value = components.second {
            cal.roll(PlatformCalendar.SECOND, value)
        }
        if let value = components.nanosecond {
            fatalError("Skip DateComponents.nanosecond unsupported in Skip")
        }

        // update our fields from the rolled java.util.Calendar fields
        self = DateComponents(fromCalendar: Calendar(platformValue: cal))
        #endif
    }

    /// Adds a value for a given components.
    ///
    /// The calendar and timeZone and isLeapMonth properties cannot be set by this method.
    public mutating func addValue(_ value: Int, for component: Calendar.Component) {
        #if !SKIP
        fatalError("Skip DateComponents: addValue not implemented for Swift")
        #else
        let cal = createCalendarComponents()

        switch component {
        case .era:
            cal.roll(PlatformCalendar.ERA, value)
        case .year:
            cal.roll(PlatformCalendar.YEAR, value)
        case .month:
            cal.roll(PlatformCalendar.MONTH, value)
        case .day:
            cal.roll(PlatformCalendar.DATE, value) // i.e., DAY_OF_MONTH
        case .hour:
            cal.roll(PlatformCalendar.HOUR_OF_DAY, value)
        case .minute:
            cal.roll(PlatformCalendar.MINUTE, value)
        case .second:
            cal.roll(PlatformCalendar.SECOND, value)
        case .weekday:
            cal.roll(PlatformCalendar.DAY_OF_WEEK, value)
        case .weekdayOrdinal:
            //cal.roll(PlatformCalendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        case .quarter:
            //cal.roll(PlatformCalendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        case .weekOfMonth:
            cal.roll(PlatformCalendar.WEEK_OF_MONTH, value)
        case .weekOfYear:
            cal.roll(PlatformCalendar.WEEK_OF_YEAR, value)
        case .yearForWeekOfYear:
            //cal.roll(PlatformCalendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        case .nanosecond:
            break // unsupported
        case .calendar, .timeZone: // , .isLeapMonth:
            // Do nothing
            break
        @unknown default:
            break
        }

        // update our fields from the rolled java.util.Calendar fields
        self = DateComponents(fromCalendar: Calendar(platformValue: cal))
        #endif
    }

    /// Returns the value of one of the properties, using an enumeration value instead of a property name.
    public func value(for component: Calendar.Component) -> Int? {
        switch component {
        case .era: return self.era
        case .year: return self.year
        case .month: return self.month
        case .day: return self.day
        case .hour: return self.hour
        case .minute: return self.minute
        case .second: return self.second
        case .weekday: return self.weekday
        case .weekdayOrdinal: return self.weekdayOrdinal
        case .quarter: return self.quarter
        case .weekOfMonth: return self.weekOfMonth
        case .weekOfYear: return self.weekOfYear
        case .yearForWeekOfYear: return self.yearForWeekOfYear
        case .nanosecond: return self.nanosecond
        case .calendar, .timeZone: // , .isLeapMonth:
            return nil
        }
    }


    public var description: String {
        #if !SKIP
        return components.description
        #else
        var strs: [String] = []
        if let calendar = self.calendar {
            strs.append("calendar \(calendar)")
        }
        if let timeZone = self.timeZone {
            strs.append("timeZone \(timeZone)")
        }
        if let era = self.era {
            strs.append("era \(era)")
        }
        if let year = self.year {
            strs.append("year \(year)")
        }
        if let month = self.month {
            strs.append("month \(month)")
        }
        if let day = self.day {
            strs.append("day \(day)")
        }
        if let hour = self.hour {
            strs.append("hour \(hour)")
        }
        if let minute = self.minute {
            strs.append("minute \(minute)")
        }
        if let second = self.second {
            strs.append("second \(second)")
        }
        if let nanosecond = self.nanosecond {
            strs.append("nanosecond \(nanosecond)")
        }
        if let weekday = self.weekday {
            strs.append("weekday \(weekday)")
        }
        if let weekdayOrdinal = self.weekdayOrdinal {
            strs.append("weekdayOrdinal \(weekdayOrdinal)")
        }
        if let quarter = self.quarter {
            strs.append("quarter \(quarter)")
        }
        if let weekOfMonth = self.weekOfMonth {
            strs.append("weekOfMonth \(weekOfMonth)")
        }
        if let weekOfYear = self.weekOfYear {
            strs.append("weekOfYear \(weekOfYear)")
        }
        if let yearForWeekOfYear = self.yearForWeekOfYear {
            strs.append("yearForWeekOfYear \(yearForWeekOfYear)")
        }

        // SKIP REPLACE: return strs.joinToString(separator = " ")
        return strs.joined(separator: " ")
        #endif
    }

    public var isValidDate: Bool {
        #if !SKIP
        return components.isValidDate
        #else
        guard let calendar = self.calendar else {
            return false
        }
        return isValidDate(in: calendar)
        #endif
    }

    public func isValidDate(in calendar: Calendar) -> Bool {
        #if !SKIP
        return components.isValidDate(in: calendar.platformValue)
        #else
        // TODO: re-use implementation from: https://github.com/apple/swift-foundation/blob/68c2466c613a77d6c4453f3a06496a5da79a0cb9/Sources/FoundationInternationalization/DateComponents.swift#LL327C1-L328C1

        let cal = createCalendarComponents()
        return cal.getActualMinimum(PlatformCalendar.DAY_OF_MONTH) <= cal.get(PlatformCalendar.DAY_OF_MONTH)
        && cal.getActualMaximum(PlatformCalendar.DAY_OF_MONTH) >= cal.get(PlatformCalendar.DAY_OF_MONTH)
        && cal.getActualMinimum(PlatformCalendar.MONTH) <= cal.get(PlatformCalendar.MONTH) + (cal.get(PlatformCalendar.MONTH) == 2 ? ((cal as? java.util.GregorianCalendar)?.isLeapYear(self.year ?? -1) == true ? 0 : 1) : 0)
        && cal.getActualMaximum(PlatformCalendar.MONTH) >= cal.get(PlatformCalendar.MONTH)
        && cal.getActualMinimum(PlatformCalendar.YEAR) <= cal.get(PlatformCalendar.YEAR)
        && cal.getActualMaximum(PlatformCalendar.YEAR) >= cal.get(PlatformCalendar.YEAR)
        #endif
    }
}
