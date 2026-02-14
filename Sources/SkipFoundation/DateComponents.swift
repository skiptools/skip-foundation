// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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
    public var dayOfYear: Int? = nil
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

    public init(calendar: Calendar? = nil, timeZone: TimeZone? = nil, era: Int? = nil, year: Int? = nil, month: Int? = nil, day: Int? = nil, dayOfYear: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil, weekday: Int? = nil, weekdayOrdinal: Int? = nil, quarter: Int? = nil, weekOfMonth: Int? = nil, weekOfYear: Int? = nil, yearForWeekOfYear: Int? = nil) {
        self.calendar = calendar
        self.timeZone = timeZone
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.dayOfYear = dayOfYear
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
        platformCal.timeZone = tz.platformValue

        if components?.contains(.timeZone) != false {
            self.timeZone = tz
        }

        if let endDate = endDate {
            let endPlatformCal = calendar.platformValue.clone() as java.util.Calendar
            endPlatformCal.time = endDate.platformValue
            endPlatformCal.timeZone = tz.platformValue

            // Calculate differences based on components.
            if components?.contains(.era) != false {
                self.era = endPlatformCal.get(java.util.Calendar.ERA) - platformCal.get(java.util.Calendar.ERA)
            }
            if components?.contains(.year) != false {
                self.year = endPlatformCal.get(java.util.Calendar.YEAR) - platformCal.get(java.util.Calendar.YEAR)
            }
            if components?.contains(.quarter) != false {
                let startQuarter = (platformCal.get(java.util.Calendar.MONTH) / 3) + 1
                let endQuarter = (endPlatformCal.get(java.util.Calendar.MONTH) / 3) + 1
                self.quarter = endQuarter - startQuarter
            }
            if components?.contains(.month) != false {
                self.month = endPlatformCal.get(java.util.Calendar.MONTH) - platformCal.get(java.util.Calendar.MONTH)
            }
            if components?.contains(.day) != false {
                self.day = endPlatformCal.get(java.util.Calendar.DAY_OF_MONTH) - platformCal.get(java.util.Calendar.DAY_OF_MONTH)
            }
            if components?.contains(.dayOfYear) != false {
                self.dayOfYear = endPlatformCal.get(java.util.Calendar.DAY_OF_YEAR) - platformCal.get(java.util.Calendar.DAY_OF_YEAR)
            }
            if components?.contains(.hour) != false {
                self.hour = endPlatformCal.get(java.util.Calendar.HOUR_OF_DAY) - platformCal.get(java.util.Calendar.HOUR_OF_DAY)
            }
            if components?.contains(.minute) != false {
                self.minute = endPlatformCal.get(java.util.Calendar.MINUTE) - platformCal.get(java.util.Calendar.MINUTE)
            }
            if components?.contains(.second) != false {
                self.second = endPlatformCal.get(java.util.Calendar.SECOND) - platformCal.get(java.util.Calendar.SECOND)
            }
            if components?.contains(.weekday) != false {
                self.weekday = endPlatformCal.get(java.util.Calendar.DAY_OF_WEEK) - platformCal.get(java.util.Calendar.DAY_OF_WEEK)
            }
            if components?.contains(.weekdayOrdinal) != false {
                self.weekdayOrdinal = endPlatformCal.get(java.util.Calendar.DAY_OF_WEEK_IN_MONTH) - platformCal.get(java.util.Calendar.DAY_OF_WEEK_IN_MONTH)
            }
            if components?.contains(.weekOfMonth) != false {
                self.weekOfMonth = endPlatformCal.get(java.util.Calendar.WEEK_OF_MONTH) - platformCal.get(java.util.Calendar.WEEK_OF_MONTH)
            }
            if components?.contains(.weekOfYear) != false {
                self.weekOfYear = endPlatformCal.get(java.util.Calendar.WEEK_OF_YEAR) - platformCal.get(java.util.Calendar.WEEK_OF_YEAR)
            }
        } else {
            // If no endDate is provided, just extract the components from the current date.
            if components?.contains(.era) != false {
                self.era = platformCal.get(java.util.Calendar.ERA)
            }
            if components?.contains(.year) != false {
                self.year = platformCal.get(java.util.Calendar.YEAR)
            }
            if components?.contains(.quarter) != false {
                self.quarter = (platformCal.get(java.util.Calendar.MONTH) / 3) + 1
            }
            if components?.contains(.month) != false {
                self.month = platformCal.get(java.util.Calendar.MONTH) + 1
            }
            if components?.contains(.day) != false {
                self.day = platformCal.get(java.util.Calendar.DAY_OF_MONTH)
            }
            if components?.contains(.dayOfYear) != false {
                self.dayOfYear = platformCal.get(java.util.Calendar.DAY_OF_YEAR)
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
            if components?.contains(.weekdayOrdinal) != false {
                self.weekdayOrdinal = platformCal.get(java.util.Calendar.DAY_OF_WEEK_IN_MONTH)
            }
            if components?.contains(.weekOfMonth) != false {
                self.weekOfMonth = platformCal.get(java.util.Calendar.WEEK_OF_MONTH)
            }
            if components?.contains(.weekOfYear) != false {
                self.weekOfYear = platformCal.get(java.util.Calendar.WEEK_OF_YEAR)
            }
        }

        // unsupported fields in java.util.Calendar:
        //self.nanosecond = platformCal.get(java.util.Calendar.NANOSECOND)
        //self.yearForWeekOfYear = platformCal.get(java.util.Calendar.YEARFORWEEKOFYEAR)
    }

    /// Builds a java.util.Calendar from the fields.
    internal func createCalendarComponents(timeZone: TimeZone? = nil) -> java.util.Calendar {
        let c: java.util.Calendar = (self.calendar?.platformValue ?? Calendar.current.platformValue)
        let cal: java.util.Calendar = (c as java.util.Calendar).clone() as java.util.Calendar

        //cal.setLenient(false)
        cal.clear() // clear the time and set the fields afresh
        cal.setTimeZone((timeZone ?? self.timeZone ?? TimeZone.current).platformValue)

        if let era = self.era {
            cal.set(java.util.Calendar.ERA, era)
        }
        if let yearForWeekOfYear = self.yearForWeekOfYear {
            //cal.set(java.util.Calendar.YEARFORWEEKOFYEAR, yearForWeekOfYear)
            fatalError("Skip Date Components.yearForWeekOfYear unsupported in Skip")
        }
        if let year = self.year {
            cal.set(java.util.Calendar.YEAR, year)
        }
        if let quarter = self.quarter {
            let monthForQuarter = (quarter - 1) * 3
            cal.set(java.util.Calendar.MONTH, monthForQuarter)
            cal.set(java.util.Calendar.DAY_OF_MONTH, 1)
        }
        if let month = self.month {
            // Foundation starts at 1, but Java: “Field number for get and set indicating the month. This is a calendar-specific value. The first month of the year in the Gregorian and Julian calendars is JANUARY which is 0; the last depends on the number of months in a year.”
            cal.set(java.util.Calendar.MONTH, month - 1)
        }
        if let weekOfYear = self.weekOfYear {
            cal.set(java.util.Calendar.WEEK_OF_YEAR, weekOfYear)
        }
        if let weekOfMonth = self.weekOfMonth {
            cal.set(java.util.Calendar.WEEK_OF_MONTH, weekOfMonth)
        }
        if let weekday = self.weekday {
            cal.set(java.util.Calendar.DAY_OF_WEEK, weekday)
        }
        if let weekdayOrdinal = self.weekdayOrdinal {
            cal.set(java.util.Calendar.DAY_OF_WEEK_IN_MONTH, weekdayOrdinal)
        }
        if let day = self.day {
            cal.set(java.util.Calendar.DAY_OF_MONTH, day)
        }
        if let dayOfYear = self.dayOfYear {
            cal.set(java.util.Calendar.DAY_OF_YEAR, dayOfYear)
        }
        if let hour = self.hour {
            cal.set(java.util.Calendar.HOUR_OF_DAY, hour)
        }
        if let minute = self.minute {
            cal.set(java.util.Calendar.MINUTE, minute)
        }
        if let second = self.second {
            cal.set(java.util.Calendar.SECOND, second)
        }
        if let nanosecond = self.nanosecond {
            cal.set(java.util.Calendar.MILLISECOND, nanosecond * 1_000_000)
        }

        return cal
    }

    public var date: Date? {
        Date(platformValue: createCalendarComponents().getTime())
    }

    public mutating func setValue(_ value: Int?, for component: Calendar.Component) {
        switch component {
        case .era: self.era = value
        case .year: self.year = value
        case .month: self.month = value
        case .day: self.day = value
        case .dayOfYear: self.dayOfYear = value
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
            cal.add(java.util.Calendar.MONTH, value * 3)
        }
        if let value = components.month {
            cal.add(java.util.Calendar.MONTH, value)
        }
        if let value = components.weekday {
            cal.add(java.util.Calendar.DAY_OF_WEEK, value)
        }
        if let value = components.weekdayOrdinal {
            cal.add(java.util.Calendar.DAY_OF_WEEK_IN_MONTH, value)
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
            let currentMonth = cal.get(java.util.Calendar.MONTH)
            let currentQuarter = currentMonth / 3
            let newQuarter = ((currentQuarter + value) % 4 + 4) % 4
            let monthInQuarter = currentMonth % 3
            let newMonth = newQuarter * 3 + monthInQuarter
            cal.set(java.util.Calendar.MONTH, newMonth)
        }
        if let value = components.month {
            cal.roll(java.util.Calendar.MONTH, value)
        }
        if let value = components.weekday {
            cal.roll(java.util.Calendar.DAY_OF_WEEK, value)
        }
        if let value = components.weekdayOrdinal {
            cal.roll(java.util.Calendar.DAY_OF_WEEK_IN_MONTH, value)
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
        case .quarter:
            cal.add(java.util.Calendar.MONTH, value * 3)
        case .month:
            cal.add(java.util.Calendar.MONTH, value)
        case .weekday:
            cal.add(java.util.Calendar.DAY_OF_WEEK, value)
        case .weekdayOrdinal:
            cal.add(java.util.Calendar.DAY_OF_WEEK_IN_MONTH, value)
        case .weekOfMonth:
            cal.add(java.util.Calendar.WEEK_OF_MONTH, value)
        case .weekOfYear:
            cal.add(java.util.Calendar.WEEK_OF_YEAR, value)
        case .yearForWeekOfYear:
            //cal.add(java.util.Calendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        case .day:
            cal.add(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        case .hour:
            cal.add(java.util.Calendar.HOUR_OF_DAY, value)
        case .minute:
            cal.add(java.util.Calendar.MINUTE, value)
        case .second:
            cal.add(java.util.Calendar.SECOND, value)
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
        case .quarter:
            let currentMonth = cal.get(java.util.Calendar.MONTH)
            let currentQuarter = currentMonth / 3
            let newQuarter = ((currentQuarter + value) % 4 + 4) % 4
            let monthInQuarter = currentMonth % 3
            let newMonth = newQuarter * 3 + monthInQuarter
            cal.set(java.util.Calendar.MONTH, newMonth)
        case .month:
            cal.roll(java.util.Calendar.MONTH, value)
        case .weekday:
            cal.roll(java.util.Calendar.DAY_OF_WEEK, value)
        case .weekdayOrdinal:
            cal.roll(java.util.Calendar.DAY_OF_WEEK_IN_MONTH, value)
        case .weekOfMonth:
            cal.roll(java.util.Calendar.WEEK_OF_MONTH, value)
        case .weekOfYear:
            cal.roll(java.util.Calendar.WEEK_OF_YEAR, value)
        case .yearForWeekOfYear:
            //cal.roll(java.util.Calendar.YEARFORWEEKOFYEAR, value)
            fatalError("Skip DateComponents.yearForWeekOfYear unsupported in Skip")
        case .day:
            cal.roll(java.util.Calendar.DATE, value) // i.e., DAY_OF_MONTH
        case .hour:
            cal.roll(java.util.Calendar.HOUR_OF_DAY, value)
        case .minute:
            cal.roll(java.util.Calendar.MINUTE, value)
        case .second:
            cal.roll(java.util.Calendar.SECOND, value)
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
        case .weekday: return self.weekday
        case .weekdayOrdinal: return self.weekdayOrdinal
        case .quarter: return self.quarter
        case .weekOfMonth: return self.weekOfMonth
        case .weekOfYear: return self.weekOfYear
        case .yearForWeekOfYear: return self.yearForWeekOfYear
        case .day: return self.day
        case .dayOfYear: return self.dayOfYear
        case .hour: return self.hour
        case .minute: return self.minute
        case .second: return self.second
        case .nanosecond: return self.nanosecond
        case .calendar, .timeZone: // , .isLeapMonth:
            return nil
        }
    }

    public var description: String {
        var strs: [String] = []
        if let calendar = self.calendar {
            strs.append("calendar=\(calendar)")
        }
        if let timeZone = self.timeZone {
            strs.append("timeZone=\(timeZone.identifier)")
        }
        if let era = self.era {
            strs.append("era=\(era)")
        }
        if let year = self.year {
            strs.append("year=\(year)")
        }
        if let quarter = self.quarter {
            strs.append("quarter=\(quarter)")
        }
        if let month = self.month {
            strs.append("month=\(month)")
        }
        if let weekday = self.weekday {
            strs.append("weekday=\(weekday)")
        }
        if let weekdayOrdinal = self.weekdayOrdinal {
            strs.append("weekdayOrdinal=\(weekdayOrdinal)")
        }
        if let weekOfMonth = self.weekOfMonth {
            strs.append("weekOfMonth=\(weekOfMonth)")
        }
        if let weekOfYear = self.weekOfYear {
            strs.append("weekOfYear=\(weekOfYear)")
        }
        if let yearForWeekOfYear = self.yearForWeekOfYear {
            strs.append("yearForWeekOfYear=\(yearForWeekOfYear)")
        }
        if let day = self.day {
            strs.append("day=\(day)")
        }
        if let dayOfYear = self.dayOfYear {
            strs.append("dayOfYear=\(dayOfYear)")
        }
        if let hour = self.hour {
            strs.append("hour=\(hour)")
        }
        if let minute = self.minute {
            strs.append("minute=\(minute)")
        }
        if let second = self.second {
            strs.append("second=\(second)")
        }
        if let nanosecond = self.nanosecond {
            strs.append("nanosecond=\(nanosecond)")
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
