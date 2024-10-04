// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public typealias NSDateComponents = DateComponents

public struct DateComponents : Codable, Hashable, CustomStringConvertible {
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

    public init(calendar: Calendar? = nil, timeZone: TimeZone? = nil, era: Int? = nil, year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil, weekday: Int? = nil, weekdayOrdinal: Int? = nil, quarter: Int? = nil, weekOfMonth: Int? = nil, weekOfYear: Int? = nil, yearForWeekOfYear: Int? = nil) {
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
    }

    internal init(fromCalendar calendar: Calendar, in zone: TimeZone? = nil, from date: Date? = nil, to endDate: Date? = nil, with components: Set<Calendar.Component>? = nil) {
        let platformCal = calendar.platformValue.clone() as java.util.Calendar

        if let date = date {
            platformCal.time = date.platformValue
        }

        let tz = zone ?? calendar.timeZone
        platformCal.timeZone = self.timeZone?.platformValue ?? platformCal.timeZone

        if components?.contains(.timeZone) != false {
            self.timeZone = tz
        }
        if components?.contains(.era) != false {
            if let endDate = endDate {
                // TODO: if components.contains(.year) { dc.year = Int(ucal_getFieldDifference(ucalendar, goal, UCAL_YEAR, &status)) }
                fatalError("TODO: Skip DateComponents field differences")
            } else {
                self.era = platformCal.get(java.util.Calendar.ERA)
            }
        }
        if components?.contains(.year) != false {
            self.year = platformCal.get(java.util.Calendar.YEAR)
        }
        if components?.contains(.month) != false {
            self.month = platformCal.get(java.util.Calendar.MONTH) + 1
        }
        if components?.contains(.day) != false {
            self.day = platformCal.get(java.util.Calendar.DATE) // i.e., DAY_OF_MONTH
        }
        if components?.contains(.hour) != false {
            self.hour = platformCal.get(java.util.Calendar.HOUR_OF_DAY)
        }
        if components?.contains(.minute) != false {
            self.minute = platformCal.get(java.util.Calendar.MINUTE)
        }
        if components?.contains(.second) != false {
            self.second = platformCal.get(java.util.Calendar.SECOND)
        }
        if components?.contains(.weekday) != false {
            self.weekday = platformCal.get(java.util.Calendar.DAY_OF_WEEK)
        }
        if components?.contains(.weekOfMonth) != false {
            self.weekOfMonth = platformCal.get(java.util.Calendar.WEEK_OF_MONTH)
        }
        if components?.contains(.weekOfYear) != false {
            self.weekOfYear = platformCal.get(java.util.Calendar.WEEK_OF_YEAR)
        }

        // unsupported fields in java.util.Calendar:
        //self.nanosecond = platformCal.get(java.util.Calendar.NANOSECOND)
        //self.weekdayOrdinal = platformCal.get(java.util.Calendar.WEEKDAYORDINAL)
        //self.quarter = platformCal.get(java.util.Calendar.QUARTER)
        //self.yearForWeekOfYear = platformCal.get(java.util.Calendar.YEARFORWEEKOFYEAR)
    }

