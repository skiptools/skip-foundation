// Copyright 2023–2026 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
// Based on: https://github.com/swiftlang/swift-foundation/blob/main/Sources/FoundationEssentials/Calendar/Calendar_Enumerate.swift
#if SKIP

let logger: Logger = Logger(subsystem: "Calendar_Enumerate", category: "SkipFoundation")

/* SKIP NOWARN */
extension Calendar {
    struct SearchStepResult {
        var result: (Date, Bool)?
        var newSearchDate: Date
    }
    
    enum CalendarEnumerationError: Error {
        case dateOutOfRange(Calendar.Component, Date /* failing date */)
        case notAdvancing(Date, Date)
        case unexpectedResult(Calendar.Component, Date /* failing date */)
    }
    
    func _enumerateDatesStep(startingAfter start: Date, matching matchingComponents: DateComponents, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, direction: SearchDirection, inSearchingDate searchingDate: Date, previouslyReturnedMatchDate: Date?) throws -> SearchStepResult {
        
        // Step A: Call helper method that does the searching
        let compsToMatch = _adjustedComponents(matchingComponents, date: searchingDate, direction: direction)
        logger.info("enumerateDatesStep: compsToMatch -> \(compsToMatch)")
        
        guard let matchDate = try _matchingDate(after: searchingDate, matching: compsToMatch, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy) else {
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        logger.info("enumerateDatesStep: matchDate -> \(matchDate)")
        return SearchStepResult(result: (matchDate, true), newSearchDate: searchingDate)
    }
}

// MARK: - Date Matching
/* SKIP NOWARN */
extension Calendar {
    func _matchingDate(after startDate: Date, matching comps: DateComponents, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy) throws -> Date? {
        
        let isStrictMatching = matchingPolicy == .strict
        
        var matchedEra = true
        var searchStartDate = startDate
        
        if let result = dateAfterMatchingEra(startingAt: searchStartDate, components: comps, direction: direction, matchedEra: &matchedEra) {
            searchStartDate = result
        }
        
        // If era doesn't match we can just bail here instead of continuing on. A date from another era can't match. It's up to the caller to decide how to handle this mismatch.
        if !matchedEra {
            return nil
        }
        
        if let result = try dateAfterMatchingYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingQuarter(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekOfYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingDayOfYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingMonth(startingAt: searchStartDate, components: comps, direction: direction, strictMatching: isStrictMatching) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekOfMonth(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekdayOrdinal(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekday(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingDay(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction, isStrictMatching: isStrictMatching) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingHour(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction, findLastMatch: repeatedTimePolicy == .last, isStrictMatching: isStrictMatching, matchingPolicy: matchingPolicy) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingMinute(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingSecond(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = dateAfterMatchingNanosecond(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        return searchStartDate
    }
    
    func _matchingDate(after startDate: Date, matching comps: DateComponents, inNextHighestUnit: Component, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy) throws -> Date? {
        
        logger.info("Info: _matchingDate in \(inNextHighestUnit) for \(startDate)")
        
        guard let foundRange = dateInterval(of: inNextHighestUnit, for: startDate) else {
            throw CalendarEnumerationError.dateOutOfRange(inNextHighestUnit, startDate)
        }
        
        logger.info("Info: Found range: \(foundRange)")
        
        var nextSearchDate: Date?
        var innerDirection = direction
        
        if innerDirection == .backward {
            if inNextHighestUnit == .day {
                /*
                 If nextHighestUnit is day, it's a safe assumption that the highest actual set unit is the hour.
                 There are cases where we're looking for a minute and/or second within the first hour of the day. If we start just at the top of the day and go backwards, we could end up missing the minute/second we're looking for.
                 E.g.
                 We're looking for { hour: 0, minute: 30, second: 0 } in the day before the start date 2017-05-26 07:19:50 UTC. At this point, foundRange.start would be 2017-05-26 07:00:00 UTC.
                 In this case, the algorithm would do the following:
                 start at 2017-05-26 07:00:00 UTC, see that the hour is already set to what we want, jump to minute.
                 when checking for minute, it will cycle forward to 2017-05-26 07:30:00 +0000 but then compare to the start and see that that date is incorrect because it's in the future. Then it will cycle the date back to 2017-05-26 06:30:00 +0000.
                 the matchingDate call below will exit with 2017-05-26 06:30:00 UTC and the algorithm will see that date is incorrect and reset the new search date go back a day to 2017-05-25 07:19:50 UTC. Then we get back here to this method and move the start to 2017-05-25 07:00:00 UTC and the call to matchingDate below will return 2017-05-25 06:30:00 UTC, which skips what we want (2017-05-25 07:30:00 UTC) and the algorithm eventually keeps moving further and further into the past until it exhausts itself and returns nil.
                 To adjust for this scenario, we add this line below that sets nextSearchDate to the last minute of the previous day (using the above example, 2017-05-26 06:59:59 UTC), which causes the algorithm to not skip the minutes/seconds within the first hour of the previous day. (<rdar://problem/32609242>)
                 */
                nextSearchDate = foundRange.start.addingTimeInterval(-1.0)
                
                // One caveat: if we are looking for a date within the first hour of the day (i.e. between 12 and 1 am), we want to ensure we go forwards in time to hit the exact minute and/or second we're looking for since nextSearchDate is now in the previous day. (<rdar://problem/33944890>).
                if comps.hour == 0 {
                    innerDirection = .forward
                }
            } else {
                nextSearchDate = foundRange.start
            }
        } else {
            nextSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
        }
        
        return try _matchingDate(after: nextSearchDate!, matching: comps, direction: innerDirection, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy)
    }
    
    func _adjustedComponents(_ comps: DateComponents, date: Date, direction: SearchDirection) -> DateComponents {
        // This method ensures that the algorithm enumerates through each year or month if they are not explicitly set in the DateComponents passed into enumerateDates.  This only applies to cases where the highest set unit is month or day (at least for now).  For full in context explanation, see where it gets called in enumerateDates.
        let highestSetUnit = comps.highestSetUnit
        switch highestSetUnit {
        case .month:
            var adjusted = comps
            adjusted.year = component(.year, from: date)
            // TODO: can year ever be nil here?
            if let adjustedDate = self.date(from: adjusted) {
                if direction == .forward && date > adjustedDate {
                    adjusted.year = (adjusted.year ?? 0) + 1
                } else if direction == .backward && date < adjustedDate {
                    adjusted.year = (adjusted.year ?? 0) - 1
                }
            }
            return adjusted
        case .day:
            var adjusted = comps
            if direction == .backward {
                let dateDay = component(.day, from: date)
                // We need to make sure we don't surpass the day we want.
                if comps.day ?? Int.max >= dateDay {
                    let tempDate = self.date(byAdding: .month, value: -1, to: date)!
                    adjusted.month = component(.month, from: tempDate)
                } else {
                    // Adjusted is the date components we're trying to match against; dateDay is the current day of the current search date.
                    // See the comment in enumerateDates for the justification for adding the month to the components here.
                    //
                    // However, we can't unconditionally add the current month to these components. If the current search date is on month M and day D, and the components we're trying to match have day D' set, the resultant date components to match against are {day=D', month=M}.
                    // This is only correct sometimes:
                    //
                    //  * If D' > D (e.g. we're on Nov 05, and trying to find the next 15th of the month), then it's okay to try to match Nov 15.
                    //  * However, if D' <= D (e.g. we're on Nov 05, and are trying to find the next 2nd of the month), then it's not okay to try to match Nov 02.
                    //
                    // We can only adjust the month if it won't cause us to search "backwards" in time (causing us to elsewhere end up skipping the first [correct] match we find).
                    // These same changes apply to the backwards case above.
                    let dateMonth = component(.month, from: date)
                    adjusted.month = dateMonth
                }
            } else {
                let dateDay = component(.day, from: date)
                if comps.day ?? Int.max > dateDay {
                    adjusted.month = component(.month, from: date)
                }
            }
            return adjusted
        default:
            // Nothing to adjust
            return comps
        }
    }
}

// MARK: - Component Matchers
/* SKIP NOWARN */
extension Calendar {
    func dateIfEraHasYear(era: Int, year: Int) -> Date? {
        var dateComp = DateComponents()
        dateComp.era = era
        dateComp.year = year
        dateComp.month = 1
        dateComp.day = 1
        
        guard var date = self.date(from: dateComp) else { return nil }
        
        var currentEra = component(.era, from: date)
        var currentYear = component(.year, from: date)
        
        if year == 1 {
            let addingComp = DateComponents(day: 1)
            
            // This is needed for Japanese calendar (and maybe other calendars with more than a few eras too).
            while currentEra < era {
                guard let newDate = self.date(byAdding: addingComp, to: date!) else { return nil }
                date = newDate
                currentEra = component(.era, from: date)
            }
            
            currentYear = component(.year, from: date)
        }
        
        if currentEra == era && currentYear == year {
            // For Gregorian calendar at least, era and year should always match up so date should always be assigned to result.
            return date
        }
        
        return nil
    }
    
    func dateAfterMatchingEra(startingAt: Date, components: DateComponents, direction: SearchDirection, matchedEra: inout Bool) -> Date? {
        
        logger.info("dateAfterMatchingEra: startingAt \(startingAt)")
        
        guard let era = components.era else {
            // Nothing to do
            logger.info("dateAfterMatchingEra: no era defined in components")
            return nil
        }
        
        let dateEra = component(.era, from: startingAt)
        guard era != dateEra else {
            // Already matches
            logger.info("dateAfterMatchingEra: era already matches components")
            return nil
        }
        
        if (direction == .backward && era <= dateEra) || (direction == .forward && era >= dateEra) {
            var dateComp = DateComponents()
            dateComp.era = era
            dateComp.year = 1
            dateComp.month = 1
            dateComp.day = 1
            dateComp.hour = 0
            dateComp.minute = 0
            dateComp.second = 0
            dateComp.nanosecond = 0
            
            if let result = self.date(from: dateComp) {
                let dateCompEra = component(.era, from: result)
                if dateCompEra != era {
                    matchedEra = false
                }
                return result
            } else {
                matchedEra = false
                return nil
            }
        } else {
            matchedEra = false
            return nil
        }
    }
    
    func dateAfterMatchingYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingYear: startingAt \(startingAt)")
        
        guard let year = components.year else {
            // Nothing to do
            logger.info("dateAfterMatchingYear: no year defined in components")
            return nil
        }
        
        let dateYear = component(.year, from: startingAt)
        let dateEra = component(.era, from: startingAt)
        
        guard year != dateYear else {
            // Already matches
            logger.info("dateAfterMatchingYear: year already matches components")
            return nil
        }
        
        guard let yearBegin = dateIfEraHasYear(era: dateEra, year: year) else {
            // TODO: Consider if this is an error or not
            return nil
        }
        
        // We set searchStartDate to the end of the year ONLY if we know we will be trying to match anything else beyond just the year and it'll be a backwards search; otherwise, we set searchStartDate to the start of the year.
        let totalSetUnits = components.setUnitCount
        if direction == .backward && totalSetUnits > 1 {
            guard year < dateYear else {
                throw CalendarEnumerationError.dateOutOfRange(.year, yearBegin)
            }
            
            let cal = components.createCalendarComponents()
            cal.time = yearBegin.platformValue
            cal.add(java.util.Calendar.YEAR, 1)
            if components.day == nil || components.day == 31 {
                cal.add(java.util.Calendar.DAY_OF_MONTH, -1)
            }
            return Date(platformValue: cal.time)
        } else {
            guard year > dateYear else {
                throw CalendarEnumerationError.dateOutOfRange(.year, yearBegin)
            }
            return yearBegin
        }
    }
    
    func dateAfterMatchingQuarter(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingQuarter: startingAt \(startingAt)")
        
        guard let quarter = components.quarter else {
            // Nothing to do
            logger.info("dateAfterMatchingQuarter: no quarter defined in components")
            return nil
        }
        
        // Get the beginning of the year we need.
        guard let foundRange = dateInterval(of: .year, for: startingAt) else {
            throw CalendarEnumerationError.dateOutOfRange(.year, startingAt)
        }
        
        logger.info("dateAfterMatchingQuarter: foundRange -> \(foundRange)")
        
        if direction == .backward {
            var count = 4
            var quarterBegin = foundRange.start.addingTimeInterval(foundRange.duration - 1)
            logger.info("dateAfterMatchingQuarter: quarterBegin -> \(quarterBegin)")
            
            while count != quarter && count > 0 {
                logger.info("dateAfterMatchingQuarter: count -> \(count)")
                guard let quarterRange = dateInterval(of: .quarter, for: quarterBegin) else {
                    throw CalendarEnumerationError.dateOutOfRange(.quarter, quarterBegin)
                }
                quarterBegin = quarterRange.start.addingTimeInterval(-quarterRange.duration)
                logger.info("dateAfterMatchingQuarter: quarterRange.start -> \(quarterRange.start)")
                logger.info("dateAfterMatchingQuarter: quarterRange.duration -> \(quarterRange.duration)")
                logger.info("dateAfterMatchingQuarter: quarterBegin -> \(quarterBegin)")
                count -= 1
            }
            
            return quarterBegin
        } else {
            var count = 1
            var quarterBegin = foundRange.start
            logger.info("dateAfterMatchingQuarter: quarterBegin -> \(quarterBegin)")
            
            while count != quarter && count < 5 {
                logger.info("dateAfterMatchingQuarter: count -> \(count)")
                guard let quarterRange = dateInterval(of: .quarter, for: quarterBegin) else {
                    throw CalendarEnumerationError.dateOutOfRange(.quarter, quarterBegin)
                }
                // Move past this quarter. The is the first instant of the next quarter.
                quarterBegin = quarterRange.start.addingTimeInterval(quarterRange.duration)
                logger.info("dateAfterMatchingQuarter: quarterRange.start -> \(quarterRange.start)")
                logger.info("dateAfterMatchingQuarter: quarterRange.duration -> \(quarterRange.duration)")
                logger.info("dateAfterMatchingQuarter: quarterBegin -> \(quarterBegin)")
                count += 1
            }
            
            return quarterBegin
        }
    }
    
    func dateAfterMatchingMonth(startingAt: Date, components: DateComponents, direction: SearchDirection, strictMatching: Bool) throws -> Date? {
        
        logger.info("dateAfterMatchingMonth: startingAt \(startingAt)")
        
        guard let month = components.month else {
            // Nothing to do
            logger.info("dateAfterMatchingMonth: no month defined in components")
            return nil
        }
        
        var dateMonth = component(.month, from: startingAt)
        guard month != dateMonth else {
            // Already matches
            logger.info("dateAfterMatchingMonth: month already matches components")
            return nil
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            let lastResult = result
            logger.info("dateAfterMatchingMonth: lastResult -> \(lastResult)")
            guard let foundRange = dateInterval(of: .month, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.month, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.MONTH, -1)
            } else {
                cal.add(java.util.Calendar.MONTH, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingMonth: searchDate -> \(searchDate)")
            dateMonth = component(.month, from: searchDate)
            logger.info("dateAfterMatchingMonth: dateMonth -> \(dateMonth)")
            result = searchDate
            logger.info("dateAfterMatchingMonth: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while month != dateMonth
        
        return result
    }
    
    func dateAfterMatchingWeekOfYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingWeekOfYear: startingAt \(startingAt)")
        
        guard let weekOfYear = components.weekOfYear else {
            // Nothing to do
            logger.info("dateAfterMatchingWeekOfYear: no week of year defined in components")
            return nil
        }
        
        var dateWeekOfYear = component(.weekOfYear, from: startingAt)
        guard weekOfYear != dateWeekOfYear else {
            // Already matches
            logger.info("dateAfterMatchingWeekOfYear: week of year already matches components")
            return nil
        }
        
        // After this point, the result is at least the start date.
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            // Used to check if we are not advancing the week of year.
            let lastResult = result
            guard let foundRange = dateInterval(of: .weekOfYear, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.weekOfYear, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.WEEK_OF_YEAR, -1)
            } else {
                cal.add(java.util.Calendar.WEEK_OF_YEAR, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingWeekOfYear: searchDate -> \(searchDate)")
            dateWeekOfYear = component(.weekOfYear, from: searchDate)
            logger.info("dateAfterMatchingWeekOfYear: dateWeekOfYear -> \(dateWeekOfYear)")
            result = searchDate
            logger.info("dateAfterMatchingWeekOfYear: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while weekOfYear != dateWeekOfYear
        
        return result
    }
    
    func dateAfterMatchingWeekOfMonth(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingWeekOfMonth: startingAt \(startingAt)")
        
        guard let weekOfMonth = components.weekOfMonth else {
            // Nothing to do
            logger.info("dateAfterMatchingWeekOfMonth: no week of month defined in components")
            return nil
        }
        
        var dateWeekOfMonth = component(.weekOfMonth, from: startingAt)
        guard weekOfMonth != dateWeekOfMonth else {
            // Already matches
            logger.info("dateAfterMatchingWeekOfMonth: week of month already matches components")
            return nil
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            // Used to check if we are not advancing the week of month.
            let lastResult = result
            guard let foundRange = dateInterval(of: .weekOfMonth, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.weekOfMonth, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.WEEK_OF_MONTH, -1)
            } else {
                cal.add(java.util.Calendar.WEEK_OF_MONTH, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingWeekOfMonth: searchDate -> \(searchDate)")
            dateWeekOfMonth = component(.weekOfMonth, from: searchDate)
            logger.info("dateAfterMatchingWeekOfMonth: dateWeekOfMonth -> \(dateWeekOfMonth)")
            result = searchDate
            logger.info("dateAfterMatchingWeekOfMonth: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while weekOfMonth != dateWeekOfMonth
        
        return result
    }
    
    func dateAfterMatchingDayOfYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingDayOfYear: startingAt \(startingAt)")
        
        guard let dayOfYear = components.dayOfYear else {
            // Nothing to do
            logger.info("dateAfterMatchingDayOfYear: no day of year defined in components")
            return nil
        }
        
        var dateDayOfYear = component(.dayOfYear, from: startingAt)
        guard dayOfYear != dateDayOfYear else {
            // Already matches
            logger.info("dateAfterMatchingDayOfYear: day of year already matches components")
            return nil
        }
        
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            let lastResult = result
            logger.info("dateAfterMatchingDayOfYear: lastResult -> \(lastResult)")
            guard let foundRange = dateInterval(of: .dayOfYear, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.dayOfYear, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.DAY_OF_YEAR, -1)
            } else {
                cal.add(java.util.Calendar.DAY_OF_YEAR, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingDayOfYear: searchDate -> \(searchDate)")
            dateDayOfYear = component(.dayOfYear, from: searchDate)
            logger.info("dateAfterMatchingDayOfYear: dateDayOfYear -> \(dateDayOfYear)")
            result = searchDate
            logger.info("dateAfterMatchingDayOfYear: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while dayOfYear != dateDayOfYear
        
        return result
    }
    
    func dateAfterMatchingDay(startingAt: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection, isStrictMatching: Bool) throws -> Date? {
        
        logger.info("dateAfterMatchingDay: startingAt \(startingAt)")
        
        guard let day = components.day else {
            // Nothing to do
            logger.info("dateAfterMatchingDay: no day defined in components")
            return nil
        }
        
        var dateDay = component(.day, from: startingAt)
        guard day != dateDay else {
            // Already matches
            logger.info("dateAfterMatchingDay: day already matches components")
            return nil
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            // Used to check if we are not advancing the day.
            let lastResult = result
            guard let foundRange = dateInterval(of: .day, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.day, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.DAY_OF_MONTH, -1)
            } else {
                cal.add(java.util.Calendar.DAY_OF_MONTH, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingDay: searchDate -> \(searchDate)")
            dateDay = component(.day, from: searchDate)
            logger.info("dateAfterMatchingDay: dateDay -> \(dateDay)")
            result = searchDate
            logger.info("dateAfterMatchingDay: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
            
            // Used to check if we are not advancing the month.
            if let targetMonth = components.month {
                let currentMonth = component(.month, from: searchDate)
                if currentMonth != targetMonth {
                    if isStrictMatching {
                        throw CalendarEnumerationError.dateOutOfRange(.month, searchDate)
                    } else {
                        break
                    }
                }
            }
        } while day != dateDay
        
        return result
    }
    
    func dateAfterMatchingWeekdayOrdinal(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingWeekdayOrdinal: startingAt \(startingAt)")
        
        guard let weekdayOrdinal = components.weekdayOrdinal else {
            // Nothing to do
            logger.info("dateAfterMatchingWeekdayOrdinal: no weekday ordinal defined in components")
            return nil
        }
        
        var dateWeekdayOrdinal = self.component(.weekdayOrdinal, from: startingAt)
        guard weekdayOrdinal != dateWeekdayOrdinal else {
            // Nothing to do
            logger.info("dateAfterMatchingWeekdayOrdinal: weekday ordinal already matches components")
            return nil
        }
        
        // After this point, result is at least startDate
        var result = startingAt
        let cal = components.createCalendarComponents()
        repeat {
            let lastResult = result
            logger.info("dateAfterMatchingWeekdayOrdinal: lastResult -> \(lastResult)")
            guard let foundRange = self.dateInterval(of: .weekdayOrdinal, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.weekdayOrdinal, result)
            }
            
            cal.time = foundRange.start.platformValue
            if direction == .backward {
                cal.add(java.util.Calendar.DAY_OF_MONTH, -1)
            } else {
                cal.add(java.util.Calendar.DAY_OF_MONTH, 1)
            }
            
            let searchDate = Date(platformValue: cal.time)
            logger.info("dateAfterMatchingWeekdayOrdinal: searchDate -> \(searchDate)")
            dateWeekdayOrdinal = component(.weekdayOrdinal, from: result)
            logger.info("dateAfterMatchingWeekdayOrdinal: dateWeekdayOrdinal -> \(dateWeekdayOrdinal)")
            result = searchDate
            logger.info("dateAfterMatchingWeekdayOrdinal: result -> \(result)")
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while weekdayOrdinal != dateWeekdayOrdinal
        
        return result
    }
    
    func dateAfterMatchingWeekday(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingWeekday: startingAt \(startingAt)")
        
        guard let weekday = components.weekday else {
            // Nothing to do
            logger.info("dateAfterMatchingWeekday: no weekday defined in components")
            return nil
        }
        
        // NOTE: This differs from the weekday check in weekdayOrdinal because weekday is meant to be ambiguous and can be set without setting the ordinality.
        // e.g. inquiries like "find the next Tuesday after 2017-06-01" or "find every Wednesday before 2012-12-25"
        var dateWeekday = self.component(.weekday, from: startingAt)
        guard weekday != dateWeekday else {
            // Already matches
            logger.info("dateAfterMatchingWeekday: weekday already matches components")
            return nil
        }
        
        // After this point, result is at least startDate
        var result = startingAt
        repeat {
            guard let foundRange = self.dateInterval(of: .weekday, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.weekday, result)
            }
            
            // We need to either advance or rewind by a day.
            // * Advancing to tomorrow is relatively simple: get the start of today and get the length of that day — then, advance by that length
            // * Rewinding to the start of yesterday is more complicated: the length of today is not necessarily the length of yesterday if DST transitions are involved:
            //   * Today can have 25 hours: if we rewind 25 hours from the start of today, we'll skip yesterday altogether
            //   * Today can have 24 hours: if we rewind 24 hours from the start of today, we might skip yesterday if it had 23 hours, or end up at the wrong time if it had 25
            //   * Today can have 23 hours: if we rewind 23 hours from the start of today, we'll end up at the wrong time yesterday
            //
            // We need to account for DST by ensuring we rewind to exactly the time we want.
            let tempSearchDate: Date
            if direction == .backward {
                let lateYesterday = foundRange.start.addingTimeInterval(-1)
                if let anotherFoundRange = self.dateInterval(of: .day, for: lateYesterday) {
                    tempSearchDate = anotherFoundRange.start
                } else {
                    // This fallback is only really correct when today and yesterday have the same length.
                    // Again, it shouldn't be possible to hit this case.
                    tempSearchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                }
            } else {
                // This is always correct to do since we are using today's length on today — there can't be a mismatch.
                tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
            }
            
            dateWeekday = self.component(.weekday, from: tempSearchDate)
            
            try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
            
            result = tempSearchDate
        } while weekday != dateWeekday
        
        return result
    }
    
    func dateAfterMatchingHour(startingAt startDate: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection, findLastMatch: Bool, isStrictMatching: Bool, matchingPolicy: MatchingPolicy) throws -> Date? {
        
        logger.info("dateAfterMatchingHour: startingAt \(startingAt)")
        
        guard let hour = components.hour else {
            // Nothing to do
            logger.info("dateAfterMatchingHour: no hour defined in components")
            return nil
        }
        
        var result = startDate
        var adjustedSearchStartDate = false
        
        var dateHour = self.component(.hour, from: result)
        
        // The loop below here takes care of advancing forward in the case of an hour mismatch, taking DST into account.
        // However, it does not take into account a unique circumstance: searching for hour 0 of a day on a day that has no hour 0 due to DST.
        //
        // America/Sao_Paulo, for instance, is a time zone which has DST at midnight -- an instant after 11:59:59 PM can become 1:00 AM, which is the start of the new day:
        //
        //            2018-11-03                      2018-11-04
        //    ┌─────11:00 PM (GMT-3)─────┐ │ ┌ ─ ─ 12:00 AM (GMT-3)─ ─ ─┐ ┌─────1:00 AM (GMT-2) ─────┐
        //    │                          │ │ |                          │ │                          │
        //    └──────────────────────────┘ │ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘ └▲─────────────────────────┘
        //                                            Nonexistent           └── Start of Day
        //
        // The issue with this specifically is that parts of the rewinding algorithm that handle overshooting rewind to the start of the day to search again (or alternatively, adjusting higher components tends to send us to the start of the day).
        // This doesn't work when the day starts past the time we're looking for if we're looking for hour 0.
        //
        // If we're not matching strictly, we need to check whether we're already a non-strict match and not an overshoot.
        if hour == 0 /* searching for hour 0 */ && !isStrictMatching {
            logger.info("dateAfterMatchingHour: searching for hour 0")
            if let foundRange = self.dateInterval(of: .day, for: result) {
                let dayBegin = foundRange.start
                logger.info("dateAfterMatchingHour: dayBegin -> \(dayBegin)")
                let firstHourOfTheDay = self.component(.hour, from: dayBegin)
                if firstHourOfTheDay != 0 && dateHour == firstHourOfTheDay {
                    // We're at the start of the day; it's just not hour 0.
                    // We have a candidate match. We can modify that match based on the actual options we need to set.
                    
                    if matchingPolicy == .nextTime {
                        // We don't need to preserve the smallest components. We can wipe them out.
                        // Note that we rewind to the start of the hour by rewinding to the start of the day -- normally we'd want to rewind to the start of _this_ hour in case there were a difference in a first/last scenario (repeated hour DST transition), but we can't both be missing hour 0 _and_ be the second hour in a repeated transition.
                        result = dayBegin
                    } else if matchingPolicy == .nextTimePreservingSmallerComponents || matchingPolicy == .previousTimePreservingSmallerComponents {
                        // We want to preserve any currently set smaller units (hour and minute), so don't do anything.
                        // If we need to match the previous time (i.e. go back an hour), that adjustment will be made elsewhere, in the generalized isForwardDST adjustment in the main loop.
                    }
                    
                    // Avoid making any further adjustments again.
                    adjustedSearchStartDate = true
                }
            }
        }
        
        // This is a real mismatch and not due to hour 0 being missing.
        // NOTE: The behavior of generalized isForwardDST checking depends on the behavior of this loop!
        //        Right now, in the general case, this loop stops iteration _before_ a forward DST transition. If that changes, please take a look at the isForwardDST code for when `beforeTransition = false` and adjust as necessary.
        if hour != dateHour && !adjustedSearchStartDate {
            logger.info("dateAfterMatchingHour: searching for hour != 0")
            repeat {
                let lastResult = result
                guard let foundRange = self.dateInterval(of: .hour, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.hour, result)
                }
                
                let prevDateHour = dateHour
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                
                dateHour = self.component(.hour, from: tempSearchDate)
                
                // Sometimes we can get into a position where the next hour is also equal to hour (as in we hit a backwards DST change). In this case, we could be at the first time this hour occurs. If we want the next time the hour is technically the same (as in we need to go to the second time this hour occurs), we check to see if we hit a backwards DST change.
                let possibleBackwardDSTDate = foundRange.start.addingTimeInterval(foundRange.duration * 2.0)
                let secondDateHour = self.component(.hour, from: possibleBackwardDSTDate)
                
                if ((dateHour - prevDateHour) == 2) || (prevDateHour == 23 && dateHour == 1) {
                    // We've hit a forward DST transition.
                    dateHour = dateHour - 1
                    result = foundRange.start
                } else if (secondDateHour == dateHour) && findLastMatch {
                    // If we're not trying to find the last match, just pass on the match we already found.
                    // We've hit a backwards DST transition.
                    result = possibleBackwardDSTDate
                } else {
                    result = tempSearchDate
                }
                
                adjustedSearchStartDate = true
                
                // Verify the hour value (it changes even if the result does not)
                if (result == lastResult && prevDateHour == dateHour) {
                    // We are not advancing. Bail out of the loop
                    throw CalendarEnumerationError.notAdvancing(result, lastResult)
                }
            } while hour != dateHour
            
            if direction == .backward && originalStartDate < result {
                // We've gone into the future when we were supposed to go into the past.  We're ahead by a day.
                if let rolledBack = self.date(byAdding: .day, value: -1, to: result) {
                    result = rolledBack
                }
                
                // Check hours again to see if they match (they may not because of DST change already being handled implicitly by dateByAddingUnit:)
                dateHour = self.component(.hour, from: result)
                if (dateHour - hour) == 1 {
                    // Detecting a DST transition
                    // We have moved an hour ahead of where we want to be so we go back 1 hour to readjust.
                    if let adjusted = self.date(byAdding: .hour, value: -1, to: result) { result = adjusted }
                } else if (hour - dateHour) == 1 {
                    // <rdar://problem/31051045>
                    // This is a weird special edge case that only gets hit when you're searching backwards and move past a forward (skip an hour) DST transition.
                    // We're not at a DST transition but the hour of our date got moved because the previous day had a DST transition.
                    // So we're an hour before where we want to be. We move an hour ahead to correct and get back to where we need to be.
                    if let adjusted = self.date(byAdding: .hour, value: 1, to: result) { result = adjusted }
                }
            }
        }
        
        if findLastMatch {
            if let foundRange = self.dateInterval(of: .hour, for: result) {
                // Rewind forward/back hour-by-hour until we get to a different hour. A loop here is necessary because not all DST transitions are only an hour long.
                var next = foundRange.start
                var nextHour = hour
                while nextHour == hour {
                    result = next
                    let offset = (direction == .backward ? -1 : 1)
                    if let nextDate = self.date(byAdding: .hour, value: offset, to: next) {
                        next = nextDate
                    } else {
                        break
                    }
                    nextHour = self.component(.hour, from: next)
                }
            }
        }
        
        if !adjustedSearchStartDate {
            // This applies if we didn't hit the above cases to adjust the search start date, i.e. the hour already matches the start hour and either:
            // 1) We're not looking to match the "last" (repeated) hour in a DST transition (regardless of whether we're in a DST transition), or
            // 2) We are looking to match that hour, but we're not in that DST transition.
            //
            // In either case, we need to clear the lower components in case they are not part of the components we're looking for.
            if let foundRange = self.dateInterval(of: .hour, for: result) {
                result = foundRange.start
                adjustedSearchStartDate = true
            }
        }
        
        return result
    }
    
    func dateAfterMatchingMinute(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingMinute: startingAt \(startingAt)")
        
        guard let minute = components.minute else {
            // Nothing to do
            logger.info("dateAfterMatchingMinute: no minute defined in components")
            return nil
        }
        
        var result = startingAt
        var dateMinute = self.component(.minute, from: result)
        if minute != dateMinute {
            repeat {
                guard let foundRange = self.dateInterval(of: .minute, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.minute, result)
                }
                
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateMinute = self.component(.minute, from: tempSearchDate)
                
                try verifyUnequalResult(tempSearchDate, previous: result, startingAt: startingAt, components: components, direction: direction, strict: nil)
                
                result = tempSearchDate
            } while minute != dateMinute
        } else {
            // When the search date matches the minute we're looking for, we need to clear the lower components in case they are not part of the components we're looking for.
            if let foundRange = self.dateInterval(of: .minute, for: result) {
                result = foundRange.start
            }
        }
        
        return result
    }
    
    func dateAfterMatchingSecond(startingAt startDate: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        logger.info("dateAfterMatchingSecond: startingAt \(startingAt)")
        
        guard let second = components.second else {
            // Nothing to do
            logger.info("dateAfterMatchingSecond: no second defined in components")
            return nil
        }
        
        // After this point, result is at least startDate
        var result = startDate
        
        var dateSecond = self.component(.second, from: result)
        if second != dateSecond {
            repeat {
                guard let foundRange = self.dateInterval(of: .second, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.second, result)
                }
                
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateSecond = self.component(.second, from: tempSearchDate)
                try verifyUnequalResult(tempSearchDate, previous: result, startingAt: startDate, components: components, direction: direction, strict: nil)
                result = tempSearchDate
            } while second != dateSecond

            if originalStartDate < result {
                if direction == .backward {
                    // We've gone into the future when we were supposed to go into the past.
                    // There are multiple times a day where the seconds repeat.  Need to take that into account.
                    let originalStartSecond = self.component(.second, from: originalStartDate)
                    if dateSecond > originalStartSecond {
                        guard let new = self.date(byAdding: .minute, value: -1, to: result) else {
                            return nil
                        }
                        result = new
                    }
                } else {
                    // This handles the case where dateSecond started ahead of second, so doing the above landed us in the next minute.  If minute is not set, we are fine.  But if minute is set, then we are now in the wrong minute and we have to readjust. <rdar://problem/31098131>
                    var searchStartMin = self.component(.minute, from: result)
                    if let minute = components.minute {
                        if searchStartMin > minute {
                            // We've gone ahead of where we needed to be
                            repeat {
                                // Reset to beginning of minute
                                guard let foundRange = self.dateInterval(of: .minute, for: result) else {
                                    throw CalendarEnumerationError.dateOutOfRange(.minute, result)
                                }
                                
                                let tempSearchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                                searchStartMin = self.component(.minute, from: tempSearchDate)
                                try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
                                result = tempSearchDate
                            } while searchStartMin > minute
                        }
                    }
                }
            }
        } else {
            // When the search date matches the second we're looking for, we need to clear the lower components in case they are not part of the components we're looking for.
            guard let anotherFoundRange = self.dateInterval(of: .second, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.second, result)
            }
            result = anotherFoundRange.start
            // Now searchStartDate <= startDate
        }
        
        return result
    }
    
    func dateAfterMatchingNanosecond(startingAt: Date, components: DateComponents, direction: SearchDirection) -> Date? {
        
        logger.info("dateAfterMatchingNanosecond: startingAt \(startingAt)")
        
        guard let nanosecond = components.nanosecond else {
            // Nothing to do
            logger.info("dateAfterMatchingNanosecond: no nanosecond defined in components")
            return nil
        }
        
        // This taken directly from the old algorithm.  We don't have great support for nanoseconds in general and trying to treat them like seconds causes a hang. :-/
        // <rdar://problem/30229247>
        let units: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute, .second]
        var dateComp = self.dateComponents(units, from: startingAt)
        
        dateComp.nanosecond = nanosecond
        return self.date(from: dateComp)
    }
}

// MARK: - Helpers
/* SKIP NOWARN */
extension Calendar {
    func date(_ date: Date, containsMatchingComponents compsToMatch: DateComponents) -> (Set<Calendar.Component>, Bool) {
        var dateMatchesComps = true
        let units = compsToMatch.setUnits
        var compsFromDate = self.dateComponents(units, from: date)
        
        if compsToMatch.calendar != nil {
            compsFromDate.calendar = compsToMatch.calendar
        }
        if compsToMatch.timeZone != nil {
            compsFromDate.timeZone = compsToMatch.timeZone
        }
        
        if compsFromDate != compsToMatch {
            dateMatchesComps = false
            var mismatchedUnitsOut = compsFromDate.mismatchedUnits(comparedTo: compsToMatch)
            
            // We only care about mismatched leapMonth if it was set on the compsToMatch input. Otherwise we ignore it, even if it's set on compsFromDate.
            if compsToMatch.isLeapMonth == nil {
                // Remove if it's present
                mismatchedUnitsOut.remove(Calendar.Component.isLeapMonth)
            }
            
            if mismatchedUnitsOut.isEmpty {
                return ([], true)
            }
            
            return (mismatchedUnitsOut, false)
        } else {
            return ([], true)
        }
    }
    
    func bumpedDateUpToNextHigherUnitInComponents(_ searchingDate: Date, _ components: DateComponents, _ direction: SearchDirection, _ matchDate: Date?) -> Date? {
        guard let highestSetUnit = components.highestSetUnit else {
            // Empty components?
            return nil
        }
        
        let nextUnitAboveHighestSet: Component
        
        if highestSetUnit == Calendar.Component.era {
            nextUnitAboveHighestSet = Calendar.Component.year
        } else if highestSetUnit == Calendar.Component.year || highestSetUnit == Calendar.Component.yearForWeekOfYear {
            nextUnitAboveHighestSet = highestSetUnit
        } else {
            guard let next = highestSetUnit.nextHigherUnit else {
                return nil
            }
            nextUnitAboveHighestSet = next
        }
        
        // Advance to the start or end of the next highest unit. Old code here used to add `±1 nextUnitAboveHighestSet` to searchingDate and manually adjust afterwards, but this is incorrect in many cases.
        // For instance, this is wrong when searching forward looking for a specific Week of Month. Take for example, searching for WoM == 1:
        //
        //           January 2018           February 2018
        //       Su Mo Tu We Th Fr Sa    Su Mo Tu We Th Fr Sa
        //  W1       1  2  3  4  5  6                 1  2  3
        //  W2    7  8  9 10 11 12 13     4  5  6  7  8  9 10
        //  W3   14 15 16 17 18 19 20    11 12 13 14 15 16 17
        //  W4   21 22 23 24 25 26 27    18 19 20 21 22 23 24
        //  W5   28 29 30 31             25 26 27 28
        //
        // Consider searching for `WoM == 1` when searchingDate is *in* W1 of January. Because we're looking to advance to next month, we could simply add a month, right?
        // Adding a month from Monday, January 1st lands us on Thursday, February 1st; from Tuesday, January 2nd we get Friday, February 2nd, etc. Note though that for January 4th, 5th, and 6th, adding a month lands us in **W2** of February!
        // This means that if we continue searching forward from there, we'll have completely skipped W1 of February as a candidate week, and search forward until we hit W1 of March. This is incorrect.
        //
        // What we really want is to skip to the _start_ of February and search from there -- if we undershoot, we can always keep looking.
        // Searching backwards is similar: we can overshoot if we were subtracting a month, so instead we want to jump back to the very end of the previous month.
        // In general, this translates to jumping to the very beginning of the next period of the next highest unit when searching forward, or jumping to the very end of the last period when searching backward.

        guard let foundRange = dateInterval(of: nextUnitAboveHighestSet, for: searchingDate) else {
            return nil
        }
        
        var result = foundRange.start.addingTimeInterval(direction == .backward ? -1.0 : foundRange.duration)
        
        if let matchDate {
            let ordering = matchDate.compare(result)
            if (ordering != .orderedAscending && direction == .forward) || (ordering != .orderedDescending && direction == .backward) {
                // We need to advance searchingDate so that it starts just after matchDate
                // We already guarded against an empty components above, so force unwrap here
                if let lowestSetUnit = components.highestSetUnit { // Nutze den Helper von vorhin
                    guard let date = self.date(byAdding: lowestSetUnit, value: direction == .backward ? -1 : 1, to: matchDate) else {
                        return nil
                    }
                    result = date
                }
            }
        }
        
        return result
    }
    
    func preserveSmallerUnits(_ date: Date, compsToMatch: DateComponents, compsToModify: inout DateComponents) {
        let smallerUnits = self.dateComponents([.hour, .minute, .second], from: date)
        
        // Either preserve the units we're trying to match if they are explicitly defined or preserve the hour/min/sec in the date.
        compsToModify.hour = compsToMatch.hour ?? smallerUnits.hour
        compsToModify.minute = compsToMatch.minute ?? smallerUnits.minute
        compsToModify.second = compsToMatch.second ?? smallerUnits.second
    }
    
    func verifyAdvancingResult(_ next: Date, previous: Date, direction: Calendar.SearchDirection) throws {
        if (direction == .forward && next <= previous) || (direction == .backward && next >= previous) {
            // We are not advancing. Bail out of the loop.
            throw CalendarEnumerationError.notAdvancing(next, previous)
        }
    }
    
    private func verifyUnequalResult(_ next: Date, previous: Date, startingAt: Date, components: DateComponents, direction: Calendar.SearchDirection, strict: Bool?) throws {
        if (next == previous) {
            // We are not advancing. Bail out of the loop
            throw CalendarEnumerationError.notAdvancing(next, previous)
        }
    }
}

// MARK: - Private Extensions
private extension Calendar.Component {
    var nextHigherUnit: Self? {
        switch self {
        case .timeZone, .calendar:
            return nil // not really components
        case .era:
            return nil
        case .year, .yearForWeekOfYear:
            return .era
        case .weekOfYear:
            return .yearForWeekOfYear
        case .quarter, .isLeapMonth, .month, .dayOfYear:
            return .year
        case .day, .weekOfMonth, .weekdayOrdinal, .isRepeatedDay:
            return .month
        case .weekday:
            return .weekOfMonth
        case .hour:
            return .day
        case .minute:
            return .hour
        case .second:
            return .minute
        case .nanosecond:
            return .second
        }
    }
}

private extension Set where Element == Calendar.Component {
    var highestSetUnit: Calendar.Component? {
        if self.contains(Calendar.Component.era) { return .era }
        if self.contains(Calendar.Component.year) { return .year }
        if self.contains(Calendar.Component.dayOfYear) { return .dayOfYear }
        if self.contains(Calendar.Component.quarter) { return .quarter }
        if self.contains(Calendar.Component.month) { return .month }
        if self.contains(Calendar.Component.day) { return .day }
        if self.contains(Calendar.Component.hour) { return .hour }
        if self.contains(Calendar.Component.minute) { return .minute }
        if self.contains(Calendar.Component.second) { return .second }
        if self.contains(Calendar.Component.weekday) { return .weekday }
        if self.contains(Calendar.Component.weekdayOrdinal) { return .weekdayOrdinal }
        if self.contains(Calendar.Component.weekOfMonth) { return .weekOfMonth }
        if self.contains(Calendar.Component.weekOfYear) { return .weekOfYear }
        if self.contains(Calendar.Component.yearForWeekOfYear) { return .yearForWeekOfYear }
        if self.contains(Calendar.Component.nanosecond) { return .nanosecond }
        
        // The algorithms that call this function assume that isLeapMonth and isRepeatedDay can count as 'highest unit set', but they are ordered after nanosecond.
        if self.contains(Calendar.Component.isLeapMonth) { return .isLeapMonth }
        if self.contains(Calendar.Component.isRepeatedDay) { return .isRepeatedDay }
        
        // The calendar and timeZone properties do not count as a 'highest unit set', since they are not ordered in time like the others are.
        return nil
    }
}

private extension DateComponents {
    var highestSetUnit: Calendar.Component? {
        // A note on performance: this approach is much faster than using key paths, which require a lot more allocations.
        if self.era != nil { return .era }
        if self.year != nil { return .year }
        if self.dayOfYear != nil { return .dayOfYear }
        if self.quarter != nil { return .quarter }
        if self.month != nil { return .month }
        if self.day != nil { return .day }
        if self.hour != nil { return .hour }
        if self.minute != nil { return .minute }
        if self.second != nil { return .second }

        // It may seem a bit odd to check in this order, but it's been a longstanding behavior
        if self.weekday != nil { return .weekday }
        if self.weekdayOrdinal != nil { return .weekdayOrdinal }
        if self.weekOfMonth != nil { return .weekOfMonth }
        if self.weekOfYear != nil { return .weekOfYear }
        if self.yearForWeekOfYear != nil { return .yearForWeekOfYear }
        if self.nanosecond != nil { return .nanosecond }
        return nil
    }
    
    var lowestSetUnit: Calendar.Component? {
        // A note on performance: this approach is much faster than using key paths, which require a lot more allocations.
        if self.nanosecond != nil { return .nanosecond }

        // It may seem a bit odd to check in this order, but it's been a longstanding behavior
        if self.yearForWeekOfYear != nil { return .yearForWeekOfYear }
        if self.weekOfYear != nil { return .weekOfYear }
        if self.weekOfMonth != nil { return .weekOfMonth }
        if self.weekdayOrdinal != nil { return .weekdayOrdinal }
        if self.weekday != nil { return .weekday }
        if self.second != nil { return .second }
        if self.minute != nil { return .minute }
        if self.hour != nil { return .hour }
        if self.day != nil { return .day }
        if self.month != nil { return .month }
        if self.quarter != nil { return .quarter }
        if self.dayOfYear != nil { return .dayOfYear }
        if self.year != nil { return .year }
        if self.era != nil { return .era }
        return nil
    }

    var setUnits: Set<Calendar.Component> {
        var units = Set<Calendar.Component>()
        if self.era != nil { units.insert(.era) }
        if self.year != nil { units.insert(.year) }
        if self.quarter != nil { units.insert(.quarter) }
        if self.month != nil { units.insert(.month) }
        if self.day != nil { units.insert(.day) }
        if self.hour != nil { units.insert(.hour) }
        if self.minute != nil { units.insert(.minute) }
        if self.second != nil { units.insert(.second) }
        if self.weekday != nil { units.insert(.weekday) }
        if self.weekdayOrdinal != nil { units.insert(.weekdayOrdinal) }
        if self.weekOfMonth != nil { units.insert(.weekOfMonth) }
        if self.weekOfYear != nil { units.insert(.weekOfYear) }
        if self.yearForWeekOfYear != nil { units.insert(.yearForWeekOfYear) }
        if self.dayOfYear != nil { units.insert(.dayOfYear) }
        if self.nanosecond != nil { units.insert(.nanosecond) }
        return units
    }

    var setUnitCount: Int {
        return setUnits.count
    }
    
    func mismatchedUnits(comparedTo other: DateComponents) -> Set<Calendar.Component> {
        var mismatched = Set<Calendar.Component>()
        
        if self.era != other.era { mismatched.insert(Calendar.Component.era) }
        if self.year != other.year { mismatched.insert(Calendar.Component.year) }
        if self.quarter != other.quarter { mismatched.insert(Calendar.Component.quarter) }
        if self.month != other.month { mismatched.insert(Calendar.Component.month) }
        if self.day != other.day { mismatched.insert(Calendar.Component.day) }
        if self.hour != other.hour { mismatched.insert(Calendar.Component.hour) }
        if self.minute != other.minute { mismatched.insert(Calendar.Component.minute) }
        if self.second != other.second { mismatched.insert(Calendar.Component.second) }
        if self.weekday != other.weekday { mismatched.insert(Calendar.Component.weekday) }
        if self.weekdayOrdinal != other.weekdayOrdinal { mismatched.insert(Calendar.Component.weekdayOrdinal) }
        if self.weekOfMonth != other.weekOfMonth { mismatched.insert(Calendar.Component.weekOfMonth) }
        if self.weekOfYear != other.weekOfYear { mismatched.insert(Calendar.Component.weekOfYear) }
        if self.yearForWeekOfYear != other.yearForWeekOfYear { mismatched.insert(Calendar.Component.yearForWeekOfYear) }
        if self.nanosecond != other.nanosecond { mismatched.insert(Calendar.Component.nanosecond) }
        if self.isLeapMonth != other.isLeapMonth { mismatched.insert(Calendar.Component.isLeapMonth) }
        if self.dayOfYear != other.dayOfYear { mismatched.insert(Calendar.Component.dayOfYear) }
        
        return mismatched
    }
}

#endif
