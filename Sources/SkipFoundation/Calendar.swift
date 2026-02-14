// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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

    public var firstWeekday: Int {
        get {
            return platformValue.getFirstDayOfWeek()
        }
        set {
            platformValue.setFirstDayOfWeek(newValue)
        }
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

    public func component(_ component: Calendar.Component, from date: Date) -> Int {
        return dateComponents([component], from: date).value(for: component) ?? 0
    }

    public func minimumRange(of component: Calendar.Component) -> Range<Int>? {
        let platformCal = platformValue.clone() as java.util.Calendar

        switch component {
        case .era:
            // Eras are internally represented as 0 and 1 (BC/AD).
            return platformCal.getMinimum(java.util.Calendar.ERA)..<(platformCal.getLeastMaximum(java.util.Calendar.ERA) + 1)

        case .year:
            // Year typically starts at 1 and has no defined maximum.
            return 1..<platformCal.getMaximum(java.util.Calendar.YEAR)

        case .quarter:
            // There are always 4 quarters in a year.
            return 1..<5

        case .month:
            // Java's month is 0-based (0-11), but Swift expects 1-based (1-12).
            return 1..<(platformCal.getMaximum(java.util.Calendar.MONTH) + 2)

        case .weekday:
            // Weekday ranges from 1 (Sunday) to 7 (Saturday).
            return platformCal.getMinimum(java.util.Calendar.DAY_OF_WEEK)..<(platformCal.getMaximum(java.util.Calendar.DAY_OF_WEEK) + 1)

        case .weekdayOrdinal:
            // Weekday ordinal ranges from 1 to 4 (smallest possible maximum occurrences in a month).
            return platformCal.getMinimum(java.util.Calendar.DAY_OF_WEEK_IN_MONTH)..< (platformCal.getLeastMaximum(java.util.Calendar.DAY_OF_WEEK_IN_MONTH) + 2)

        case .weekOfMonth:
            // Week of month ranges from 1 to 4 (smallest possible maximum).
            return platformCal.getMinimum(java.util.Calendar.WEEK_OF_MONTH) + 1..< (platformCal.getLeastMaximum(java.util.Calendar.WEEK_OF_MONTH) + 2)

         case .weekOfYear:
            // Week of year ranges from 1 to 52 (smallest possible maximum).
            return 1..<53

        case .day:
            // getMaximum() gives the largest value that field could theoretically have.
            // getActualMaximum() gives the largest value that field actually has for the specific calendar state.

            // calendar.getActualMaximum(java.util.Calendar.DATE)
            // will return 28 because February 2023 has 28 days (it’s not a leap year).
            platformCal.set(java.util.Calendar.DAY_OF_MONTH, 1)
            clearTime(in: platformCal)
            platformCal.set(java.util.Calendar.MONTH, java.util.Calendar.FEBRUARY)
            platformCal.set(java.util.Calendar.YEAR, 2023)
            // Minimum days in a month is 1, maximum can vary (28 for February).
            return platformCal.getMinimum(java.util.Calendar.DATE)..<platformCal.getActualMaximum(java.util.Calendar.DATE) + 1

        case .dayOfYear:
            // Day of year ranges from 1 to 365 (smallest possible maximum).
            return 1..<366

        case .hour:
            // Hours are in the range 0-23.
            return platformCal.getMinimum(java.util.Calendar.HOUR_OF_DAY)..<(platformCal.getMaximum(java.util.Calendar.HOUR_OF_DAY) + 1)

        case .minute:
            // Minutes are in the range 0-59.
            return platformCal.getMinimum(java.util.Calendar.MINUTE)..<(platformCal.getMaximum(java.util.Calendar.MINUTE) + 1)

        case .second:
            // Seconds are in the range 0-59.
            return platformCal.getMinimum(java.util.Calendar.SECOND)..<(platformCal.getMaximum(java.util.Calendar.SECOND) + 1)

        default:
            return nil
        }
    }

    public func maximumRange(of component: Calendar.Component) -> Range<Int>? {
        let platformCal = platformValue.clone() as java.util.Calendar
        switch component {
        case .day:
            // Maximum number of days in a month can vary (e.g., 28, 29, 30, or 31 days).
            return platformCal.getMinimum(java.util.Calendar.DATE)..<(platformCal.getMaximum(java.util.Calendar.DATE) + 1)
        case .weekOfYear, .dayOfYear, .weekdayOrdinal:
            let minRange = minimumRange(of: component)!
            return minRange.lowerBound..<(minRange.upperBound + 1)
        case .weekOfMonth:
            let minRange = minimumRange(of: component)!
            return minRange.lowerBound..<(minRange.upperBound + 2)
        default:
            // Maximum range is usually the same logic as minimum but could differ in some cases.
            return minimumRange(of: component)
        }
    }

    public func range(of smaller: Calendar.Component, in larger: Calendar.Component, for date: Date) -> Range<Int>? {
        let platformCal = platformValue.clone() as java.util.Calendar
        platformCal.time = date.platformValue

        switch larger {
        case .month:
            if smaller == .day {
                // Range of days in the current month
                let numDays = platformCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH)
                return 1..<(numDays + 1)
            } else if smaller == .weekOfMonth {
                // Range of weeks in the current month
                let numWeeks = platformCal.getActualMaximum(java.util.Calendar.WEEK_OF_MONTH)
                return 1..<(numWeeks + 1)
            }
        case .year:
            if smaller == .weekOfYear {
                // Range of weeks in the current year
                // Seems like Swift always returns Maximum not for an actual date
                let numWeeks = platformCal.getMaximum(java.util.Calendar.WEEK_OF_YEAR)
                return 1..<(numWeeks + 1)
            } else if smaller == .day {
                // Range of days in the current year
                let numDays = platformCal.getActualMaximum(java.util.Calendar.DAY_OF_YEAR)
                return 1..<(numDays + 1)
            } else if smaller == .month {
                // Range of months in the current year (1 to 12)
                return 1..<13
            }
        default:
            return nil
        }

        return nil
    }

    private func clearTime(in calendar: java.util.Calendar) {
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0) // “The HOUR_OF_DAY, HOUR and AM_PM fields are handled independently and the the resolution rule for the time of day is applied. Clearing one of the fields doesn't reset the hour of day value of this Calendar. Use set(Calendar.HOUR_OF_DAY, 0) to reset the hour value.”
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)
    }

    public func dateInterval(of component: Calendar.Component, for date: Date) -> DateInterval? {
        var start = Date()
        var interval: TimeInterval = 0
        if dateInterval(of: component, start: &start, interval: &interval, for: date) {
            return DateInterval(start: start, duration: interval)
        }
        return nil
    }

    public func dateInterval(of component: Calendar.Component, start: inout Date, interval: inout TimeInterval, for date: Date) -> Bool {
        let platformCal = platformValue.clone() as java.util.Calendar
        platformCal.time = date.platformValue

        switch component {
        case .second:
            platformCal.set(java.util.Calendar.MILLISECOND, 0)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(1)
            return true

        case .minute:
            platformCal.set(java.util.Calendar.SECOND, 0)
            platformCal.set(java.util.Calendar.MILLISECOND, 0)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(60)
            return true

        case .hour:
            platformCal.set(java.util.Calendar.MINUTE, 0)
            platformCal.set(java.util.Calendar.SECOND, 0)
            platformCal.set(java.util.Calendar.MILLISECOND, 0)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(60 * 60)
            return true

        case .day, .dayOfYear:
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(24 * 60 * 60)
            return true

        case .weekday, .weekdayOrdinal:
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(24 * 60 * 60)
            return true

        case .month:
            platformCal.set(java.util.Calendar.DAY_OF_MONTH, 1)
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            let numberOfDays = platformCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH)
            interval = TimeInterval(numberOfDays) * TimeInterval(24 * 60 * 60)
            return true

        case .weekOfMonth, .weekOfYear:
            platformCal.set(java.util.Calendar.DAY_OF_WEEK, platformCal.firstDayOfWeek)
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            interval = TimeInterval(7 * 24 * 60 * 60)
            return true

        case .quarter:
            let currentMonth = platformCal.get(java.util.Calendar.MONTH)
            let quarterStartMonth = (currentMonth / 3) * 3 // Find the first month of the current quarter
            platformCal.set(java.util.Calendar.MONTH, quarterStartMonth)
            platformCal.set(java.util.Calendar.DAY_OF_MONTH, 1)
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            let nextQuarterCal = platformCal.clone() as java.util.Calendar
            nextQuarterCal.add(java.util.Calendar.MONTH, 3)
            let durationMillis = nextQuarterCal.timeInMillis - platformCal.timeInMillis
            interval = TimeInterval(durationMillis) / 1000.0
            return true

        case .year:
            platformCal.set(java.util.Calendar.MONTH, java.util.Calendar.JANUARY)
            platformCal.set(java.util.Calendar.DAY_OF_MONTH, 1)
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            let numberOfDays = platformCal.getActualMaximum(java.util.Calendar.DAY_OF_YEAR)
            interval = TimeInterval(numberOfDays) * TimeInterval(24 * 60 * 60)
            return true

        case .era:
            platformCal.set(java.util.Calendar.YEAR, 1)
            platformCal.set(java.util.Calendar.MONTH, java.util.Calendar.JANUARY)
            platformCal.set(java.util.Calendar.DAY_OF_MONTH, 1)
            clearTime(in: platformCal)
            start = Date(platformValue: platformCal.time)
            interval = Double.infinity
            return true

        default:
            return false
        }
    }

    public func ordinality(of smaller: Calendar.Component, in larger: Calendar.Component, for date: Date) -> Int? {
        let platformCal = platformValue.clone() as java.util.Calendar
        platformCal.time = date.platformValue

        switch larger {
        case .year:
            if smaller == .day {
                return platformCal.get(java.util.Calendar.DAY_OF_YEAR)
            } else if smaller == .weekOfYear {
                return platformCal.get(java.util.Calendar.WEEK_OF_YEAR)
            }
        case .month:
            if smaller == .day {
                return platformCal.get(java.util.Calendar.DAY_OF_MONTH)
            } else if smaller == .weekOfMonth {
                return platformCal.get(java.util.Calendar.WEEK_OF_MONTH)
            }
        default:
            return nil
        }
        return nil
    }

    public func date(from components: DateComponents) -> Date? {
        var localComponents = components
        localComponents.calendar = self
        return Date(platformValue: localComponents.createCalendarComponents(timeZone: self.timeZone).getTime())
    }

    public func date(byAdding components: DateComponents, to date: Date, wrappingComponents: Bool = false) -> Date? {
        var comps = DateComponents(fromCalendar: self, in: self.timeZone, from: date)
        if !wrappingComponents {
            comps.add(components)
        } else {
            comps.roll(components)
        }
        return date(from: comps)
    }

    public func date(byAdding component: Calendar.Component, value: Int, to date: Date, wrappingComponents: Bool = false) -> Date? {
        var comps = DateComponents(fromCalendar: self, in: self.timeZone, from: date)
        if !wrappingComponents {
            comps.addValue(value, for: component)
        } else {
            comps.rollValue(value, for: component)
        }
        return date(from: comps)
    }

    public func date(bySetting component: Calendar.Component, value: Int, of date: Date) -> Date? {
        guard let currentValue = self.dateComponents([component], from: date).value(for: component) else {
            return nil
        }
        guard currentValue != value else {
            return date
        }

        var result: Date?
        var targetComponents = DateComponents()
        targetComponents.setValue(value, for: component)
        self.enumerateDates(startingAfter: date, matching: targetComponents, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) { date, exactMatch, stop in
            result = date
            stop = true
        }
        return result
    }

    public func date(bySettingHour hour: Int, minute: Int, second: Int, of date: Date, matchingPolicy: Calendar.MatchingPolicy = .nextTime, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward) -> Date? {
        guard let interval = self.dateInterval(of: .day, for: date) else {
            return nil
        }

        let comps = DateComponents(hour: hour, minute: minute, second: second)
        let restrictedMatchingPolicy: MatchingPolicy
        if matchingPolicy == .nextTime || matchingPolicy == .strict {
            restrictedMatchingPolicy = matchingPolicy
        } else {
            restrictedMatchingPolicy = .nextTime
        }

        guard let result = self.nextDate(after: interval.start.addingTimeInterval(-0.5), matching: comps, matchingPolicy: restrictedMatchingPolicy, repeatedTimePolicy: repeatedTimePolicy, direction: direction) else {
            return nil
        }

        if result < interval.start {
            return self.nextDate(after: interval.start, matching: comps, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, direction: direction)
        } else {
            return result
        }
    }

    public func date(_ date: Date, matchesComponents components: DateComponents) -> Bool {
        let comparedUnits: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear, .dayOfYear, .nanosecond]

        let actualUnits = comparedUnits.filter { unit in
            return components.value(for: unit) != nil
        }

        return components == self.dateComponents(actualUnits, from: date)
    }

    public func dateComponents(in zone: TimeZone? = nil, from date: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: zone ?? self.timeZone, from: date)
    }

    public func dateComponents(_ components: Set<Calendar.Component>, from start: Date, to end: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: self.timeZone, from: start, to: end)
    }

    public func dateComponents(_ components: Set<Calendar.Component>, from date: Date) -> DateComponents {
        return DateComponents(fromCalendar: self, in: self.timeZone, from: date, with: components)
    }

    public func startOfDay(for date: Date) -> Date {
        // Clone the calendar to avoid mutating the original
        let platformCal = platformValue.clone() as java.util.Calendar
        platformCal.time = date.platformValue

        // Set the time components to the start of the day
        clearTime(in: platformCal)

        // Return the new Date representing the start of the day
        return Date(platformValue: platformCal.time)
    }

    public func compare(_ date1: Date, to date2: Date, toGranularity component: Calendar.Component) -> ComparisonResult {
        let platformCal1 = platformValue.clone() as java.util.Calendar
        let platformCal2 = platformValue.clone() as java.util.Calendar

        platformCal1.time = date1.platformValue
        platformCal2.time = date2.platformValue

        switch component {
        case .year:
            let year1 = platformCal1.get(java.util.Calendar.YEAR)
            let year2 = platformCal2.get(java.util.Calendar.YEAR)
            return year1 < year2 ? .orderedAscending : year1 > year2 ? .orderedDescending : .orderedSame
        case .month:
            let year1 = platformCal1.get(java.util.Calendar.YEAR)
            let year2 = platformCal2.get(java.util.Calendar.YEAR)
            let month1 = platformCal1.get(java.util.Calendar.MONTH)
            let month2 = platformCal2.get(java.util.Calendar.MONTH)
            if year1 != year2 { return year1 < year2 ? .orderedAscending : .orderedDescending }
            return month1 < month2 ? .orderedAscending : month1 > month2 ? .orderedDescending : .orderedSame
        case .day:
            let year1 = platformCal1.get(java.util.Calendar.YEAR)
            let year2 = platformCal2.get(java.util.Calendar.YEAR)
            let day1 = platformCal1.get(java.util.Calendar.DAY_OF_YEAR)
            let day2 = platformCal2.get(java.util.Calendar.DAY_OF_YEAR)
            if year1 != year2 { return year1 < year2 ? .orderedAscending : .orderedDescending }
            return day1 < day2 ? .orderedAscending : day1 > day2 ? .orderedDescending : .orderedSame
        default:
            return .orderedSame
        }
    }

    public func isDate(_ date1: Date, equalTo date2: Date, toGranularity component: Calendar.Component) -> Bool {
        return compare(date1, to: date2, toGranularity: component) == .orderedSame
    }

    public func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        return isDate(date1, equalTo: date2, toGranularity: .day)
    }

    public func isDateInToday(_ date: Date) -> Bool {
        let platformCal = platformValue.clone() as java.util.Calendar
        platformCal.time = Date().platformValue

        let targetCal = platformValue.clone() as java.util.Calendar
        targetCal.time = date.platformValue

        return platformCal.get(java.util.Calendar.YEAR) == targetCal.get(java.util.Calendar.YEAR)
            && platformCal.get(java.util.Calendar.DAY_OF_YEAR) == targetCal.get(java.util.Calendar.DAY_OF_YEAR)
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

    public func enumerateDates(startingAfter start: Date, matching components: DateComponents, matchingPolicy: Calendar.MatchingPolicy, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward, using block: (_ result: Date?, _ exactMatch: Bool, _ stop: inout Bool) -> Void) {

        let STOP_EXHAUSTIVE_SEARCH_AFTER_MAX_ITERATIONS = 100 // To prevent infinite loops
        var searchingDate = start
        var previouslyReturnedMatchDate: Date? = nil
        var iterations = -1

        repeat {
            iterations += 1
            do {
                let result = try self._enumerateDatesStep(startingAfter: start, matching: components, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, direction: direction, inSearchingDate: searchingDate, previouslyReturnedMatchDate: previouslyReturnedMatchDate)

                if let found = result.result {
                    let (matchDate, exactMatch) = found
                    var stop = false
                    previouslyReturnedMatchDate = matchDate
                    block(matchDate, exactMatch, &stop)
                    if stop { return }
                    searchingDate = matchDate
                } else if iterations < STOP_EXHAUSTIVE_SEARCH_AFTER_MAX_ITERATIONS {
                    // Try again on nil result
                    searchingDate = result.newSearchDate
                    continue
                } else {
                    // Give up
                    return
                }
            } catch {
                return
            }
        } while true
    }

    public func nextDate(after date: Date, matching components: DateComponents, matchingPolicy: Calendar.MatchingPolicy, repeatedTimePolicy: Calendar.RepeatedTimePolicy = .first, direction: Calendar.SearchDirection = .forward) -> Date? {
        var result: Date?
        self.enumerateDates(startingAfter: date, matching: components, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, direction: direction) { date, exactMatch, stop in
            result = date
            stop = true
        }
        return result
    }

    public enum Component: Sendable {
        case era
        case year
        case month
        case day
        case dayOfYear
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

#endif