    /// Builds a java.util.Calendar from the fields.
    internal func createCalendarComponents(timeZone: TimeZone? = nil) -> java.util.Calendar {
        let c: java.util.Calendar = (self.calendar?.platformValue ?? Calendar.current.platformValue)
        let cal: java.util.Calendar = (c as java.util.Calendar).clone() as java.util.Calendar

        if let timeZone = timeZone ?? self.timeZone {
            cal.setTimeZone(timeZone.platformValue)
        } else {
            cal.setTimeZone(TimeZone.current.platformValue)
        }

        cal.setTimeInMillis(0) // clear the time and set the fields afresh

        if let era = self.era {
            cal.set(java.util.Calendar.ERA, era)
        }
        if let year = self.year {
            cal.set(java.util.Calendar.YEAR, year)
        } else {
            cal.set(java.util.Calendar.YEAR, 0)
        }
        if let month = self.month {
            // Foundation starts at 1, but Java: “Field number for get and set indicating the month. This is a calendar-specific value. The first month of the year in the Gregorian and Julian calendars is JANUARY which is 0; the last depends on the number of months in a year.”
            cal.set(java.util.Calendar.MONTH, month - 1)
        } else {
            cal.set(java.util.Calendar.MONTH, 0)
        }
        if let day = self.day {
            cal.set(java.util.Calendar.DATE, day) // i.e., DAY_OF_MONTH
        } else {
            cal.set(java.util.Calendar.DATE, 1)
        }
        if let hour = self.hour {
            cal.set(java.util.Calendar.HOUR_OF_DAY, hour)
        } else {
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
        }
        if let minute = self.minute {
            cal.set(java.util.Calendar.MINUTE, minute)
        } else {
            cal.set(java.util.Calendar.MINUTE, 0)
        }
        if let second = self.second {
            cal.set(java.util.Calendar.SECOND, second)
        } else {
            cal.set(java.util.Calendar.SECOND, 0)
        }
        if let nanosecond = self.nanosecond {
            cal.set(java.util.Calendar.MILLISECOND, nanosecond * 1_000_000)
        } else {
            cal.set(java.util.Calendar.MILLISECOND, 0)
        }
        if let weekday = self.weekday {
            cal.set(java.util.Calendar.DAY_OF_WEEK, weekday)
        }
        if let weekdayOrdinal = self.weekdayOrdinal {
            //cal.set(java.util.Calendar.WEEKDAYORDINAL, weekdayOrdinal)
            fatalError("Skip Date Components.weekdayOrdinal unsupported in Skip")
        }
        if let quarter = self.quarter {
            //cal.set(java.util.Calendar.QUARTER, quarter)
            fatalError("Skip Date Components.quarter unsupported in Skip")
        }
        if let weekOfMonth = self.weekOfMonth {
            cal.set(java.util.Calendar.WEEK_OF_MONTH, weekOfMonth)
        }
        if let weekOfYear = self.weekOfYear {
            cal.set(java.util.Calendar.WEEK_OF_YEAR, weekOfYear)
        }
        if let yearForWeekOfYear = self.yearForWeekOfYear {
            //cal.set(java.util.Calendar.YEARFORWEEKOFYEAR, yearForWeekOfYear)
            fatalError("Skip Date Components.yearForWeekOfYear unsupported in Skip")
        }

        return cal
    }

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

    public mutating func add(components: DateComponents) {
        let cal = createCalendarComponents()

        if let value = components.era {
            cal.add(java.util.Calendar.ERA, value)
        }
        if let value = components.year {
            cal.add(java.util.Calendar.YEAR, value)
        }
        if let value = components.quarter {
            //cal.add(java.util.Calendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        }
        if let value = components.month {
            cal.add(java.util.Calendar.MONTH, value)
        }
        if let value = components.weekday {
            cal.add(java.util.Calendar.DAY_OF_WEEK, value)
        }
        if let value = components.weekdayOrdinal {
            //cal.add(java.util.Calendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        }
        if let value = components.weekOfMonth {
            cal.add(java.util.Calendar.WEEK_OF_MONTH, value)
        }
        if let value = components.weekOfYear {
            cal.add(java.util.Calendar.WEEK_OF_YEAR, value)
        }
        if let value = components.yearForWeekOfYear {
            //cal.add(java.util.Calendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        }
        if let value = components.day {
            cal.add(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        }
        if let value = components.hour {
            cal.add(java.util.Calendar.HOUR_OF_DAY, value)
        }
        if let value = components.minute {
            cal.add(java.util.Calendar.MINUTE, value)
        }
        if let value = components.second {
            cal.add(java.util.Calendar.SECOND, value)
        }
        if let value = components.nanosecond {
            fatalError("Skip DateComponents.nanosecond unsupported in Skip")
        }

        // update our fields from the rolled java.util.Calendar fields
        self = DateComponents(fromCalendar: Calendar(platformValue: cal))
    }

    public mutating func roll(components: DateComponents) {
        let cal = createCalendarComponents()

        if let value = components.era {
            cal.roll(java.util.Calendar.ERA, value)
        }
        if let value = components.year {
            cal.roll(java.util.Calendar.YEAR, value)
        }
        if let value = components.quarter {
            //cal.roll(java.util.Calendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        }
        if let value = components.month {
            cal.roll(java.util.Calendar.MONTH, value)
        }
        if let value = components.weekday {
            cal.roll(java.util.Calendar.DAY_OF_WEEK, value)
        }
        if let value = components.weekdayOrdinal {
            //cal.roll(java.util.Calendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        }
        if let value = components.weekOfMonth {
            cal.roll(java.util.Calendar.WEEK_OF_MONTH, value)
        }
        if let value = components.weekOfYear {
            cal.roll(java.util.Calendar.WEEK_OF_YEAR, value)
        }
        if let value = components.yearForWeekOfYear {
            //cal.roll(java.util.Calendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        }
        if let value = components.day {
            cal.roll(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        }
        if let value = components.hour {
            cal.roll(java.util.Calendar.HOUR_OF_DAY, value)
        }
        if let value = components.minute {
            cal.roll(java.util.Calendar.MINUTE, value)
        }
        if let value = components.second {
            cal.roll(java.util.Calendar.SECOND, value)
        }
        if let value = components.nanosecond {
            fatalError("Skip DateComponents.nanosecond unsupported in Skip")
        }

        // update our fields from the rolled java.util.Calendar fields
        self = DateComponents(fromCalendar: Calendar(platformValue: cal))
    }

    public mutating func addValue(_ value: Int, for component: Calendar.Component) {
        let cal = createCalendarComponents()

        switch component {
        case .era:
            cal.add(java.util.Calendar.ERA, value)
        case .year:
            cal.add(java.util.Calendar.YEAR, value)
        case .month:
            cal.add(java.util.Calendar.MONTH, value)
        case .day:
            cal.add(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        case .hour:
            cal.add(java.util.Calendar.HOUR_OF_DAY, value)
        case .minute:
            cal.add(java.util.Calendar.MINUTE, value)
        case .second:
            cal.add(java.util.Calendar.SECOND, value)
        case .weekday:
            cal.add(java.util.Calendar.DAY_OF_WEEK, value)
        case .weekdayOrdinal:
            //cal.add(java.util.Calendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        case .quarter:
            //cal.add(java.util.Calendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        case .weekOfMonth:
            cal.add(java.util.Calendar.WEEK_OF_MONTH, value)
        case .weekOfYear:
            cal.add(java.util.Calendar.WEEK_OF_YEAR, value)
        case .yearForWeekOfYear:
            //cal.add(java.util.Calendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        case .nanosecond:
            break // unsupported
        case .calendar, .timeZone: // , .isLeapMonth:
            // Do nothing
            break
        @unknown default:
            break
        }

        // update our fields from the added java.util.Calendar fields
        self = DateComponents(fromCalendar: Calendar(platformValue: cal))
    }

    public mutating func rollValue(_ value: Int, for component: Calendar.Component) {
        let cal = createCalendarComponents()

        switch component {
        case .era:
            cal.roll(java.util.Calendar.ERA, value)
        case .year:
            cal.roll(java.util.Calendar.YEAR, value)
        case .month:
            cal.roll(java.util.Calendar.MONTH, value)
        case .day:
            cal.roll(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        case .hour:
            cal.roll(java.util.Calendar.HOUR_OF_DAY, value)
        case .minute:
            cal.roll(java.util.Calendar.MINUTE, value)
        case .second:
            cal.roll(java.util.Calendar.SECOND, value)
        case .weekday:
            cal.roll(java.util.Calendar.DAY_OF_WEEK, value)
        case .weekdayOrdinal:
            //cal.roll(java.util.Calendar.WEEKDAYORDINAL, value)
            fatalError("Skip DateComponents.weekdayOrdinal unsupported in Skip")
        case .quarter:
            //cal.roll(java.util.Calendar.QUARTER, value)
            fatalError("Skip DateComponents.quarter unsupported in Skip")
        case .weekOfMonth:
            cal.roll(java.util.Calendar.WEEK_OF_MONTH, value)
        case .weekOfYear:
            cal.roll(java.util.Calendar.WEEK_OF_YEAR, value)
        case .yearForWeekOfYear:
            //cal.roll(java.util.Calendar.YEARFORWEEKOFYEAR, value)
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
    }

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
        return strs.joined(separator: " ")
    }

    public var isValidDate: Bool {
        guard let calendar = self.calendar else {
            return false
        }
        return isValidDate(in: calendar)
    }

    public func isValidDate(in calendar: Calendar) -> Bool {
        // TODO: re-use implementation from: https://github.com/apple/swift-foundation/blob/68c2466c613a77d6c4453f3a06496a5da79a0cb9/Sources/FoundationInternationalization/DateComponents.swift#LL327C1-L328C1

        let cal = createCalendarComponents()
        return cal.getActualMinimum(java.util.Calendar.DAY_OF_MONTH) <= cal.get(java.util.Calendar.DAY_OF_MONTH)
        && cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH) >= cal.get(java.util.Calendar.DAY_OF_MONTH)
        && cal.getActualMinimum(java.util.Calendar.MONTH) <= cal.get(java.util.Calendar.MONTH) + (cal.get(java.util.Calendar.MONTH) == 2 ? ((cal as? java.util.GregorianCalendar)?.isLeapYear(self.year ?? -1) == true ? 0 : 1) : 0)
        && cal.getActualMaximum(java.util.Calendar.MONTH) >= cal.get(java.util.Calendar.MONTH)
        && cal.getActualMinimum(java.util.Calendar.YEAR) <= cal.get(java.util.Calendar.YEAR)
        && cal.getActualMaximum(java.util.Calendar.YEAR) >= cal.get(java.util.Calendar.YEAR)
    }
}

#endif
